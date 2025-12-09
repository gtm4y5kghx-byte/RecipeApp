import XCTest

class BaseUITestCase: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-TESTING"]
        app.launch()
    }

    func createTestRecipe(title: String = "Test Recipe") {
        let addButton = app.buttons["add-recipe-button"]
        addButton.tap()

        let titleField = app.textFields["recipe-title-field"]
        titleField.tap()
        titleField.typeText(title)

        let ingredientField = app.textFields["ingredient-field-0"]
        ingredientField.tap()
        ingredientField.typeText("Original ingredient")

        let instructionField = app.textViews["instruction-editor-0"]
        instructionField.tap()
        instructionField.typeText("Original instruction")

        let saveButton = app.buttons["recipe-form-save-button"]
        saveButton.tap()

        let recipeTitle = app.staticTexts[title]
    }
}
