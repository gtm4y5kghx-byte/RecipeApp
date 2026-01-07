import Foundation

// MARK: - Claude Response Models (internal)

struct MealPlanAssignment: Codable {
    let dayOffset: Int
    let recipeID: String
}

// MARK: - Public Result Types

struct MealPlanGenerationResult: Equatable {
    let date: Date
    let recipe: Recipe

    static func == (lhs: MealPlanGenerationResult, rhs: MealPlanGenerationResult) -> Bool {
        lhs.date == rhs.date && lhs.recipe.id == rhs.recipe.id
    }
}
