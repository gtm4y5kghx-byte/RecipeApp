import Testing
import Foundation
@testable import RecipeApp

@Suite("UnifiedSuggestionService Tests")
@MainActor
struct UnifiedSuggestionServiceTests {

    // MARK: - Recipe Count Threshold Tests

    @Test("Returns empty when fewer than 10 recipes")
    func emptyWhenBelowThreshold() async throws {
        let mockSuggestionEngine = MockAISuggestionEngineService()
        let mockGenerationService = MockRecipeGenerationService()
        let service = createService(
            suggestionEngine: mockSuggestionEngine,
            generationService: mockGenerationService,
            isPremium: false
        )

        let recipes = createRecipes(count: 9)
        let suggestions = try await service.getUnifiedSuggestions(recipes: recipes, forceRefresh: false)

        #expect(suggestions.isEmpty)
        #expect(mockSuggestionEngine.getSuggestionsCallCount == 0)
        #expect(mockGenerationService.getGeneratedRecipesCallCount == 0)
    }

    @Test("Returns suggestions when exactly 10 recipes")
    func suggestionsAtThreshold() async throws {
        let mockSuggestionEngine = MockAISuggestionEngineService()
        mockSuggestionEngine.mockSuggestions = [
            RecipeTestFixtures.createRecipeSuggestion(recipeID: UUID(), reason: "Try again")
        ]
        let mockGenerationService = MockRecipeGenerationService()
        let service = createService(
            suggestionEngine: mockSuggestionEngine,
            generationService: mockGenerationService,
            isPremium: false
        )

        let recipes = createRecipes(count: 10)
        let suggestions = try await service.getUnifiedSuggestions(recipes: recipes, forceRefresh: false)

        #expect(!suggestions.isEmpty)
        #expect(mockSuggestionEngine.getSuggestionsCallCount == 1)
    }

    // MARK: - Free User Tests

    @Test("Free user gets only collection suggestions")
    func freeUserCollectionOnly() async throws {
        let mockSuggestionEngine = MockAISuggestionEngineService()
        mockSuggestionEngine.mockSuggestions = [
            RecipeTestFixtures.createRecipeSuggestion(recipeID: UUID(), reason: "Reason 1"),
            RecipeTestFixtures.createRecipeSuggestion(recipeID: UUID(), reason: "Reason 2"),
            RecipeTestFixtures.createRecipeSuggestion(recipeID: UUID(), reason: "Reason 3")
        ]
        let mockGenerationService = MockRecipeGenerationService()
        mockGenerationService.mockGeneratedRecipes = [
            RecipeTestFixtures.createGeneratedRecipe(title: "AI Recipe")
        ]
        let service = createService(
            suggestionEngine: mockSuggestionEngine,
            generationService: mockGenerationService,
            isPremium: false
        )

        let recipes = createRecipes(count: 15)
        let suggestions = try await service.getUnifiedSuggestions(recipes: recipes, forceRefresh: false)

        #expect(suggestions.count == 3)
        #expect(suggestions.allSatisfy { !$0.isAIGenerated })
        #expect(mockGenerationService.getGeneratedRecipesCallCount == 0)
    }

    // MARK: - Premium User Tests

    @Test("Premium user gets both collection and AI-generated suggestions")
    func premiumUserGetsBoth() async throws {
        let mockSuggestionEngine = MockAISuggestionEngineService()
        mockSuggestionEngine.mockSuggestions = [
            RecipeTestFixtures.createRecipeSuggestion(recipeID: UUID(), reason: "Collection 1"),
            RecipeTestFixtures.createRecipeSuggestion(recipeID: UUID(), reason: "Collection 2"),
            RecipeTestFixtures.createRecipeSuggestion(recipeID: UUID(), reason: "Collection 3")
        ]
        let mockGenerationService = MockRecipeGenerationService()
        mockGenerationService.mockGeneratedRecipes = [
            RecipeTestFixtures.createGeneratedRecipe(title: "AI Recipe 1"),
            RecipeTestFixtures.createGeneratedRecipe(title: "AI Recipe 2")
        ]
        let service = createService(
            suggestionEngine: mockSuggestionEngine,
            generationService: mockGenerationService,
            isPremium: true
        )

        let recipes = createRecipes(count: 15)
        let suggestions = try await service.getUnifiedSuggestions(recipes: recipes, forceRefresh: false)

        let collectionSuggestions = suggestions.filter { !$0.isAIGenerated }
        let aiSuggestions = suggestions.filter { $0.isAIGenerated }

        #expect(collectionSuggestions.count == 3)
        #expect(aiSuggestions.count == 2)
        #expect(suggestions.count == 5)
    }

    @Test("Premium user: collection suggestions come first in ordering")
    func orderingCollectionFirst() async throws {
        let mockSuggestionEngine = MockAISuggestionEngineService()
        mockSuggestionEngine.mockSuggestions = [
            RecipeTestFixtures.createRecipeSuggestion(recipeID: UUID(), reason: "Collection")
        ]
        let mockGenerationService = MockRecipeGenerationService()
        mockGenerationService.mockGeneratedRecipes = [
            RecipeTestFixtures.createGeneratedRecipe(title: "AI Recipe")
        ]
        let service = createService(
            suggestionEngine: mockSuggestionEngine,
            generationService: mockGenerationService,
            isPremium: true
        )

        let recipes = createRecipes(count: 15)
        let suggestions = try await service.getUnifiedSuggestions(recipes: recipes, forceRefresh: false)

        #expect(suggestions.first?.isAIGenerated == false)
        #expect(suggestions.last?.isAIGenerated == true)
    }

