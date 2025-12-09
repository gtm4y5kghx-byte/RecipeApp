import XCTest
@testable import RecipeApp

final class DiscoveredRecipeTests: XCTestCase {

    func testToRecipeBasicInfo() {
        let discovered = DiscoveredRecipe(
            id: 123,
            title: "Pasta Carbonara",
            image: nil,
            imageType: nil,
            servings: 4,
            readyInMinutes: 30,
            sourceUrl: "https://example.com/recipe",
            sourceName: "Test Source",
            cuisines: ["Italian"],
            dishTypes: nil,
            vegetarian: nil,
            vegan: nil,
            glutenFree: nil,
            extendedIngredients: nil,
            analyzedInstructions: nil,
            nutrition: nil
        )

        let recipe = discovered.toRecipe()

        XCTAssertEqual(recipe.title, "Pasta Carbonara")
        XCTAssertEqual(recipe.servings, 4)
        XCTAssertEqual(recipe.cookTime, 30)
        XCTAssertEqual(recipe.cuisine, "Italian")
        XCTAssertEqual(recipe.sourceURL, "https://example.com/recipe")
        XCTAssertEqual(recipe.notes, "Imported from Test Source")
        XCTAssertEqual(recipe.sourceType, .web_imported)
    }

    func testToRecipeWithIngredients() {
        let discovered = DiscoveredRecipe(
            id: 123,
            title: "Pasta Carbonara",
            image: nil,
            imageType: nil,
            servings: 4,
            readyInMinutes: 30,
            sourceUrl: nil,
            sourceName: nil,
            cuisines: nil,
            dishTypes: nil,
            vegetarian: nil,
            vegan: nil,
            glutenFree: nil,
            extendedIngredients: [
                SpoonacularIngredient(
                    id: 1,
                    name: "pasta",
                    original: "1 lb pasta",
                    measures: SpoonacularMeasures(
                        us: SpoonacularMeasure(amount: 1, unitShort: "lb", unitLong: "pound"),
                        metric: SpoonacularMeasure(amount: 453, unitShort: "g", unitLong: "grams")
                    )
                ),
                SpoonacularIngredient(
                    id: 2,
                    name: "eggs",
                    original: "2 eggs",
                    measures: SpoonacularMeasures(
                        us: SpoonacularMeasure(amount: 2, unitShort: "", unitLong: ""),
                        metric: SpoonacularMeasure(amount: 2, unitShort: "", unitLong: "")
                    )
                )
            ],
            analyzedInstructions: nil,
            nutrition: nil
        )

        let recipe = discovered.toRecipe()

        XCTAssertEqual(recipe.ingredients.count, 2)
        XCTAssertEqual(recipe.ingredients[0].item, "pasta")
        XCTAssertEqual(recipe.ingredients[0].quantity, "1.0")
        XCTAssertEqual(recipe.ingredients[0].unit, "pound")
        XCTAssertEqual(recipe.ingredients[0].order, 0)

        XCTAssertEqual(recipe.ingredients[1].item, "eggs")
        XCTAssertEqual(recipe.ingredients[1].quantity, "2.0")
        XCTAssertNil(recipe.ingredients[1].unit)
        XCTAssertEqual(recipe.ingredients[1].order, 1)
    }

