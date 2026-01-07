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

    // Review Plan
    var mockInsights: [MealPlanInsight] = []
    var reviewPlanCallCount = 0
    var lastEntries: [MealPlanEntry]?
    var lastRecipes: [Recipe]?

    override func generatePlan(
        for mealType: MealType,
        recipes: [Recipe],
        dayCount: Int = 7
    ) async throws -> [MealPlanGenerationResult] {
        generatePlanCallCount += 1
        lastMealType = mealType
        lastRecipes = recipes
        lastDayCount = dayCount

        if shouldThrowError {
            throw MealPlanAIError.parsingFailed
        }
        return mockResults
    }

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
        mockResults = []
        generatePlanCallCount = 0
        lastMealType = nil
        lastDayCount = nil
        mockInsights = []
        reviewPlanCallCount = 0
        lastEntries = nil
        lastRecipes = nil
    }
}
