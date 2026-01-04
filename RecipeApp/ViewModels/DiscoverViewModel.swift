import Foundation
import SwiftData

@MainActor
@Observable
class DiscoverViewModel {
    var generatedRecipes: [GeneratedRecipe] = []
    var isLoading: Bool = false
    var error: Error?

    private let recipes: [Recipe]
    private let modelContext: ModelContext
    private let generationService: RecipeGenerating

    init(
        recipes: [Recipe],
        modelContext: ModelContext,
        generationService: RecipeGenerating
    ) {
        self.recipes = recipes
        self.modelContext = modelContext
        self.generationService = generationService
    }

    // MARK: - Computed Properties

    var isPremium: Bool {
        UserSubscriptionService.shared.isPremium
    }

    var canGenerate: Bool {
        isPremium
    }

    // MARK: - Methods

    func loadGeneratedRecipes() async {
        guard canGenerate else { return }

        isLoading = true
        error = nil

        do {
            generatedRecipes = try await generationService.getGeneratedRecipes(recipes: recipes)
        } catch {
            self.error = error
            generatedRecipes = []
        }

        isLoading = false
    }

    func saveToCollection(_ recipe: GeneratedRecipe) {
        let newRecipe = recipe.toRecipe()
        modelContext.insert(newRecipe)

        do {
            try modelContext.save()
            generatedRecipes.removeAll { $0.id == recipe.id }
        } catch {
            self.error = error
        }
    }
}
