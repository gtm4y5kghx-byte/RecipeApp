import Foundation

// MARK: - Suggestion Type

enum MealPlanSuggestionType: String, Codable, CaseIterable {
    case swap
    case add
    case varietyAlert
}

// MARK: - Claude Response Models (internal)

struct MealPlanAssignment: Codable {
    let dayOffset: Int
    let recipeID: String
}

struct MealPlanInsightResponse: Codable {
    let insight: String
    let recommendation: String
    let suggestedRecipeID: String?
    let suggestionType: String
    let targetDayOffset: Int?
    let targetMealType: String?
}

// MARK: - Public Result Types

struct MealPlanGenerationResult: Equatable {
    let date: Date
    let recipe: Recipe

    static func == (lhs: MealPlanGenerationResult, rhs: MealPlanGenerationResult) -> Bool {
        lhs.date == rhs.date && lhs.recipe.id == rhs.recipe.id
    }
}

struct MealPlanInsight: Identifiable, Equatable {
    let id: UUID
    let insight: String
    let recommendation: String
    let suggestedRecipe: Recipe?
    let suggestionType: MealPlanSuggestionType
    let targetDate: Date?
    let targetMealType: MealType?

    init(
        insight: String,
        recommendation: String,
        suggestedRecipe: Recipe? = nil,
        suggestionType: MealPlanSuggestionType,
        targetDate: Date? = nil,
        targetMealType: MealType? = nil
    ) {
        self.id = UUID()
        self.insight = insight
        self.recommendation = recommendation
        self.suggestedRecipe = suggestedRecipe
        self.suggestionType = suggestionType
        self.targetDate = targetDate
        self.targetMealType = targetMealType
    }

    static func == (lhs: MealPlanInsight, rhs: MealPlanInsight) -> Bool {
        lhs.id == rhs.id &&
        lhs.insight == rhs.insight &&
        lhs.recommendation == rhs.recommendation &&
        lhs.suggestedRecipe?.id == rhs.suggestedRecipe?.id &&
        lhs.suggestionType == rhs.suggestionType &&
        lhs.targetDate == rhs.targetDate &&
        lhs.targetMealType == rhs.targetMealType
    }
}
