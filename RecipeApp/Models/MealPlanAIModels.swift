import Foundation

// MARK: - Claude Response Models (internal)

struct MealPlanAssignment: Codable {
    let dayOffset: Int
    let recipeID: String
}

// MARK: - Public Result Types

struct MealPlanGenerationResult: Equatable, Identifiable {
    let date: Date
    let recipe: Recipe

    var id: UUID { recipe.id }

    var dayOfWeek: String {
        date.formatted(.dateTime.weekday(.abbreviated))
    }

    var dayNumber: String {
        date.formatted(.dateTime.day())
    }

    static func == (lhs: MealPlanGenerationResult, rhs: MealPlanGenerationResult) -> Bool {
        lhs.date == rhs.date && lhs.recipe.id == rhs.recipe.id
    }
}
