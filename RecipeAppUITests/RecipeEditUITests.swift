import XCTest

final class RecipeEditUITests: BaseUITestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()

        createTestRecipe()

        let recipeTitle = app.staticTexts["Test Recipe"]
        recipeTitle.tap()
    }

    func testEditRecipeTitle() throws {
        let editButton = app.buttons["edit-recipe-button"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 2))
        editButton.tap()

        let titleField = app.textFields["recipe-title-field"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.clearText()
        titleField.typeText("Updated Recipe Title")

        let saveButton = app.buttons["recipe-form-save-button"]
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        XCTAssertFalse(saveButton.waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Updated Recipe Title"].exists)
    }

    func testEditRecipeIngredients() throws {
        let editButton = app.buttons["edit-recipe-button"]
        editButton.tap()

        let ingredientField = app.textFields["ingredient-field-0"]
        XCTAssertTrue(ingredientField.waitForExistence(timeout: 2))
        ingredientField.tap()
        ingredientField.clearText()
        ingredientField.typeText("Updated ingredient")

        let saveButton = app.buttons["recipe-form-save-button"]
        saveButton.tap()

        XCTAssertFalse(saveButton.waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Updated ingredient"].exists)
    }

    func testAddIngredient() throws {
        let editButton = app.buttons["edit-recipe-button"]
        editButton.tap()

        let addIngredientButton = app.buttons["add-ingredient-button"]
        addIngredientButton.tap()

        let secondIngredientField = app.textFields["ingredient-field-1"]
        XCTAssertTrue(secondIngredientField.waitForExistence(timeout: 2))
        secondIngredientField.tap()
        secondIngredientField.typeText("New ingredient")

        let saveButton = app.buttons["recipe-form-save-button"]
        saveButton.tap()

        XCTAssertFalse(saveButton.waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["New ingredient"].exists)
    }

    func testDeleteIngredient() throws {
        let editButton = app.buttons["edit-recipe-button"]
        editButton.tap()

        let addIngredientButton = app.buttons["add-ingredient-button"]
        addIngredientButton.tap()

        let secondIngredientField = app.textFields["ingredient-field-1"]
        XCTAssertTrue(secondIngredientField.waitForExistence(timeout: 2))
        secondIngredientField.tap()
        secondIngredientField.typeText("Ingredient to delete")

        let deleteButton = app.buttons["delete-ingredient-1"]
        XCTAssertTrue(deleteButton.exists)
        XCTAssertTrue(deleteButton.isEnabled)
        deleteButton.tap()

        XCTAssertFalse(app.textFields["ingredient-field-1"].exists)

        let firstDeleteButton = app.buttons["delete-ingredient-0"]
        XCTAssertFalse(firstDeleteButton.isEnabled)

        let saveButton = app.buttons["recipe-form-save-button"]
        saveButton.tap()

        XCTAssertFalse(saveButton.waitForExistence(timeout: 2))
        XCTAssertFalse(app.staticTexts["Ingredient to delete"].exists)
    }

    func testEditRecipeInstructions() throws {
        let editButton = app.buttons["edit-recipe-button"]
        editButton.tap()

        app.swipeUp()

        let instructionField = app.textViews["instruction-editor-0"]
        XCTAssertTrue(instructionField.waitForExistence(timeout: 2))
        instructionField.clearTextView()
        instructionField.typeText("Updated cooking instruction")

        let saveButton = app.buttons["recipe-form-save-button"]
        saveButton.tap()

        XCTAssertFalse(saveButton.waitForExistence(timeout: 2))

        let updatedInstruction = app.staticTexts["Updated cooking instruction"]
        XCTAssertTrue(updatedInstruction.exists)
    }

    func testCancelEditWithChanges() throws {
        let editButton = app.buttons["edit-recipe-button"]
        editButton.tap()

        let titleField = app.textFields["recipe-title-field"]
        titleField.tap()
        titleField.clearText()
        titleField.typeText("This Should Not Save")

        let cancelButton = app.buttons["recipe-form-cancel-button"]
        cancelButton.tap()

        let discardButton = app.alerts.buttons["Discard"]
        XCTAssertTrue(discardButton.waitForExistence(timeout: 2))
        discardButton.tap()

        XCTAssertFalse(app.staticTexts["This Should Not Save"].exists)
        XCTAssertTrue(app.staticTexts["Test Recipe"].waitForExistence(timeout: 3))
    }

    func testEditRecipeMetadata() throws {
        let editButton = app.buttons["edit-recipe-button"]
        editButton.tap()

        let servingsField = app.textFields["recipe-servings-field"]
        XCTAssertTrue(servingsField.waitForExistence(timeout: 2))
        servingsField.tap()
        servingsField.clearText()
        servingsField.typeText("4")

        let prepTimeField = app.textFields["recipe-prep-time-field"]
        prepTimeField.tap()
        prepTimeField.clearText()
        prepTimeField.typeText("15")

        let cookTimeField = app.textFields["recipe-cook-time-field"]
        cookTimeField.tap()
        cookTimeField.clearText()
        cookTimeField.typeText("30")

        let cuisineField = app.textFields["recipe-cuisine-field"]
        cuisineField.tap()
        cuisineField.clearText()
        cuisineField.typeText("Italian")

        let saveButton = app.buttons["recipe-form-save-button"]
        saveButton.tap()

        XCTAssertFalse(saveButton.waitForExistence(timeout: 2))

        XCTAssertTrue(app.staticTexts["4 servings"].exists)
        XCTAssertTrue(app.staticTexts["15 min"].exists)
        XCTAssertTrue(app.staticTexts["30 min"].exists)
        XCTAssertTrue(app.staticTexts["Italian"].exists)
    }
}
