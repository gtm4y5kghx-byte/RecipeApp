import XCTest

/// Smoke tests that verify the app doesn't crash when navigating to each major view.
/// These don't assert behavior — just that views load without crashing.
final class NavigationSmokeTests: XCTestCase {

    // MARK: - Tab Navigation

    func testNavigateToAllTabs() throws {
        let app = AppLauncher.launchWith(recipes: ["apple_pie"])

        // Recipes tab (default)
        let recipeListMenu = app.buttons["recipe-list-menu-button"]
        XCTAssertTrue(app.waitForElement(recipeListMenu), "Recipes tab should load")

        // Meal Plan tab
        app.tapMealPlanTab()
        let mealPlanToday = app.buttons["meal-plan-today-button"]
        XCTAssertTrue(app.waitForElement(mealPlanToday, timeout: 3), "Meal Plan tab should load")

        // Shopping List tab
        app.tapShoppingListTab()
        let addField = app.textFields["shopping-list-add-item-field"]
        XCTAssertTrue(app.waitForElement(addField, timeout: 3), "Shopping List tab should load")

        // Back to Recipes
        app.tapRecipesTab()
        XCTAssertTrue(app.waitForElement(recipeListMenu), "Should return to Recipes tab")
    }

    // MARK: - Recipe Detail

    func testNavigateToRecipeDetail() throws {
        let app = AppLauncher.launchWith(recipes: ["apple_pie"])

        let card = app.recipeCard(titled: "Grandma's Apple Pie")
        XCTAssertTrue(app.waitForElement(card))
        card.tap()

        let menuButton = app.buttons["recipe-detail-menu-button"]
        XCTAssertTrue(app.waitForElement(menuButton, timeout: 3), "Recipe detail should load")
    }

    // MARK: - Recipe Form

    func testNavigateToRecipeForm() throws {
        let app = AppLauncher.launchClean()

        app.openRecipeListMenu()
        app.tapNewRecipe()

        let titleField = app.textFields["recipe-form-title-field"]
        XCTAssertTrue(app.waitForElement(titleField, timeout: 3), "Recipe form should load")

        // Dismiss
        app.buttons["recipe-form-cancel-button"].tap()
    }

    // MARK: - Settings

    func testNavigateToSettings() throws {
        let app = AppLauncher.launchClean()

        app.openRecipeListMenu()
        app.buttons["menu-settings-button"].tap()

        let closeButton = app.buttons["settings-close-button"]
        XCTAssertTrue(app.waitForElement(closeButton, timeout: 3), "Settings should load")

        closeButton.tap()
    }

    // MARK: - Tag Filter

    func testFilterByTag() throws {
        // apple_pie has tag "Dessert", tacos has tag "Dinner"
        let app = AppLauncher.launchWith(recipes: ["apple_pie", "tacos"])

        // Open menu and tap a tag
        app.openRecipeListMenu()

        // "Dessert" tag — accessibility ID is "menu-tag-tag-Dessert"
        let tagButton = app.buttons["menu-tag-tag-Dessert"]
        if !tagButton.exists {
            // Fallback: find by label text
            app.staticTexts["Dessert"].tap()
        } else {
            tagButton.tap()
        }

        // App should not crash; clear filter button should appear
        let clearButton = app.buttons["clear-filter-button"]
        XCTAssertTrue(app.waitForElement(clearButton, timeout: 3), "Tag filter should be applied")

        // Clear it
        clearButton.tap()

        // Both recipes should be visible again
        let card = app.recipeCard(titled: "Easy Beef Tacos")
        XCTAssertTrue(app.waitForElement(card, timeout: 3), "All recipes should be visible after clearing tag filter")
    }

    // MARK: - All Menu Filters (Smoke)

    func testAllMenuFiltersDoNotCrash() throws {
        // Need favorites (apple_pie, grilled_cheese) and recently cooked (grilled_cheese)
        let app = AppLauncher.launchWith(recipes: ["apple_pie", "grilled_cheese", "tacos"])

        let filterIDs = [
            "menu-filter-all",
            "menu-filter-recently-added",
            "menu-filter-recently-cooked",
            "menu-filter-favorites",
            "menu-filter-uncategorized"
        ]

        for filterID in filterIDs {
            app.openRecipeListMenu()

            let filterButton = app.buttons[filterID]
            if filterButton.waitForExistence(timeout: 2) {
                filterButton.tap()
            }

            // Brief pause to let the view settle
            sleep(1)
        }

        // If we made it here without crashing, all filters are safe
        let recipeListMenu = app.buttons["recipe-list-menu-button"]
        XCTAssertTrue(recipeListMenu.exists, "App should still be responsive after cycling through all filters")
    }
}
