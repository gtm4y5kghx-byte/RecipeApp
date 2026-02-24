import XCTest

final class ShoppingListTests: XCTestCase {

    // MARK: - Add Ingredients from Recipe

    func testAddIngredientsFromRecipe() throws {
        let app = AppLauncher.launchWith(recipes: ["apple_pie"])

        // Navigate to a recipe with ingredients
        let card = app.recipeCard(titled: "Grandma's Apple Pie")
        XCTAssertTrue(app.waitForElement(card))
        card.tap()

        // Wait for detail
        let menuButton = app.buttons["recipe-detail-menu-button"]
        XCTAssertTrue(app.waitForElement(menuButton))

        // Menu → Add to Shopping List
        menuButton.tap()
        app.buttons["recipe-detail-add-to-shopping-list-button"].tap()

        // Wait briefly for the action to complete (toast should appear)
        sleep(1)

        // Switch to Shopping List tab
        app.tapShoppingListTab()

        // Verify items are present (shopping list should NOT be empty)
        let emptyState = app.otherElements["shopping-list-empty-state"]
        XCTAssertFalse(emptyState.waitForExistence(timeout: 2), "Shopping list should not be empty after adding ingredients")
    }

    // MARK: - Add Manual Item

    func testAddManualItem() throws {
        let app = AppLauncher.launchClean()

        // Go to Shopping List tab
        app.tapShoppingListTab()

        // Type item and submit
        let addField = app.textFields["shopping-list-add-item-field"]
        XCTAssertTrue(app.waitForElement(addField))
        addField.tap()
        addField.typeText("Organic Milk")

        // Submit via keyboard
        app.keyboards.buttons["done"].tap()

        // Verify item appears
        let item = app.staticTexts["Organic Milk"]
        XCTAssertTrue(app.waitForElement(item), "Manual item should appear in shopping list")
    }

    // MARK: - Check Off Item

    func testCheckOffItem() throws {
        let app = AppLauncher.launchClean()
        app.tapShoppingListTab()

        // Add an item first
        let addField = app.textFields["shopping-list-add-item-field"]
        XCTAssertTrue(app.waitForElement(addField))
        addField.tap()
        addField.typeText("Eggs")
        app.keyboards.buttons["done"].tap()

        // Wait for item to appear
        let item = app.staticTexts["Eggs"]
        XCTAssertTrue(app.waitForElement(item))

        // Find and tap the checkbox (it's the first button in the item's row)
        // Shopping list items have checkboxes with IDs like "shopping-list-item-{id}-checkbox"
        // Since we don't know the UUID, find the row containing "Eggs" and tap its checkbox
        let itemRow = app.cells.containing(.staticText, identifier: "Eggs").firstMatch
        if itemRow.exists {
            // Tap the checkbox image/button within the row
            let checkbox = itemRow.buttons.firstMatch
            checkbox.tap()
        }

        // The item should still be visible but in a checked state
        XCTAssertTrue(item.exists, "Checked item should still be visible")
    }

    // MARK: - Clear Checked Items

    func testClearCheckedItems() throws {
        let app = AppLauncher.launchClean()
        app.tapShoppingListTab()

        // Add two items
        let addField = app.textFields["shopping-list-add-item-field"]
        XCTAssertTrue(app.waitForElement(addField))

        addField.tap()
        addField.typeText("Butter")
        app.keyboards.buttons["done"].tap()
        sleep(1)

        addField.tap()
        addField.typeText("Sugar")
        app.keyboards.buttons["done"].tap()
        sleep(1)

        // Check off "Butter"
        let butterRow = app.cells.containing(.staticText, identifier: "Butter").firstMatch
        if butterRow.exists {
            butterRow.buttons.firstMatch.tap()
        }

        // Menu → Clear Checked
        app.buttons["shopping-list-menu-button"].tap()
        app.buttons["shopping-list-clear-checked-button"].tap()

        // "Sugar" should remain, "Butter" should be gone
        sleep(1)
        let sugar = app.staticTexts["Sugar"]
        let butter = app.staticTexts["Butter"]
        XCTAssertTrue(sugar.exists, "Unchecked item should remain")
        XCTAssertFalse(butter.exists, "Checked item should be cleared")
    }

    // MARK: - Clear All Items

    func testClearAllItems() throws {
        let app = AppLauncher.launchClean()
        app.tapShoppingListTab()

        // Add an item
        let addField = app.textFields["shopping-list-add-item-field"]
        XCTAssertTrue(app.waitForElement(addField))
        addField.tap()
        addField.typeText("Flour")
        app.keyboards.buttons["done"].tap()

        let item = app.staticTexts["Flour"]
        XCTAssertTrue(app.waitForElement(item))

        // Menu → Clear All → Confirm
        app.buttons["shopping-list-menu-button"].tap()
        app.buttons["shopping-list-clear-all-button"].tap()

        // Confirm the alert if one appears
        let alert = app.alerts.firstMatch
        if alert.waitForExistence(timeout: 2) {
            // Tap the destructive confirmation button
            let confirmButton = alert.buttons.element(boundBy: 1)
            if confirmButton.exists {
                confirmButton.tap()
            }
        }

        // Verify empty state
        let emptyState = app.otherElements["shopping-list-empty-state"]
        XCTAssertTrue(app.waitForElement(emptyState, timeout: 3), "Shopping list should show empty state after clearing all")
    }
}
