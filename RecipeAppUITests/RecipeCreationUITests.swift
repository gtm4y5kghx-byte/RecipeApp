import XCTest

final class RecipeCreationUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testCreateRecipeFlow() throws {
        let addButton = app.navigationBars.buttons["Add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let titleField = app.textFields["Title"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Pasta Carbonara")

        let servingsField = app.textFields["Servings"]
        servingsField.tap()
        servingsField.typeText("4")

        let prepTimeField = app.textFields["Prep Time (min)"]
        prepTimeField.tap()
        prepTimeField.typeText("10")

        let cookTimeField = app.textFields["Cook Time (min)"]
        cookTimeField.tap()
        cookTimeField.typeText("20")

        let cuisineField = app.textFields["Cuisine"]
        cuisineField.tap()
        cuisineField.typeText("Italian")

        let ingredientField = app.textFields.matching(identifier: "ingredient-field").element(boundBy: 0)
        ingredientField.tap()
        ingredientField.typeText("500g spaghetti")

        let addIngredientButton = app.buttons["Add Ingredient"]
        addIngredientButton.tap()

        let secondIngredientField = app.textFields.matching(identifier: "ingredient-field").element(boundBy: 1)
        secondIngredientField.tap()
        secondIngredientField.typeText("4 eggs")

        let instructionField = app.textViews.matching(identifier: "instruction-field").element(boundBy: 0)
        instructionField.tap()
        instructionField.typeText("Boil pasta according to package directions")

        let addStepButton = app.buttons["Add Step"]
        addStepButton.tap()

        let secondInstructionField = app.textViews.matching(identifier: "instruction-field").element(boundBy: 1)
        secondInstructionField.tap()
        secondInstructionField.typeText("Mix eggs with pasta and serve")

        let saveButton = app.navigationBars.buttons["Save"]
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        XCTAssertTrue(app.staticTexts["Pasta Carbonara"].waitForExistence(timeout: 3))
    }

    func testCreateRecipeValidation() throws {
        let addButton = app.navigationBars.buttons["Add"]
        addButton.tap()

        let saveButton = app.navigationBars.buttons["Save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 2))
        XCTAssertFalse(saveButton.isEnabled)

        let titleField = app.textFields["Title"]
        titleField.tap()
        titleField.typeText("Test Recipe")

        XCTAssertTrue(saveButton.isEnabled)
    }

    func testCancelRecipeCreation() throws {
        let addButton = app.navigationBars.buttons["Add"]
        addButton.tap()

        let titleField = app.textFields["Title"]
        titleField.tap()
        titleField.typeText("Test Recipe to Cancel")

        let cancelButton = app.navigationBars.buttons["Cancel"]
        cancelButton.tap()

        let discardButton = app.alerts.buttons["Discard"]
        if discardButton.exists {
            discardButton.tap()
        }

        XCTAssertFalse(app.staticTexts["Test Recipe to Cancel"].exists)
    }
}
