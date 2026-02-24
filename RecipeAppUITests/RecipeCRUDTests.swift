import XCTest

final class RecipeCRUDTests: XCTestCase {

    // MARK: - Create

    func testCreateRecipe() throws {
        let app = AppLauncher.launchClean()

        // Open menu → New Recipe
        app.openRecipeListMenu()
        app.tapNewRecipe()

        let titleField = app.textFields["recipe-form-title-field"]
        XCTAssertTrue(app.waitForElement(titleField), "Title field should appear")

        // Fill title
        titleField.tap()
        titleField.typeText("Test Pancakes")

        // Add an ingredient
        app.buttons["add-ingredient"].tap()
        let ingredientField = app.textFields["recipe-form-ingredient-0-field"]
        XCTAssertTrue(app.waitForElement(ingredientField))
        ingredientField.tap()
        ingredientField.typeText("2 cups flour")

        // Add an instruction
        app.buttons["add-step"].tap()
        let instructionField = app.textViews["recipe-form-instruction-0-field"]
        XCTAssertTrue(app.waitForElement(instructionField))
        instructionField.tap()
        instructionField.typeText("Mix dry ingredients")

        // Save
        app.buttons["recipe-form-save-button"].tap()

        // Verify card appears in list
        let card = app.recipeCard(titled: "Test Pancakes")
        XCTAssertTrue(app.waitForElement(card), "New recipe should appear in the list")
    }

    // MARK: - Edit

    func testEditRecipe() throws {
        let app = AppLauncher.launchWith(recipes: ["apple_pie"])

        let card = app.recipeCard(titled: "Grandma's Apple Pie")
        XCTAssertTrue(app.waitForElement(card), "Sample recipe should exist")
        card.tap()

        // Wait for detail to load
        let menuButton = app.buttons["recipe-detail-menu-button"]
        XCTAssertTrue(app.waitForElement(menuButton))

        // Open menu → Edit
        menuButton.tap()
        app.buttons["recipe-detail-edit-button"].tap()

        // Change title
        let titleField = app.textFields["recipe-form-title-field"]
        XCTAssertTrue(app.waitForElement(titleField))
        titleField.tap()
        titleField.clearAndTypeText("Updated Apple Pie")

        // Save
        app.buttons["recipe-form-save-button"].tap()

        // Verify updated title in detail
        let updatedTitle = app.staticTexts["Updated Apple Pie"]
        XCTAssertTrue(app.waitForElement(updatedTitle), "Title should be updated in detail view")
    }

    // MARK: - Delete from Detail

    func testDeleteRecipeFromDetail() throws {
        let app = AppLauncher.launchWith(recipes: ["grilled_cheese"])

        let card = app.recipeCard(titled: "Classic Grilled Cheese")
        XCTAssertTrue(app.waitForElement(card))
        card.tap()

        // Wait for detail
        let menuButton = app.buttons["recipe-detail-menu-button"]
        XCTAssertTrue(app.waitForElement(menuButton))

        // Menu → Delete → Confirm
        menuButton.tap()
        app.buttons["recipe-detail-delete-button"].tap()

        let deleteAlert = app.alerts.firstMatch
        XCTAssertTrue(app.waitForElement(deleteAlert))
        deleteAlert.buttons["Delete"].tap()

        // Should return to list; recipe should be gone
        let deletedCard = app.recipeCard(titled: "Classic Grilled Cheese")
        XCTAssertFalse(deletedCard.waitForExistence(timeout: 2), "Deleted recipe should not appear in list")
    }

    // MARK: - Delete from Swipe

    func testDeleteRecipeFromSwipe() throws {
        let app = AppLauncher.launchWith(recipes: ["tacos"])

        let card = app.recipeCard(titled: "Easy Beef Tacos")
        XCTAssertTrue(app.waitForElement(card))

        // Swipe left to reveal trash button
        card.swipeLeft()

        // Tap the trash button (it's a button with a "trash" image inside the swipe action)
        let trashButton = app.buttons["trash"].firstMatch
        if trashButton.waitForExistence(timeout: 2) {
            trashButton.tap()
        } else {
            // Fallback: try tapping the image directly
            app.images["trash"].firstMatch.tap()
        }

        // Confirm delete
        let deleteAlert = app.alerts.firstMatch
        XCTAssertTrue(app.waitForElement(deleteAlert))
        deleteAlert.buttons["Delete"].tap()

        // Verify gone
        let deletedCard = app.recipeCard(titled: "Easy Beef Tacos")
        XCTAssertFalse(deletedCard.waitForExistence(timeout: 2), "Swiped recipe should be deleted")
    }

    // MARK: - Delete During Search

    func testDeleteRecipeDuringSearch() throws {
        let app = AppLauncher.launchWith(recipes: ["baked_salmon"])

        // Search for the recipe
        app.searchFor("Baked Salmon")

        let card = app.recipeCard(titled: "Simple Baked Salmon")
        XCTAssertTrue(app.waitForElement(card), "Search should find Simple Baked Salmon")

        // Swipe delete
        card.swipeLeft()
        let trashButton = app.buttons["trash"].firstMatch
        if trashButton.waitForExistence(timeout: 2) {
            trashButton.tap()
        } else {
            app.images["trash"].firstMatch.tap()
        }

        // Confirm
        let deleteAlert = app.alerts.firstMatch
        XCTAssertTrue(app.waitForElement(deleteAlert))
        deleteAlert.buttons["Delete"].tap()

        // Verify recipe no longer in search results
        let deletedCard = app.recipeCard(titled: "Simple Baked Salmon")
        XCTAssertFalse(deletedCard.waitForExistence(timeout: 2), "Deleted recipe should disappear from search results")
    }
}

// MARK: - XCUIElement Helpers

private extension XCUIElement {
    func clearAndTypeText(_ text: String) {
        guard let currentValue = value as? String, !currentValue.isEmpty else {
            typeText(text)
            return
        }
        // Select all + type to replace
        tap(withNumberOfTaps: 3, numberOfTouches: 1)
        typeText(text)
    }
}
