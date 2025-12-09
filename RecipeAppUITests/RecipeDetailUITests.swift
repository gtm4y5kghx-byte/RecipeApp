import XCTest

final class RecipeDetailUITests: BaseUITestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()

        createTestRecipe(title: "Test Recipe Detail")

        let recipeTitle = app.staticTexts["Test Recipe Detail"]
        recipeTitle.tap()
    }

    func testRecipeDetailsDisplay() throws {
        XCTAssertTrue(app.staticTexts["Test Recipe Detail"].exists)

        XCTAssertTrue(app.staticTexts["Original ingredient"].exists)

        XCTAssertTrue(app.staticTexts["Original instruction"].exists)
    }

    func testMarkAsCookedFromToolbar() throws {
        let markCookedButton = app.buttons["mark-cooked-button"]
        XCTAssertTrue(markCookedButton.waitForExistence(timeout: 2))

        markCookedButton.tap()

        XCTAssertTrue(app.staticTexts["Cooked 1 time"].waitForExistence(timeout: 2))
    }

    func testMarkAsCookedFromActionButtons() throws {
        let markCookedActionButton = app.buttons["mark-cooked-action-button"]
        XCTAssertTrue(markCookedActionButton.exists)

        markCookedActionButton.tap()

        XCTAssertTrue(app.staticTexts["Cooked 1 time"].waitForExistence(timeout: 2))
    }

    func testToggleFavorite() throws {
        let favoriteButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Favorite'")).firstMatch
        XCTAssertTrue(favoriteButton.waitForExistence(timeout: 2))

        let initialLabel = favoriteButton.label
        favoriteButton.tap()

        let updatedLabel = favoriteButton.label
        XCTAssertNotEqual(initialLabel, updatedLabel)

        favoriteButton.tap()

        let finalLabel = favoriteButton.label
        XCTAssertEqual(initialLabel, finalLabel)
    }

    func testStartCookingButtonEnabledWithIngredientsAndInstructions() throws {
        let startCookingButton = app.buttons["start-cooking-button"]
        XCTAssertTrue(startCookingButton.waitForExistence(timeout: 2))
        XCTAssertTrue(startCookingButton.isEnabled)
    }

    func testTransformButtonEnabledWithIngredientsAndInstructions() throws {
        let transformButton = app.buttons["transform-recipe-button"]
        XCTAssertTrue(transformButton.waitForExistence(timeout: 2))
        XCTAssertTrue(transformButton.isEnabled)
    }

    func testStartCookingButtonDisabledWithNoIngredients() throws {
        app.navigationBars.buttons.firstMatch.tap()

        createRecipeWithProperties(
            title: "No Ingredients Recipe",
            ingredients: [],
            instructions: ["Step 1"]
        )

        let recipeTitle = app.staticTexts["No Ingredients Recipe"]
        recipeTitle.tap()

        let startCookingButton = app.buttons["start-cooking-button"]
        XCTAssertTrue(startCookingButton.waitForExistence(timeout: 2))
        XCTAssertFalse(startCookingButton.isEnabled)
    }

    func testStartCookingButtonDisabledWithNoInstructions() throws {
        app.navigationBars.buttons.firstMatch.tap()

        createRecipeWithProperties(
            title: "No Instructions Recipe",
            ingredients: ["Ingredient 1"],
            instructions: []
        )

        let recipeTitle = app.staticTexts["No Instructions Recipe"]
        recipeTitle.tap()

        let startCookingButton = app.buttons["start-cooking-button"]
        XCTAssertTrue(startCookingButton.waitForExistence(timeout: 2))
        XCTAssertFalse(startCookingButton.isEnabled)
    }

    func testTransformButtonDisabledWithNoIngredients() throws {
        app.navigationBars.buttons.firstMatch.tap()

        createRecipeWithProperties(
            title: "Transform No Ingredients",
            ingredients: [],
            instructions: ["Step 1"]
        )

        let recipeTitle = app.staticTexts["Transform No Ingredients"]
        recipeTitle.tap()

        let transformButton = app.buttons["transform-recipe-button"]
        XCTAssertTrue(transformButton.waitForExistence(timeout: 2))
        XCTAssertFalse(transformButton.isEnabled)
    }

    func testTransformButtonDisabledWithNoInstructions() throws {
        app.navigationBars.buttons.firstMatch.tap()

        createRecipeWithProperties(
            title: "Transform No Instructions",
            ingredients: ["Ingredient 1"],
            instructions: []
        )

        let recipeTitle = app.staticTexts["Transform No Instructions"]
        recipeTitle.tap()

        let transformButton = app.buttons["transform-recipe-button"]
        XCTAssertTrue(transformButton.waitForExistence(timeout: 2))
        XCTAssertFalse(transformButton.isEnabled)
    }

    func testNavigateToEditSheet() throws {
        let editButton = app.buttons["edit-recipe-button"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 2))
        editButton.tap()

        let titleField = app.textFields["recipe-title-field"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))

        let cancelButton = app.buttons["recipe-form-cancel-button"]
        cancelButton.tap()

        XCTAssertTrue(app.staticTexts["Test Recipe Detail"].waitForExistence(timeout: 2))
    }
}