    // MARK: - Graceful Degradation Tests

    @Test("Returns AI-generated only when collection suggestions fail")
    func gracefulDegradationCollectionFails() async throws {
        let mockSuggestionEngine = MockAISuggestionEngineService()
        mockSuggestionEngine.shouldThrowError = true
        let mockGenerationService = MockRecipeGenerationService()
        mockGenerationService.mockGeneratedRecipes = [
            RecipeTestFixtures.createGeneratedRecipe(title: "AI Recipe 1"),
            RecipeTestFixtures.createGeneratedRecipe(title: "AI Recipe 2")
        ]
        let service = createService(
            suggestionEngine: mockSuggestionEngine,
            generationService: mockGenerationService,
            isPremium: true
        )

        let recipes = createRecipes(count: 15)
        let suggestions = try await service.getUnifiedSuggestions(recipes: recipes, forceRefresh: false)

        #expect(suggestions.count == 2)
        #expect(suggestions.allSatisfy { $0.isAIGenerated })
    }

    @Test("Returns collection only when AI generation fails")
    func gracefulDegradationAIFails() async throws {
        let mockSuggestionEngine = MockAISuggestionEngineService()
        mockSuggestionEngine.mockSuggestions = [
            RecipeTestFixtures.createRecipeSuggestion(recipeID: UUID(), reason: "Collection 1"),
            RecipeTestFixtures.createRecipeSuggestion(recipeID: UUID(), reason: "Collection 2"),
            RecipeTestFixtures.createRecipeSuggestion(recipeID: UUID(), reason: "Collection 3")
        ]
        let mockGenerationService = MockRecipeGenerationService()
        mockGenerationService.shouldThrowError = true
        let service = createService(
            suggestionEngine: mockSuggestionEngine,
            generationService: mockGenerationService,
            isPremium: true
        )

        let recipes = createRecipes(count: 15)
        let suggestions = try await service.getUnifiedSuggestions(recipes: recipes, forceRefresh: false)

        #expect(suggestions.count == 3)
        #expect(suggestions.allSatisfy { !$0.isAIGenerated })
    }

    @Test("Throws when both services fail")
    func throwsWhenBothFail() async throws {
        let mockSuggestionEngine = MockAISuggestionEngineService()
        mockSuggestionEngine.shouldThrowError = true
        let mockGenerationService = MockRecipeGenerationService()
        mockGenerationService.shouldThrowError = true
        let service = createService(
            suggestionEngine: mockSuggestionEngine,
            generationService: mockGenerationService,
            isPremium: true
        )

        let recipes = createRecipes(count: 15)

        await #expect(throws: Error.self) {
            _ = try await service.getUnifiedSuggestions(recipes: recipes, forceRefresh: false)
        }
    }

    // MARK: - ForceRefresh Tests

    @Test("ForceRefresh is passed to underlying services")
    func forceRefreshPassed() async throws {
        let mockSuggestionEngine = MockAISuggestionEngineService()
        mockSuggestionEngine.mockSuggestions = [
            RecipeTestFixtures.createRecipeSuggestion(recipeID: UUID(), reason: "Test")
        ]
        let mockGenerationService = MockRecipeGenerationService()
        mockGenerationService.mockGeneratedRecipes = [
            RecipeTestFixtures.createGeneratedRecipe(title: "Test")
        ]
        let service = createService(
            suggestionEngine: mockSuggestionEngine,
            generationService: mockGenerationService,
            isPremium: true
        )

        let recipes = createRecipes(count: 15)
        _ = try await service.getUnifiedSuggestions(recipes: recipes, forceRefresh: true)

        #expect(mockSuggestionEngine.lastForceRefresh == true)
    }

    // MARK: - AI Generated Reason Tests

    @Test("AI-generated suggestions have personalized reason")
    func aiGeneratedHasReason() async throws {
        let mockSuggestionEngine = MockAISuggestionEngineService()
        let mockGenerationService = MockRecipeGenerationService()
        mockGenerationService.mockGeneratedRecipes = [
            RecipeTestFixtures.createGeneratedRecipe(title: "Pasta Dish", cuisine: "Italian")
        ]
        let service = createService(
            suggestionEngine: mockSuggestionEngine,
            generationService: mockGenerationService,
            isPremium: true
        )

        let recipes = createRecipes(count: 15)
        let suggestions = try await service.getUnifiedSuggestions(recipes: recipes, forceRefresh: false)

        let aiSuggestion = suggestions.first { $0.isAIGenerated }
        #expect(aiSuggestion != nil)
        #expect(!aiSuggestion!.reason.isEmpty)
    }

    // MARK: - Test Helpers

    private func createService(
        suggestionEngine: AISuggestionProviding,
        generationService: RecipeGenerating,
        isPremium: Bool
    ) -> UnifiedSuggestionService {
        UnifiedSuggestionService(
            suggestionEngine: suggestionEngine,
            generationService: generationService,
            isPremiumProvider: { isPremium }
        )
    }

    private func createRecipes(count: Int) -> [Recipe] {
        (0..<count).map { index in
            RecipeTestFixtures.createRecipe(title: "Recipe \(index)")
        }
    }
}
