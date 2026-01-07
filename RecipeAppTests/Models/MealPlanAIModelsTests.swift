import Testing
import Foundation
@testable import RecipeApp

@Suite("MealPlanAIModels Tests")
@MainActor
struct MealPlanAIModelsTests {

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
}
