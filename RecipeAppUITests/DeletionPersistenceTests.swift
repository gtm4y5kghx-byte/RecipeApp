import XCTest

final class DeletionPersistenceTests: XCTestCase {

    // MARK: - Deletion removes recipe from Meal Plan

    func testDeletedRecipeDisappearsFromMealPlan() throws {
        let app = AppLauncher.launchWith(recipes: ["pad_thai"])

        // 1. Add a recipe to the meal plan
        let card = app.recipeCard(titled: "Pad Thai")
        XCTAssertTrue(app.waitForElement(card))
        card.tap()

        let menuButton = app.buttons["recipe-detail-menu-button"]
        XCTAssertTrue(app.waitForElement(menuButton))
        menuButton.tap()
        app.buttons["recipe-detail-add-to-meal-plan-button"].tap()

        // Wait for calendar sheet, scroll to today, add as dinner
        let cancelButton = app.buttons["meal-plan-calendar-sheet-cancel-button"]
        XCTAssertTrue(app.waitForElement(cancelButton, timeout: 5))

        let todayButton = app.buttons["meal-plan-calendar-sheet-today-button"]
        if todayButton.exists { todayButton.tap() }

        let dateID = Self.todayDateID()
        let addButton = app.buttons["meal-plan-\(dateID)-add-button"]
        XCTAssertTrue(app.waitForElement(addButton, timeout: 3))
        addButton.tap()

        let dinnerButton = app.buttons["Dinner"]
        XCTAssertTrue(app.waitForElement(dinnerButton, timeout: 3))
        dinnerButton.tap()

        // Wait for sheet to dismiss, back on detail
        let detailMenu = app.buttons["recipe-detail-menu-button"]
        XCTAssertTrue(app.waitForElement(detailMenu, timeout: 5))

        // Verify it's in the meal plan
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.tapMealPlanTab()

        let entryBefore = app.staticTexts["Pad Thai"]
        XCTAssertTrue(app.waitForElement(entryBefore, timeout: 5), "Recipe should be visible in meal plan")

        // 2. Go back to recipes and delete it
        app.tapRecipesTab()

        let cardToDelete = app.recipeCard(titled: "Pad Thai")
        XCTAssertTrue(app.waitForElement(cardToDelete))
        cardToDelete.tap()

        let deleteMenu = app.buttons["recipe-detail-menu-button"]
        XCTAssertTrue(app.waitForElement(deleteMenu))
        deleteMenu.tap()
        app.buttons["recipe-detail-delete-button"].tap()

        let alert = app.alerts.firstMatch
        XCTAssertTrue(app.waitForElement(alert))
        alert.buttons["Delete"].tap()

        // 3. Switch to meal plan — recipe should be gone
        app.tapMealPlanTab()

        let entryAfter = app.staticTexts["Pad Thai"]
        XCTAssertFalse(entryAfter.waitForExistence(timeout: 3), "Deleted recipe should no longer appear in meal plan")
    }

    // MARK: - Deletion removes recipe from search results and default grid

    func testDeletedRecipeDisappearsFromSearchAndGrid() throws {
        let app = AppLauncher.launchWith(recipes: ["spicy_ramen"])

        // 1. Search for the recipe to confirm it exists
        app.searchFor("Spicy")

        let searchResult = app.recipeCard(titled: "Spicy Miso Ramen")
        XCTAssertTrue(app.waitForElement(searchResult), "Recipe should appear in search results")

        // Clear search to go back to full list
        app.clearSearch()
        let cancelSearchButton = app.buttons["Cancel"]
        if cancelSearchButton.exists { cancelSearchButton.tap() }

        // 2. Navigate to the recipe and delete it
        let card = app.recipeCard(titled: "Spicy Miso Ramen")
        XCTAssertTrue(app.waitForElement(card))
        card.tap()

        let menuButton = app.buttons["recipe-detail-menu-button"]
        XCTAssertTrue(app.waitForElement(menuButton))
        menuButton.tap()
        app.buttons["recipe-detail-delete-button"].tap()

        let alert = app.alerts.firstMatch
        XCTAssertTrue(app.waitForElement(alert))
        alert.buttons["Delete"].tap()

        // 3. Should be back on the grid — verify recipe is gone from default view
        let gridCard = app.recipeCard(titled: "Spicy Miso Ramen")
        XCTAssertFalse(gridCard.waitForExistence(timeout: 3), "Deleted recipe should not appear in recipe grid")

        // 4. Search again — should not find it
        app.searchFor("Spicy")

        let searchAgain = app.recipeCard(titled: "Spicy Miso Ramen")
        XCTAssertFalse(searchAgain.waitForExistence(timeout: 3), "Deleted recipe should not appear in search results")
    }

    // MARK: - Helpers

    private static func todayDateID() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
