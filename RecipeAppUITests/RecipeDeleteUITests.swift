import XCTest

final class RecipeDeleteUITests: BaseUITestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()

        createTestRecipe(title: "Recipe to Delete")
    }

    func testDeleteFromRecipeList() throws {
        let recipeCell = app.staticTexts["Recipe to Delete"]
        XCTAssertTrue(recipeCell.exists)

        recipeCell.swipeLeft()

        let deleteButton = app.buttons["Delete"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 2))
        deleteButton.tap()

        XCTAssertFalse(app.staticTexts["Recipe to Delete"].exists)
    }

    func testDeleteFromRecipeDetailView() throws {
        let recipeTitle = app.staticTexts["Recipe to Delete"]
        recipeTitle.tap()

        let deleteButton = app.buttons["delete-recipe-button"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 2))
        deleteButton.tap()

        let deleteAlertButton = app.alerts.buttons["Delete"]
        XCTAssertTrue(deleteAlertButton.waitForExistence(timeout: 2))
        deleteAlertButton.tap()

        XCTAssertFalse(app.staticTexts["Recipe to Delete"].exists)
    }

    func testCancelDeleteFromRecipeDetailView() throws {
        let recipeTitle = app.staticTexts["Recipe to Delete"]
        recipeTitle.tap()

        let deleteButton = app.buttons["delete-recipe-button"]
        deleteButton.tap()

        let cancelButton = app.alerts.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 2))
        cancelButton.tap()

        XCTAssertTrue(app.staticTexts["Recipe to Delete"].exists)
    }
}
