import XCTest

final class RecipeSearchUITests: BaseUITestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()

        createRecipeWithProperties(
            title: "Pasta Carbonara",
            ingredients: ["bacon"],
            instructions: ["boil pasta water"],
            cuisine: "Italian"
        )

        createRecipeWithProperties(
            title: "Chicken Soup",
            ingredients: ["chicken breast"],
            instructions: ["simmer the broth"]
        )

        createRecipeWithProperties(
            title: "Veggie Stir Fry",
            ingredients: ["broccoli florets"],
            instructions: ["heat the wok"],
            notes: "perfect for meal prep"
        )
    }

    func testSearchByTitle() throws {
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("Pasta")

        XCTAssertTrue(app.staticTexts["Pasta Carbonara"].exists)
        XCTAssertFalse(app.staticTexts["Chicken Soup"].exists)
    }

    func testSearchByIngredient() throws {
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("chicken")

        let ingredientsScope = app.buttons["Ingredients"]
        XCTAssertTrue(ingredientsScope.waitForExistence(timeout: 2))
        ingredientsScope.tap()

        XCTAssertTrue(app.staticTexts["Chicken Soup"].exists)
        XCTAssertFalse(app.staticTexts["Pasta Carbonara"].exists)
    }

    func testSearchByInstructions() throws {
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("boil")

        let instructionsScope = app.buttons["Instructions"]
        XCTAssertTrue(instructionsScope.waitForExistence(timeout: 2))
        instructionsScope.tap()

        XCTAssertTrue(app.staticTexts["Pasta Carbonara"].exists)
        XCTAssertFalse(app.staticTexts["Chicken Soup"].exists)
    }

    func testSearchByNotes() throws {
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("meal prep")

        let notesScope = app.buttons["Notes"]
        XCTAssertTrue(notesScope.waitForExistence(timeout: 2))
        notesScope.tap()

        XCTAssertTrue(app.staticTexts["Veggie Stir Fry"].exists)
        XCTAssertFalse(app.staticTexts["Pasta Carbonara"].exists)
        XCTAssertFalse(app.staticTexts["Chicken Soup"].exists)
    }

    func testSearchByCuisine() throws {
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("Italian")

        let cuisineScope = app.buttons["Cuisine"]
        XCTAssertTrue(cuisineScope.waitForExistence(timeout: 2))
        cuisineScope.tap()

        XCTAssertTrue(app.staticTexts["Pasta Carbonara"].exists)
        XCTAssertFalse(app.staticTexts["Chicken Soup"].exists)
        XCTAssertFalse(app.staticTexts["Veggie Stir Fry"].exists)
    }

    func testClearSearchShowsAllRecipes() throws {
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("Pasta")

        XCTAssertTrue(app.staticTexts["Pasta Carbonara"].exists)
        XCTAssertFalse(app.staticTexts["Chicken Soup"].exists)

        let clearButton = searchField.buttons["Clear text"]
        clearButton.tap()

        XCTAssertTrue(app.staticTexts["Pasta Carbonara"].exists)
        XCTAssertTrue(app.staticTexts["Chicken Soup"].exists)
        XCTAssertTrue(app.staticTexts["Veggie Stir Fry"].exists)
    }

    func testFuzzySearchMatching() throws {
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("past")

        XCTAssertTrue(app.staticTexts["Pasta Carbonara"].exists)

        let clearButton = searchField.buttons["Clear text"]
        clearButton.tap()

        searchField.typeText("chikn")

        XCTAssertTrue(app.staticTexts["Chicken Soup"].exists)
    }
}
