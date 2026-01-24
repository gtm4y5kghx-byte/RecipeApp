import Foundation
@testable import RecipeApp

@MainActor
class MockAISuggestionEngineService: AISuggestionProviding {
    var mockSuggestions: [RecipeSuggestion] = []
    var shouldThrowError = false
    var mockError: Error = AIError.apiError("Mock error")
    var getSuggestionsCallCount = 0
    var lastRecipes: [Recipe]?
    var lastForceRefresh: Bool?

    func getSuggestions(recipes: [Recipe], forceRefresh: Bool) async throws -> [RecipeSuggestion] {
        getSuggestionsCallCount += 1
        lastRecipes = recipes
        lastForceRefresh = forceRefresh

        if shouldThrowError {
            throw mockError
        }
        return mockSuggestions
    }

    func reset() {
        mockSuggestions = []
        shouldThrowError = false
        mockError = AIError.apiError("Mock error")
        getSuggestionsCallCount = 0
        lastRecipes = nil
        lastForceRefresh = nil
    }
}
