import Foundation
@testable import RecipeApp

@MainActor
class MockMealPlanAIService: MealPlanAIService {
    var shouldThrowError = false

    // Generate Plan
    var mockResults: [MealPlanGenerationResult] = []
    var generatePlanCallCount = 0
    var lastMealType: MealType?
    var lastDayCount: Int?
    var lastRecipes: [Recipe]?

    override func generatePlan(
        for mealType: MealType?,
        recipes: [Recipe],
        dayCount: Int = 7
    ) async throws -> [MealPlanGenerationResult] {
        generatePlanCallCount += 1
        lastMealType = mealType
        lastRecipes = recipes
        lastDayCount = dayCount

        if shouldThrowError {
            throw AIError.parsingFailed
        }
        return mockResults
    }

    func reset() {
        shouldThrowError = false
        mockResults = []
        generatePlanCallCount = 0
        lastMealType = nil
        lastDayCount = nil
        lastRecipes = nil
    }
}
