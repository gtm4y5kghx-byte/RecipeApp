import XCTest
import SwiftData
@testable import RecipeApp

final class RecipeTests: XCTestCase {

    func testTotalTimeWithBothPrepAndCook() {
        let recipe = Recipe(title: "Test Recipe", sourceType: .manual)
        recipe.prepTime = 15
        recipe.cookTime = 30

        XCTAssertEqual(recipe.totalTime, 45)
    }

    func testTotalTimeWithOnlyPrepTime() {
        let recipe = Recipe(title: "Test Recipe", sourceType: .manual)
        recipe.prepTime = 15
        recipe.cookTime = nil

        XCTAssertEqual(recipe.totalTime, 15)
    }

    func testTotalTimeWithOnlyCookTime() {
        let recipe = Recipe(title: "Test Recipe", sourceType: .manual)
        recipe.prepTime = nil
        recipe.cookTime = 30

        XCTAssertEqual(recipe.totalTime, 30)
    }

    func testTotalTimeWithNeither() {
        let recipe = Recipe(title: "Test Recipe", sourceType: .manual)
        recipe.prepTime = nil
        recipe.cookTime = nil

        XCTAssertNil(recipe.totalTime)
    }

    func testCanStartCookingWithIngredientsAndInstructions() {
        let recipe = Recipe(title: "Test Recipe", sourceType: .manual)

        let ingredient = Ingredient(quantity: "1", unit: "cup", item: "flour", preparation: nil, section: nil)
        recipe.ingredients.append(ingredient)

        let step = Step(instruction: "Mix ingredients")
        recipe.instructions.append(step)

        XCTAssertTrue(recipe.canStartCooking)
    }

    func testCanStartCookingWithNoIngredients() {
        let recipe = Recipe(title: "Test Recipe", sourceType: .manual)

        let step = Step(instruction: "Mix ingredients")
        recipe.instructions.append(step)

        XCTAssertFalse(recipe.canStartCooking)
    }

    func testCanStartCookingWithNoInstructions() {
        let recipe = Recipe(title: "Test Recipe", sourceType: .manual)

        let ingredient = Ingredient(quantity: "1", unit: "cup", item: "flour", preparation: nil, section: nil)
        recipe.ingredients.append(ingredient)

        XCTAssertFalse(recipe.canStartCooking)
    }

    func testCanStartCookingWithNeither() {
        let recipe = Recipe(title: "Test Recipe", sourceType: .manual)

        XCTAssertFalse(recipe.canStartCooking)
    }

    func testNutritionRelationship() {
        let recipe = Recipe(title: "Test Recipe", sourceType: .manual)

        XCTAssertNil(recipe.nutrition)

        let nutrition = NutritionInfo(
            calories: 450,
            carbohydrates: 50.0,
            protein: 20.0,
            fat: 15.0,
            fiber: 5.0,
            sodium: 600.0,
            sugar: 8.0
        )
        recipe.nutrition = nutrition

        XCTAssertNotNil(recipe.nutrition)
        XCTAssertEqual(recipe.nutrition?.calories, 450)
        XCTAssertEqual(recipe.nutrition?.carbohydrates, 50.0)
        XCTAssertEqual(recipe.nutrition?.protein, 20.0)
        XCTAssertEqual(recipe.nutrition?.fat, 15.0)
        XCTAssertEqual(recipe.nutrition?.fiber, 5.0)
        XCTAssertEqual(recipe.nutrition?.sodium, 600.0)
        XCTAssertEqual(recipe.nutrition?.sugar, 8.0)
    }
}
