import XCTest

final class MealPlanTests: XCTestCase {

    // MARK: - Add Recipe to Meal Plan

    func testAddRecipeToMealPlan() throws {
        let app = AppLauncher.launchWith(recipes: ["apple_pie"])

        // Navigate to a recipe
        let card = app.recipeCard(titled: "Grandma's Apple Pie")
        XCTAssertTrue(app.waitForElement(card))
        card.tap()

        // Menu → Add to Meal Plan
        let menuButton = app.buttons["recipe-detail-menu-button"]
        XCTAssertTrue(app.waitForElement(menuButton))
        menuButton.tap()
        app.buttons["recipe-detail-add-to-meal-plan-button"].tap()

        // Wait for the meal plan calendar sheet to appear
        let cancelButton = app.buttons["meal-plan-calendar-sheet-cancel-button"]
        XCTAssertTrue(app.waitForElement(cancelButton, timeout: 5), "Meal plan calendar sheet should appear")

        // Scroll to today
        let todayButton = app.buttons["meal-plan-calendar-sheet-today-button"]
        if todayButton.exists {
            todayButton.tap()
        }

        // Find today's date section and tap its "+" add button
        let dateID = Self.todayDateID()
        let addButton = app.buttons["meal-plan-\(dateID)-add-button"]
        XCTAssertTrue(app.waitForElement(addButton, timeout: 3), "Today's add button should be visible")
        addButton.tap()

        // Select a meal type from the menu (e.g., "Dinner")
        let dinnerButton = app.buttons["Dinner"]
        XCTAssertTrue(app.waitForElement(dinnerButton, timeout: 3))
        dinnerButton.tap()

        // Sheet should auto-dismiss after adding
        // Wait for detail view to come back
        let detailMenu = app.buttons["recipe-detail-menu-button"]
        XCTAssertTrue(app.waitForElement(detailMenu, timeout: 5), "Should return to recipe detail after adding to meal plan")

        // Navigate back to list, then to Meal Plan tab
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.tapMealPlanTab()

        // Verify the recipe appears in the meal plan
        let entryText = app.staticTexts["Grandma's Apple Pie"]
        XCTAssertTrue(app.waitForElement(entryText, timeout: 5), "Recipe should appear in meal plan")
    }

    // MARK: - View Recipe from Meal Plan

    func testViewRecipeFromMealPlan() throws {
        let app = AppLauncher.launchWith(recipes: ["chocolate_cake"])

        // First add a recipe to the meal plan
        let card = app.recipeCard(titled: "Simple Chocolate Cake")
        XCTAssertTrue(app.waitForElement(card))
        card.tap()

        let menuButton = app.buttons["recipe-detail-menu-button"]
        XCTAssertTrue(app.waitForElement(menuButton))
        menuButton.tap()
        app.buttons["recipe-detail-add-to-meal-plan-button"].tap()

        // Wait for calendar sheet
        let cancelButton = app.buttons["meal-plan-calendar-sheet-cancel-button"]
        XCTAssertTrue(app.waitForElement(cancelButton, timeout: 5))

        // Tap today button to scroll to today
        let todayButton = app.buttons["meal-plan-calendar-sheet-today-button"]
        if todayButton.exists {
            todayButton.tap()
        }

        // Add to today's lunch
        let dateID = Self.todayDateID()
        let addButton = app.buttons["meal-plan-\(dateID)-add-button"]
        XCTAssertTrue(app.waitForElement(addButton, timeout: 3))
        addButton.tap()

        let lunchButton = app.buttons["Lunch"]
        XCTAssertTrue(app.waitForElement(lunchButton, timeout: 3))
        lunchButton.tap()

        // Wait for sheet to dismiss
        let detailMenu = app.buttons["recipe-detail-menu-button"]
        XCTAssertTrue(app.waitForElement(detailMenu, timeout: 5))

        // Go back to list and switch to meal plan tab
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.tapMealPlanTab()

        // Tap the recipe entry in the meal plan
        let entryText = app.staticTexts["Simple Chocolate Cake"]
        XCTAssertTrue(app.waitForElement(entryText, timeout: 5))
        entryText.tap()

        // Verify recipe detail is shown
        let recipeDetailMenu = app.buttons["recipe-detail-menu-button"]
        XCTAssertTrue(app.waitForElement(recipeDetailMenu, timeout: 3), "Tapping meal plan entry should open recipe detail")

        // Verify it's the right recipe
        let title = app.staticTexts["Simple Chocolate Cake"]
        XCTAssertTrue(title.exists, "Should be viewing the correct recipe")
    }

