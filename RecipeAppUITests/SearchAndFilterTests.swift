import XCTest

final class SearchAndFilterTests: XCTestCase {

    // MARK: - Search

    func testSearchByTitle() throws {
        let app = AppLauncher.launchWithSampleData()

        app.searchFor("Pad Thai")

        let matchingCard = app.recipeCard(titled: "Pad Thai")
        XCTAssertTrue(app.waitForElement(matchingCard), "Search should find Pad Thai")

        // A non-matching recipe should not be visible
        let nonMatching = app.recipeCard(titled: "Grandma's Apple Pie")
        XCTAssertFalse(nonMatching.exists, "Non-matching recipe should not be visible during search")
    }

    func testSearchCaseInsensitive() throws {
        let app = AppLauncher.launchWithSampleData()

        // Search in lowercase for a recipe with mixed case title
        app.searchFor("french onion soup")

        let card = app.recipeCard(titled: "French Onion Soup")
        XCTAssertTrue(app.waitForElement(card), "Case-insensitive search should find the recipe")
    }

    func testClearSearch() throws {
        let app = AppLauncher.launchWithSampleData()

        // Search to filter down
        app.searchFor("Chocolate Cake")

        let cake = app.recipeCard(titled: "Simple Chocolate Cake")
        XCTAssertTrue(app.waitForElement(cake))

        // Clear search
        app.clearSearch()

        // Cancel the search (tap Cancel button to dismiss search)
        let cancelButton = app.buttons["Cancel"]
        if cancelButton.exists {
            cancelButton.tap()
        }

        // Other recipes should reappear
        let pie = app.recipeCard(titled: "Grandma's Apple Pie")
        XCTAssertTrue(app.waitForElement(pie, timeout: 3), "All recipes should be restored after clearing search")
    }

    // MARK: - Filters

    func testFilterByFavorites() throws {
        let app = AppLauncher.launchWithSampleData()

        // apple_pie is already isFavorite = true in sample data
        // Open menu → Favorites filter
        app.openRecipeListMenu()
        let favoritesFilter = app.buttons["menu-filter-favorites"]
        if !favoritesFilter.exists {
            app.staticTexts["Favorites"].tap()
        } else {
            favoritesFilter.tap()
        }

        // Verify a known favorite recipe is shown
        let filteredCard = app.recipeCard(titled: "Grandma's Apple Pie")
        XCTAssertTrue(app.waitForElement(filteredCard, timeout: 3), "Favorited recipe should appear in favorites filter")
    }

    func testFilterByRecentlyCooked() throws {
        let app = AppLauncher.launchWithSampleData()

        // Open menu → Recently Cooked filter
        app.openRecipeListMenu()
        let recentFilter = app.buttons["menu-filter-recently-cooked"]
        if !recentFilter.exists {
            app.staticTexts["Recently Cooked"].tap()
        } else {
            recentFilter.tap()
        }

        // The navigation title should reflect the filter
        // (We can't assert exact count since sample data may or may not have recently cooked recipes)
        // Just verify the filter was applied by checking for the clear filter button
        let clearButton = app.buttons["clear-filter-button"]
        XCTAssertTrue(app.waitForElement(clearButton, timeout: 3), "Clear filter button should appear when a filter is active")
    }

    func testClearFilter() throws {
        let app = AppLauncher.launchWithSampleData()

        // Apply a filter first
        app.openRecipeListMenu()
        let favoritesFilter = app.buttons["menu-filter-favorites"]
        if !favoritesFilter.exists {
            app.staticTexts["Favorites"].tap()
        } else {
            favoritesFilter.tap()
        }

        // Verify clear filter button exists
        let clearButton = app.buttons["clear-filter-button"]
        XCTAssertTrue(app.waitForElement(clearButton, timeout: 3))

        // Tap it to clear the filter
        clearButton.tap()

        // All recipes should be shown again
        let card = app.recipeCard(titled: "Grandma's Apple Pie")
        XCTAssertTrue(app.waitForElement(card, timeout: 3), "All recipes should be visible after clearing filter")
    }
}
