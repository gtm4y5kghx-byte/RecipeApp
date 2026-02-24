import XCTest

final class RecipeFormValidationTests: XCTestCase {

    func testSaveDisabledWithEmptyTitle() throws {
        let app = AppLauncher.launchClean()

        // Open new recipe form
        app.openRecipeListMenu()
        app.tapNewRecipe()

        let saveButton = app.buttons["recipe-form-save-button"]
        XCTAssertTrue(app.waitForElement(saveButton))

        // Save should be disabled when title is empty
        XCTAssertFalse(saveButton.isEnabled, "Save button should be disabled when title is empty")
    }

    func testSaveEnabledAfterEnteringTitle() throws {
        let app = AppLauncher.launchClean()

        app.openRecipeListMenu()
        app.tapNewRecipe()

        let titleField = app.textFields["recipe-form-title-field"]
        XCTAssertTrue(app.waitForElement(titleField))

        titleField.tap()
        titleField.typeText("My Recipe")

        let saveButton = app.buttons["recipe-form-save-button"]
        XCTAssertTrue(saveButton.isEnabled, "Save button should be enabled after entering a title")
    }
}
