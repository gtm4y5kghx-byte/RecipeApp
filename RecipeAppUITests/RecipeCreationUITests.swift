import XCTest

final class RecipeCreationUITests: BaseUITestCase {

    func testCreateRecipeFlow() throws {
        let addButton = app.buttons["add-recipe-button"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let titleField = app.textFields["recipe-title-field"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Pasta Carbonara")

        let servingsField = app.textFields["recipe-servings-field"]
        servingsField.tap()
        servingsField.typeText("4")

        let prepTimeField = app.textFields["recipe-prep-time-field"]
        prepTimeField.tap()
        prepTimeField.typeText("10")

        let cookTimeField = app.textFields["recipe-cook-time-field"]
        cookTimeField.tap()
        cookTimeField.typeText("20")

        let cuisineField = app.textFields["recipe-cuisine-field"]
        cuisineField.tap()
        cuisineField.typeText("Italian")

        let firstIngredientField = app.textFields["ingredient-field-0"]
        firstIngredientField.tap()
        firstIngredientField.typeText("500g spaghetti")

        let addIngredientButton = app.buttons["add-ingredient-button"]
        addIngredientButton.tap()

        let secondIngredientField = app.textFields["ingredient-field-1"]
        secondIngredientField.tap()
        secondIngredientField.typeText("4 eggs")

        let firstInstructionField = app.textViews["instruction-editor-0"]
        firstInstructionField.tap()
        firstInstructionField.typeText("Boil pasta according to package directions")

        let addStepButton = app.buttons["add-step-button"]
        addStepButton.tap()

        let secondInstructionField = app.textViews["instruction-editor-1"]
        secondInstructionField.tap()
        secondInstructionField.typeText("Mix eggs with pasta and serve")

        let saveButton = app.buttons["recipe-form-save-button"]
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        XCTAssertTrue(app.staticTexts["Pasta Carbonara"].waitForExistence(timeout: 3))
    }

    func testCreateRecipeValidation() throws {
        let addButton = app.buttons["add-recipe-button"]
        addButton.tap()

        let saveButton = app.buttons["recipe-form-save-button"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 2))
        XCTAssertFalse(saveButton.isEnabled)

        let titleField = app.textFields["recipe-title-field"]
        titleField.tap()
        titleField.typeText("Test Recipe")

        XCTAssertTrue(saveButton.isEnabled)
    }

    func testCancelRecipeCreation() throws {
        let addButton = app.buttons["add-recipe-button"]
        addButton.tap()

        let titleField = app.textFields["recipe-title-field"]
        titleField.tap()
        titleField.typeText("Test Recipe to Cancel")

        let cancelButton = app.buttons["recipe-form-cancel-button"]
        cancelButton.tap()

        let discardButton = app.alerts.buttons["Discard"]
        if discardButton.exists {
            discardButton.tap()
        }

        XCTAssertFalse(app.staticTexts["Test Recipe to Cancel"].exists)
    }
}
