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

    func testCreatedAtDefaultsToNow() {
        let beforeCreation = Date()
        let recipe = Recipe(title: "Test Recipe", sourceType: .manual)
        let afterCreation = Date()

        // createdAt should be between before and after
        XCTAssertTrue(recipe.createdAt >= beforeCreation)
        XCTAssertTrue(recipe.createdAt <= afterCreation)
    }

    func testUpdatedAtDefaultsToNow() {
        let beforeCreation = Date()
        let recipe = Recipe(title: "Test Recipe", sourceType: .manual)
        let afterCreation = Date()

        // updatedAt should be between before and after
        XCTAssertTrue(recipe.updatedAt >= beforeCreation)
        XCTAssertTrue(recipe.updatedAt <= afterCreation)
    }

    func testRecipesSortByCreatedAtDescending() {
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: now)!

        let oldRecipe = Recipe(title: "Old Recipe", sourceType: .manual)
        oldRecipe.createdAt = lastWeek

        let middleRecipe = Recipe(title: "Middle Recipe", sourceType: .manual)
        middleRecipe.createdAt = yesterday

        let newRecipe = Recipe(title: "New Recipe", sourceType: .manual)
        newRecipe.createdAt = now

        let recipes = [oldRecipe, middleRecipe, newRecipe]
        let sorted = recipes.sorted { $0.createdAt > $1.createdAt }

        XCTAssertEqual(sorted[0].title, "New Recipe")
        XCTAssertEqual(sorted[1].title, "Middle Recipe")
        XCTAssertEqual(sorted[2].title, "Old Recipe")
    }
    
    func testRecipesImage() {
        let recipe = Recipe(title: "Test Recipe", sourceType: .manual)

        XCTAssertNil(recipe.imageURL)

        recipe.imageURL = "https://placehold.co/400x300"
        XCTAssertEqual(recipe.imageURL, "https://placehold.co/400x300")

        recipe.imageURL = "https://example.com/recipe.jpg"
        XCTAssertEqual(recipe.imageURL, "https://example.com/recipe.jpg")

        recipe.imageURL = nil
        XCTAssertNil(recipe.imageURL)
    }
}
