import Testing
import Foundation
@testable import RecipeApp

@Suite("MealPlanAIModels Tests")
@MainActor
struct MealPlanAIModelsTests {

    // MARK: - MealPlanSuggestionType

    @Test("SuggestionType has correct raw values")
    func suggestionTypeRawValues() {
        #expect(MealPlanSuggestionType.swap.rawValue == "swap")
        #expect(MealPlanSuggestionType.add.rawValue == "add")
        #expect(MealPlanSuggestionType.varietyAlert.rawValue == "varietyAlert")
    }

    @Test("SuggestionType is Codable")
    func suggestionTypeCodable() throws {
        let original = MealPlanSuggestionType.swap
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MealPlanSuggestionType.self, from: encoded)
        #expect(decoded == original)
    }

    @Test("SuggestionType has all cases")
    func suggestionTypeAllCases() {
        #expect(MealPlanSuggestionType.allCases.count == 3)
    }

    // MARK: - MealPlanAssignment

    @Test("Assignment decodes from JSON")
    func assignmentDecodesFromJSON() throws {
        let json = """
        {"dayOffset": 2, "recipeID": "550e8400-e29b-41d4-a716-446655440000"}
        """
        let data = json.data(using: .utf8)!
        let assignment = try JSONDecoder().decode(MealPlanAssignment.self, from: data)

        #expect(assignment.dayOffset == 2)
        #expect(assignment.recipeID == "550e8400-e29b-41d4-a716-446655440000")
    }

    @Test("Assignment decodes array from JSON")
    func assignmentDecodesArrayFromJSON() throws {
        let json = """
        [
            {"dayOffset": 0, "recipeID": "550e8400-e29b-41d4-a716-446655440000"},
            {"dayOffset": 1, "recipeID": "550e8400-e29b-41d4-a716-446655440001"},
            {"dayOffset": 3, "recipeID": "550e8400-e29b-41d4-a716-446655440002"}
        ]
        """
        let data = json.data(using: .utf8)!
        let assignments = try JSONDecoder().decode([MealPlanAssignment].self, from: data)

        #expect(assignments.count == 3)
        #expect(assignments[0].dayOffset == 0)
        #expect(assignments[1].dayOffset == 1)
        #expect(assignments[2].dayOffset == 3)
    }

    // MARK: - MealPlanInsightResponse

    @Test("InsightResponse decodes from JSON with all fields")
    func insightResponseDecodesAllFields() throws {
        let json = """
        {
            "insight": "You have 3 Italian dishes this week",
            "recommendation": "Consider adding variety with Thai or Mexican",
            "suggestedRecipeID": "550e8400-e29b-41d4-a716-446655440000",
            "suggestionType": "swap",
            "targetDayOffset": 2,
            "targetMealType": "dinner"
        }
        """
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(MealPlanInsightResponse.self, from: data)

        #expect(response.insight == "You have 3 Italian dishes this week")
        #expect(response.recommendation == "Consider adding variety with Thai or Mexican")
        #expect(response.suggestedRecipeID == "550e8400-e29b-41d4-a716-446655440000")
        #expect(response.suggestionType == "swap")
        #expect(response.targetDayOffset == 2)
        #expect(response.targetMealType == "dinner")
    }

    @Test("InsightResponse decodes with optional fields as nil")
    func insightResponseDecodesOptionalNil() throws {
        let json = """
        {
            "insight": "Your week looks pasta-heavy",
            "recommendation": "Mix it up with different cuisines",
            "suggestedRecipeID": null,
            "suggestionType": "varietyAlert",
            "targetDayOffset": null,
            "targetMealType": null
        }
        """
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(MealPlanInsightResponse.self, from: data)

        #expect(response.insight == "Your week looks pasta-heavy")
        #expect(response.suggestedRecipeID == nil)
        #expect(response.suggestionType == "varietyAlert")
        #expect(response.targetDayOffset == nil)
        #expect(response.targetMealType == nil)
    }

    @Test("InsightResponse decodes array from JSON")
    func insightResponseDecodesArray() throws {
        let json = """
        [
            {
                "insight": "Friday dinner is empty",
                "recommendation": "Try Thai Green Curry",
                "suggestedRecipeID": "550e8400-e29b-41d4-a716-446655440000",
                "suggestionType": "add",
                "targetDayOffset": 4,
                "targetMealType": "dinner"
            },
            {
                "insight": "Too much Italian",
                "recommendation": "Add variety",
                "suggestedRecipeID": null,
                "suggestionType": "varietyAlert",
                "targetDayOffset": null,
                "targetMealType": null
            }
        ]
        """
        let data = json.data(using: .utf8)!
        let responses = try JSONDecoder().decode([MealPlanInsightResponse].self, from: data)

        #expect(responses.count == 2)
        #expect(responses[0].suggestionType == "add")
        #expect(responses[1].suggestionType == "varietyAlert")
    }

    // MARK: - MealPlanGenerationResult

    @Test("GenerationResult equality compares date and recipe ID")
    func generationResultEquality() {
        let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe")
        let date = Date()

        let result1 = MealPlanGenerationResult(date: date, recipe: recipe)
        let result2 = MealPlanGenerationResult(date: date, recipe: recipe)

        #expect(result1 == result2)
    }

    @Test("GenerationResult inequality with different dates")
    func generationResultInequalityDifferentDates() {
        let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe")
        let date1 = Date()
        let date2 = Calendar.current.date(byAdding: .day, value: 1, to: date1)!

        let result1 = MealPlanGenerationResult(date: date1, recipe: recipe)
        let result2 = MealPlanGenerationResult(date: date2, recipe: recipe)

        #expect(result1 != result2)
    }

    @Test("GenerationResult inequality with different recipes")
    func generationResultInequalityDifferentRecipes() {
        let recipe1 = RecipeTestFixtures.createRecipe(title: "Recipe 1")
        let recipe2 = RecipeTestFixtures.createRecipe(title: "Recipe 2")
        let date = Date()

        let result1 = MealPlanGenerationResult(date: date, recipe: recipe1)
        let result2 = MealPlanGenerationResult(date: date, recipe: recipe2)

        #expect(result1 != result2)
    }

    // MARK: - MealPlanInsight

    @Test("Insight generates unique ID on init")
    func insightGeneratesUniqueID() {
        let insight1 = MealPlanInsight(
            insight: "Test",
            recommendation: "Test",
            suggestionType: .add
        )
        let insight2 = MealPlanInsight(
            insight: "Test",
            recommendation: "Test",
            suggestionType: .add
        )

        #expect(insight1.id != insight2.id)
    }

    @Test("Insight equality compares all properties")
    func insightEqualityAllProperties() {
        let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe")
        let date = Date()

        let insight1 = MealPlanInsight(
            insight: "Friday is empty",
            recommendation: "Add Thai Green Curry",
            suggestedRecipe: recipe,
            suggestionType: .add,
            targetDate: date,
            targetMealType: .dinner
        )

        let insight2 = MealPlanInsight(
            insight: "Friday is empty",
            recommendation: "Add Thai Green Curry",
            suggestedRecipe: recipe,
            suggestionType: .add,
            targetDate: date,
            targetMealType: .dinner
        )

        #expect(insight1 != insight2)
    }

    @Test("Insight equality handles nil suggestedRecipe")
    func insightEqualityNilRecipe() {
        let insight1 = MealPlanInsight(
            insight: "Too much pasta",
            recommendation: "Add variety",
            suggestedRecipe: nil,
            suggestionType: .varietyAlert,
            targetDate: nil,
            targetMealType: nil
        )
        let insight2 = MealPlanInsight(
            insight: "Too much pasta",
            recommendation: "Add variety",
            suggestedRecipe: nil,
            suggestionType: .varietyAlert,
            targetDate: nil,
            targetMealType: nil
        )

        #expect(insight1 != insight2)
    }

    @Test("Insight stores all properties correctly")
    func insightStoresProperties() {
        let recipe = RecipeTestFixtures.createRecipe(title: "Thai Curry")
        let date = Date()

        let insight = MealPlanInsight(
            insight: "Empty slot detected",
            recommendation: "Try this recipe",
            suggestedRecipe: recipe,
            suggestionType: .add,
            targetDate: date,
            targetMealType: .dinner
        )

        #expect(insight.insight == "Empty slot detected")
        #expect(insight.recommendation == "Try this recipe")
        #expect(insight.suggestedRecipe?.title == "Thai Curry")
        #expect(insight.suggestionType == .add)
        #expect(insight.targetDate == date)
        #expect(insight.targetMealType == .dinner)
    }

    @Test("Insight default values for optional properties")
    func insightDefaultOptionals() {
        let insight = MealPlanInsight(
            insight: "Pattern detected",
            recommendation: "Consider variety",
            suggestionType: .varietyAlert
        )

        #expect(insight.suggestedRecipe == nil)
        #expect(insight.targetDate == nil)
        #expect(insight.targetMealType == nil)
    }
}
