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

        XCTAssertNil(recipe.totalTime)
    }

    func testTotalTimeWithOnlyCookTime() {
        let recipe = Recipe(title: "Test Recipe", sourceType: .manual)
        recipe.prepTime = nil
        recipe.cookTime = 30

        XCTAssertNil(recipe.totalTime)
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
}
