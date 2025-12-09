import XCTest

extension XCUIApplication {
    func expandSheet() {
        let startCoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.7))
        let endCoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        startCoordinate.press(forDuration: 0.1, thenDragTo: endCoordinate)
    }
}

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
        cuisine: String? = nil,
        isFavorite: Bool = false,
        markAsCooked: Bool = false,
        tags: [String] = []
    ) {
        let addButton = app.buttons["add-recipe-button"]
        addButton.tap()

        let titleField = app.textFields["recipe-title-field"]
        titleField.tap()
        titleField.typeText(title)

        if let cuisine = cuisine {
            fillCuisineField(cuisine: cuisine)
        }

        if let notes = notes {
            fillNotesField(notes: notes)
        }

        if !tags.isEmpty {
            fillTagField(tags: tags)
        }

        if !ingredients.isEmpty {
            fillIngredientFields(ingredients: ingredients)
        }

        if !instructions.isEmpty {
            fillInstructionFields(instructions: instructions)
        }

        let saveButton = app.buttons["recipe-form-save-button"]
        saveButton.tap()

        _ = app.staticTexts[title].waitForExistence(timeout: 3)

        if isFavorite {
            markRecipeAsFavorite(recipeTitle: title)
        }

        if markAsCooked {
            markRecipeAsCooked(recipeTitle: title)
        }
    }

    private func fillCuisineField(cuisine: String) {
        let cuisineField = app.textFields["recipe-cuisine-field"]
        cuisineField.tap()
        cuisineField.typeText(cuisine)
    }

    private func fillNotesField(notes: String) {
        let notesEditor = app.textViews["recipe-notes-editor"]
        notesEditor.tap()
        notesEditor.typeText(notes)
    }

    private func fillTagField(tags: [String]) {
        let tagField = app.textFields["recipe-tag-field"]
        tagField.tap()
        tagField.typeText(tags.joined(separator: ", "))
    }

    private func fillIngredientFields(ingredients: [String]) {
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

    private func fillInstructionFields(instructions: [String]) {
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

    private func markRecipeAsFavorite(recipeTitle: String) {
        app.staticTexts[recipeTitle].tap()
        let favoriteButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Favorite'")).firstMatch
        favoriteButton.tap()
        app.navigationBars.buttons.firstMatch.tap()
    }

    private func markRecipeAsCooked(recipeTitle: String) {
        app.staticTexts[recipeTitle].tap()
        let markCookedButton = app.buttons["mark-cooked-button"]
        markCookedButton.tap()
        app.navigationBars.buttons.firstMatch.tap()
    }
}
