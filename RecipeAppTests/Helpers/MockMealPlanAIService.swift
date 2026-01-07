import Foundation
@testable import RecipeApp

@MainActor
class MockMealPlanAIService: MealPlanAIService {
    var shouldThrowError = false
    var mockInsights: [MealPlanInsight] = []
    var reviewPlanCallCount = 0
    var lastEntries: [MealPlanEntry]?
    var lastRecipes: [Recipe]?

    override func reviewPlan(entries: [MealPlanEntry], recipes: [Recipe]) async throws -> [MealPlanInsight] {
        reviewPlanCallCount += 1
        lastEntries = entries
        lastRecipes = recipes

        if shouldThrowError {
            throw MealPlanAIError.parsingFailed
        }
        return mockInsights
    }

    func reset() {
        shouldThrowError = false
        mockInsights = []
        reviewPlanCallCount = 0
        lastEntries = nil
        lastRecipes = nil
    }
}
