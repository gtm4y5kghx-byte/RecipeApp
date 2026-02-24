import XCTest

final class FavoritesTests: XCTestCase {

    // MARK: - Toggle from Detail

    func testToggleFavoriteFromDetail() throws {
        let app = AppLauncher.launchWith(recipes: ["tacos"])

        // Navigate to a non-favorited recipe
        let card = app.recipeCard(titled: "Easy Beef Tacos")
        XCTAssertTrue(app.waitForElement(card))
        card.tap()

        // Wait for detail to load
        let favoriteButton = app.buttons["recipe-detail-favorite-button"]
        XCTAssertTrue(app.waitForElement(favoriteButton))

        // Toggle favorite on
        favoriteButton.tap()

        // The heart icon should now be filled (heart.fill)
        let filledHeart = app.images["heart.fill"]
        XCTAssertTrue(filledHeart.waitForExistence(timeout: 2), "Heart should be filled after favoriting")

        // Toggle favorite off
        favoriteButton.tap()

        // Heart should be outline again
        let outlineHeart = app.images["heart"]
        XCTAssertTrue(outlineHeart.waitForExistence(timeout: 2), "Heart should be outline after unfavoriting")
    }

    // MARK: - Favorite persists when returning to list

    func testFavoritePersistsInList() throws {
        let app = AppLauncher.launchWith(recipes: ["chocolate_cake"])

        // Navigate to recipe and favorite it
        let card = app.recipeCard(titled: "Simple Chocolate Cake")
        XCTAssertTrue(app.waitForElement(card))
        card.tap()

        let favoriteButton = app.buttons["recipe-detail-favorite-button"]
        XCTAssertTrue(app.waitForElement(favoriteButton))
        favoriteButton.tap()

        // Go back to list
        app.navigationBars.buttons.element(boundBy: 0).tap()

        // Verify by filtering to favorites
        app.openRecipeListMenu()

        let favoritesFilter = app.buttons["menu-filter-favorites"]
        if !favoritesFilter.exists {
            app.staticTexts["Favorites"].tap()
        } else {
            favoritesFilter.tap()
        }

        // Verify the favorited recipe appears under favorites filter
        let filteredCard = app.recipeCard(titled: "Simple Chocolate Cake")
        XCTAssertTrue(app.waitForElement(filteredCard, timeout: 3), "Favorited recipe should appear in favorites filter")
    }

    // MARK: - Filter shows only favorites

    func testFilterShowsOnlyFavorites() throws {
        let app = AppLauncher.launchWith(recipes: ["quick_omelette", "tacos"])

        // Favorite the omelette
        let card = app.recipeCard(titled: "Quick Cheese Omelette")
        XCTAssertTrue(app.waitForElement(card))
        card.tap()

        let favoriteButton = app.buttons["recipe-detail-favorite-button"]
        XCTAssertTrue(app.waitForElement(favoriteButton))
        favoriteButton.tap()

        // Go back
        app.navigationBars.buttons.element(boundBy: 0).tap()

        // Apply favorites filter
        app.openRecipeListMenu()
        let favoritesFilter = app.buttons["menu-filter-favorites"]
        if !favoritesFilter.exists {
            app.staticTexts["Favorites"].tap()
        } else {
            favoritesFilter.tap()
        }

        // Quick Cheese Omelette should be shown
        let favorited = app.recipeCard(titled: "Quick Cheese Omelette")
        XCTAssertTrue(app.waitForElement(favorited, timeout: 3), "Favorited recipe should be in filter results")

        // Easy Beef Tacos should not be shown
        let nonFavorited = app.recipeCard(titled: "Easy Beef Tacos")
        XCTAssertFalse(nonFavorited.exists, "Non-favorited recipe should not appear in favorites filter")
    }
}