    func testToRecipeWithInstructions() {
        let discovered = DiscoveredRecipe(
            id: 123,
            title: "Pasta Carbonara",
            image: nil,
            imageType: nil,
            servings: nil,
            readyInMinutes: nil,
            sourceUrl: nil,
            sourceName: nil,
            cuisines: nil,
            dishTypes: nil,
            vegetarian: nil,
            vegan: nil,
            glutenFree: nil,
            extendedIngredients: nil,
            analyzedInstructions: [
                SpoonacularInstruction(
                    name: nil,
                    steps: [
                        SpoonacularStep(number: 1, step: "Boil pasta"),
                        SpoonacularStep(number: 2, step: "Cook bacon"),
                        SpoonacularStep(number: 3, step: "Mix everything together")
                    ]
                )
            ],
            nutrition: nil
        )

        let recipe = discovered.toRecipe()

        XCTAssertEqual(recipe.instructions.count, 3)
        XCTAssertEqual(recipe.instructions[0].instruction, "Boil pasta")
        XCTAssertEqual(recipe.instructions[0].order, 0)
        XCTAssertEqual(recipe.instructions[1].instruction, "Cook bacon")
        XCTAssertEqual(recipe.instructions[1].order, 1)
        XCTAssertEqual(recipe.instructions[2].instruction, "Mix everything together")
        XCTAssertEqual(recipe.instructions[2].order, 2)
    }

    func testToRecipeWithNutrition() {
        let discovered = DiscoveredRecipe(
            id: 123,
            title: "Pasta Carbonara",
            image: nil,
            imageType: nil,
            servings: nil,
            readyInMinutes: nil,
            sourceUrl: nil,
            sourceName: nil,
            cuisines: nil,
            dishTypes: nil,
            vegetarian: nil,
            vegan: nil,
            glutenFree: nil,
            extendedIngredients: nil,
            analyzedInstructions: nil,
            nutrition: SpoonacularNutrition(
                nutrients: [
                    SpoonacularNutrient(name: "Calories", amount: 450, unit: "kcal", percentOfDailyNeeds: nil),
                    SpoonacularNutrient(name: "Protein", amount: 20, unit: "g", percentOfDailyNeeds: nil),
                    SpoonacularNutrient(name: "Fat", amount: 15, unit: "g", percentOfDailyNeeds: nil),
                    SpoonacularNutrient(name: "Carbohydrates", amount: 50, unit: "g", percentOfDailyNeeds: nil)
                ]
            )
        )

        let recipe = discovered.toRecipe()

        XCTAssertNotNil(recipe.nutrition)
        XCTAssertEqual(recipe.nutrition?.calories, 450)
        XCTAssertEqual(recipe.nutrition?.protein, 20)
        XCTAssertEqual(recipe.nutrition?.fat, 15)
        XCTAssertEqual(recipe.nutrition?.carbohydrates, 50)
    }

    func testToRecipeWithAllData() {
        let discovered = DiscoveredRecipe(
            id: 123,
            title: "Pasta Carbonara",
            image: nil,
            imageType: nil,
            servings: 4,
            readyInMinutes: 30,
            sourceUrl: "https://example.com",
            sourceName: "Spoonacular",
            cuisines: ["Italian"],
            dishTypes: nil,
            vegetarian: nil,
            vegan: nil,
            glutenFree: nil,
            extendedIngredients: [
                SpoonacularIngredient(
                    id: 1,
                    name: "pasta",
                    original: "1 lb pasta",
                    measures: SpoonacularMeasures(
                        us: SpoonacularMeasure(amount: 1, unitShort: "lb", unitLong: "pound"),
                        metric: SpoonacularMeasure(amount: 453, unitShort: "g", unitLong: "grams")
                    )
                )
            ],
            analyzedInstructions: [
                SpoonacularInstruction(
                    name: nil,
                    steps: [
                        SpoonacularStep(number: 1, step: "Boil pasta")
                    ]
                )
            ],
            nutrition: SpoonacularNutrition(
                nutrients: [
                    SpoonacularNutrient(name: "Calories", amount: 450, unit: "kcal", percentOfDailyNeeds: nil)
                ]
            )
        )

        let recipe = discovered.toRecipe()

        XCTAssertEqual(recipe.title, "Pasta Carbonara")
        XCTAssertEqual(recipe.ingredients.count, 1)
        XCTAssertEqual(recipe.instructions.count, 1)
        XCTAssertNotNil(recipe.nutrition)
        XCTAssertEqual(recipe.sourceType, .web_imported)
    }
}
