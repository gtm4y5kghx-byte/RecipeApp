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

        _ = app.staticTexts[title].waitForExistence(timeout: 3)
    }

    func createRecipeWithProperties(
        title: String,
        ingredients: [String] = [],
        instructions: [String] = [],
        notes: String? = nil,
        cuisine: String? = nil
    ) {
        let addButton = app.buttons["add-recipe-button"]
        addButton.tap()

        let titleField = app.textFields["recipe-title-field"]
        titleField.tap()
        titleField.typeText(title)

        if let cuisine = cuisine {
            let cuisineField = app.textFields["recipe-cuisine-field"]
            cuisineField.tap()
            cuisineField.typeText(cuisine)
        }

        if let notes = notes {
            let notesEditor = app.textViews["recipe-notes-editor"]
            notesEditor.tap()
            notesEditor.typeText(notes)
        }

        if !ingredients.isEmpty {
            for (index, ingredient) in ingredients.enumerated() {
                if index > 0 {
                    let addIngredientButton = app.buttons["add-ingredient-button"]
                    addIngredientButton.tap()
                }
                let ingredientField = app.textFields["ingredient-field-\(index)"]
                ingredientField.tap()
                ingredientField.typeText(ingredient)
            }
        }

        if !instructions.isEmpty {
            app.swipeUp()

            for (index, instruction) in instructions.enumerated() {
                if index > 0 {
                    let addStepButton = app.buttons["add-step-button"]
                    addStepButton.tap()
                }
                let instructionField = app.textViews["instruction-editor-\(index)"]
                instructionField.tap()
                instructionField.typeText(instruction)
            }
        }

        let saveButton = app.buttons["recipe-form-save-button"]
        saveButton.tap()

        _ = app.staticTexts[title].waitForExistence(timeout: 3)
    }
}
