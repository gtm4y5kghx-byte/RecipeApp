import Foundation

@MainActor
protocol UnifiedSuggestionProviding {
    func getUnifiedSuggestions(recipes: [Recipe], forceRefresh: Bool) async throws -> [UnifiedSuggestion]
}

@MainActor
class UnifiedSuggestionService: UnifiedSuggestionProviding {

    private let suggestionEngine: AISuggestionProviding
    private let generationService: RecipeGenerating
    private let isPremiumProvider: () -> Bool
    private let minimumRecipeCount = 10

    init(
        suggestionEngine: AISuggestionProviding? = nil,
        generationService: RecipeGenerating? = nil,
        isPremiumProvider: (() -> Bool)? = nil
    ) {
        self.suggestionEngine = suggestionEngine ?? AISuggestionEngineService()
        self.generationService = generationService ?? RecipeGenerationService()
        self.isPremiumProvider = isPremiumProvider ?? { UserSubscriptionService.shared.isPremium }
    }

    func getUnifiedSuggestions(recipes: [Recipe], forceRefresh: Bool) async throws -> [UnifiedSuggestion] {
        guard recipes.count >= minimumRecipeCount else {
            return []
        }

        var collectionSuggestions: [UnifiedSuggestion] = []
        var aiGeneratedSuggestions: [UnifiedSuggestion] = []
        var collectionError: Error?
        var generationError: Error?

        // Fetch collection suggestions (all users with 10+ recipes)
        do {
            let suggestions = try await suggestionEngine.getSuggestions(recipes: recipes, forceRefresh: forceRefresh)
            collectionSuggestions = suggestions.map { .fromCollection($0) }
        } catch {
            collectionError = error
        }

        // Fetch AI-generated recipes (premium only)
        if isPremiumProvider() {
            do {
                let generated = try await generationService.getGeneratedRecipes(recipes: recipes, forceRefresh: forceRefresh)
                aiGeneratedSuggestions = generated.prefix(2).map { recipe in
                    .aiGenerated(recipe, reason: buildReason(for: recipe))
                }
            } catch {
                generationError = error
            }
        }

        // Handle graceful degradation
        if collectionError != nil && generationError != nil {
            throw collectionError!
        }

        // Collection suggestions first, then AI-generated
        return collectionSuggestions + aiGeneratedSuggestions
    }

    private func buildReason(for recipe: GeneratedRecipe) -> String {
        if let cuisine = recipe.cuisine {
            return "Made for you • \(cuisine)"
        }
        return "Made for you"
    }
}
