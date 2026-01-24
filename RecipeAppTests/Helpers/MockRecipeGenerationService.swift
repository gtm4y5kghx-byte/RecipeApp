import Foundation
@testable import RecipeApp

@MainActor
class MockRecipeGenerationService: RecipeGenerating {
    var mockGeneratedRecipes: [GeneratedRecipe] = []
    var shouldThrowError = false
    var mockError: Error = AIError.apiError("Mock error")
    var getGeneratedRecipesCallCount = 0
    var lastRecipes: [Recipe]?
    var lastForceRefresh: Bool?

    func getGeneratedRecipes(recipes: [Recipe]) async throws -> [GeneratedRecipe] {
        try await getGeneratedRecipes(recipes: recipes, forceRefresh: false)
    }

    func getGeneratedRecipes(recipes: [Recipe], forceRefresh: Bool) async throws -> [GeneratedRecipe] {
        getGeneratedRecipesCallCount += 1
        lastRecipes = recipes
        lastForceRefresh = forceRefresh

        if shouldThrowError {
            throw mockError
        }
        return mockGeneratedRecipes
    }

    func reset() {
        mockGeneratedRecipes = []
        shouldThrowError = false
        mockError = AIError.apiError("Mock error")
        getGeneratedRecipesCallCount = 0
        lastRecipes = nil
        lastForceRefresh = nil
    }
}