    // MARK: - Add Recipe from Meal Plan View

    func testAddRecipeFromMealPlanView() throws {
        let app = AppLauncher.launchWith(recipes: ["apple_pie"])

        // Go to meal plan tab
        app.tapMealPlanTab()

        // Tap today button to scroll to today
        let todayButton = app.buttons["meal-plan-today-button"]
        if todayButton.exists { todayButton.tap() }

        // Tap "+" on today's date
        let dateID = Self.todayDateID()
        let addButton = app.buttons["meal-plan-\(dateID)-add-button"]
        XCTAssertTrue(app.waitForElement(addButton, timeout: 3), "Today's add button should be visible")
        addButton.tap()

        // Select meal type (e.g., Lunch)
        let lunchButton = app.buttons["Lunch"]
        XCTAssertTrue(app.waitForElement(lunchButton, timeout: 3))
        lunchButton.tap()

        // RecipePickerSheet should appear
        let pickerCancel = app.buttons["recipe-picker-cancel-button"]
        XCTAssertTrue(app.waitForElement(pickerCancel, timeout: 5), "Recipe picker sheet should appear")

        // Select a recipe from the list
        let recipeRow = app.staticTexts["Grandma's Apple Pie"]
        XCTAssertTrue(app.waitForElement(recipeRow, timeout: 3))
        recipeRow.tap()

        // Picker should dismiss — verify the entry now appears under today
        let entry = app.staticTexts["Grandma's Apple Pie"]
        XCTAssertTrue(app.waitForElement(entry, timeout: 5), "Selected recipe should appear in meal plan")
    }

    // MARK: - Delete Entry via Long Press

    func testDeleteEntryFromMealPlan() throws {
        let app = AppLauncher.launchWith(recipes: ["tacos"])

        // 1. Add a recipe to the meal plan
        let card = app.recipeCard(titled: "Easy Beef Tacos")
        XCTAssertTrue(app.waitForElement(card))
        card.tap()

        let menuButton = app.buttons["recipe-detail-menu-button"]
        XCTAssertTrue(app.waitForElement(menuButton))
        menuButton.tap()
        app.buttons["recipe-detail-add-to-meal-plan-button"].tap()

        let cancelButton = app.buttons["meal-plan-calendar-sheet-cancel-button"]
        XCTAssertTrue(app.waitForElement(cancelButton, timeout: 5))

        let todayButton = app.buttons["meal-plan-calendar-sheet-today-button"]
        if todayButton.exists { todayButton.tap() }

        let dateID = Self.todayDateID()
        let addButton = app.buttons["meal-plan-\(dateID)-add-button"]
        XCTAssertTrue(app.waitForElement(addButton, timeout: 3))
        addButton.tap()

        let breakfastButton = app.buttons["Breakfast"]
        XCTAssertTrue(app.waitForElement(breakfastButton, timeout: 3))
        breakfastButton.tap()

        // Wait for sheet to dismiss
        let detailMenu = app.buttons["recipe-detail-menu-button"]
        XCTAssertTrue(app.waitForElement(detailMenu, timeout: 5))

        // Navigate to meal plan tab
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.tapMealPlanTab()

        // Verify entry exists
        let entry = app.staticTexts["Easy Beef Tacos"]
        XCTAssertTrue(app.waitForElement(entry, timeout: 5), "Entry should be visible in meal plan")

        // 2. Long press → Delete from context menu
        entry.press(forDuration: 1.0)

        let deleteButton = app.buttons["Delete"]
        XCTAssertTrue(app.waitForElement(deleteButton, timeout: 3), "Context menu should show Delete option")
        deleteButton.tap()

        // 3. Confirm removal
        let alert = app.alerts.firstMatch
        XCTAssertTrue(app.waitForElement(alert))
        alert.buttons["Remove"].tap()

        // 4. Verify entry is gone
        let deletedEntry = app.staticTexts["Easy Beef Tacos"]
        XCTAssertFalse(deletedEntry.waitForExistence(timeout: 3), "Deleted entry should no longer appear in meal plan")
    }

    // MARK: - Helpers

    private static func todayDateID() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
