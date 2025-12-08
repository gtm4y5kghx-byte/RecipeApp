import XCTest

final class RecipeEditUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testEditRecipeTitle() throws {
        let firstRecipe = app.collectionViews.cells.firstMatch
        XCTAssertTrue(firstRecipe.waitForExistence(timeout: 5))
        firstRecipe.tap()

        let editButton = app.navigationBars.buttons["Edit"]
        XCTAssertTrue(editButton.exists)
        editButton.tap()

        let titleField = app.textFields["Title"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.clearText()
        titleField.typeText("Updated Recipe Title")

        let saveButton = app.navigationBars.buttons["Save"]
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        XCTAssertTrue(app.staticTexts["Updated Recipe Title"].waitForExistence(timeout: 3))
    }

    func testEditRecipeIngredients() throws {
        let firstRecipe = app.collectionViews.cells.firstMatch
        firstRecipe.tap()

        let editButton = app.navigationBars.buttons["Edit"]
        editButton.tap()

        let ingredientField = app.textFields.matching(identifier: "ingredient-field").element(boundBy: 0)
        XCTAssertTrue(ingredientField.waitForExistence(timeout: 2))
        ingredientField.tap()
        ingredientField.clearText()
        ingredientField.typeText("Updated ingredient")

        let saveButton = app.navigationBars.buttons["Save"]
        saveButton.tap()

        app.staticTexts["Ingredients"].tap()
        XCTAssertTrue(app.staticTexts["Updated ingredient"].exists)
    }

    func testDeleteIngredient() throws {
        let firstRecipe = app.collectionViews.cells.firstMatch
        firstRecipe.tap()

        let editButton = app.navigationBars.buttons["Edit"]
        editButton.tap()

        let ingredientsList = app.textFields.matching(identifier: "ingredient-field")
        let initialCount = ingredientsList.count

        let deleteButton = app.buttons.matching(identifier: "delete-ingredient").element(boundBy: 0)
        if deleteButton.exists {
            deleteButton.tap()

            let newCount = app.textFields.matching(identifier: "ingredient-field").count
            XCTAssertEqual(newCount, initialCount - 1)
        }

        app.navigationBars.buttons["Cancel"].tap()
    }

    func testEditRecipeInstructions() throws {
        let firstRecipe = app.collectionViews.cells.firstMatch
        firstRecipe.tap()

        let editButton = app.navigationBars.buttons["Edit"]
        editButton.tap()

        let instructionField = app.textViews.matching(identifier: "instruction-field").element(boundBy: 0)
        XCTAssertTrue(instructionField.waitForExistence(timeout: 2))
        instructionField.tap()
        instructionField.clearText()
        instructionField.typeText("Updated cooking instruction")

        let saveButton = app.navigationBars.buttons["Save"]
        saveButton.tap()

        app.staticTexts["Instructions"].tap()
        XCTAssertTrue(app.staticTexts["Updated cooking instruction"].exists)
    }

    func testCancelEditWithChanges() throws {
        let firstRecipe = app.collectionViews.cells.firstMatch
        firstRecipe.tap()

        let originalTitle = app.staticTexts.firstMatch.label

        let editButton = app.navigationBars.buttons["Edit"]
        editButton.tap()

        let titleField = app.textFields["Title"]
        titleField.tap()
        titleField.clearText()
        titleField.typeText("This Should Not Save")

        let cancelButton = app.navigationBars.buttons["Cancel"]
        cancelButton.tap()

        let discardButton = app.alerts.buttons["Discard"]
        if discardButton.exists {
            discardButton.tap()
        }

        XCTAssertFalse(app.staticTexts["This Should Not Save"].exists)
        XCTAssertTrue(app.staticTexts[originalTitle].exists)
    }
}

extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
}
