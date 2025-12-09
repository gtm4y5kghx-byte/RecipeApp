import XCTest

final class RecipeFilterUITests: BaseUITestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()

        createRecipeWithProperties(
            title: "Old Recipe",
            ingredients: ["ingredient"],
            instructions: ["step 1"]
        )

        createRecipeWithProperties(
            title: "Favorite Pasta",
            ingredients: ["pasta"],
            instructions: ["boil water"],
            isFavorite: true
        )

        createRecipeWithProperties(
            title: "Cooked Recipe",
            ingredients: ["rice"],
            instructions: ["cook rice"],
            markAsCooked: true
        )

        createRecipeWithProperties(
            title: "Tagged Recipe",
            ingredients: ["chicken"],
            instructions: ["cook chicken"],
            tags: ["Weeknight"]
        )

        createRecipeWithProperties(
            title: "Recent Recipe",
            ingredients: ["bread"],
            instructions: ["toast bread"]
        )
    }

    func testFilterByAll() throws {
        let filterButton = app.buttons["filter-button"]
        filterButton.tap()

        let allFilter = app.buttons.containing(NSPredicate(format: "label CONTAINS 'ALL'")).firstMatch
        XCTAssertTrue(allFilter.waitForExistence(timeout: 2))
        XCTAssertTrue(allFilter.images["checkmark"].exists)

        let closeButton = app.buttons["Close"]
        closeButton.tap()

        XCTAssertTrue(app.staticTexts["Old Recipe"].exists)
        XCTAssertTrue(app.staticTexts["Favorite Pasta"].exists)
        XCTAssertTrue(app.staticTexts["Cooked Recipe"].exists)
        XCTAssertTrue(app.staticTexts["Tagged Recipe"].exists)
        XCTAssertTrue(app.staticTexts["Recent Recipe"].exists)
    }

    func testFilterByFavorites() throws {
        let filterButton = app.buttons["filter-button"]
        filterButton.tap()

        let favoritesFilter = app.buttons.containing(NSPredicate(format: "label CONTAINS 'FAVORITES'")).firstMatch
        XCTAssertTrue(favoritesFilter.waitForExistence(timeout: 2))
        favoritesFilter.tap()

        XCTAssertTrue(app.staticTexts["Favorite Pasta"].exists)
        XCTAssertFalse(app.staticTexts["Old Recipe"].exists)
        XCTAssertFalse(app.staticTexts["Cooked Recipe"].exists)
        XCTAssertFalse(app.staticTexts["Tagged Recipe"].exists)
        XCTAssertFalse(app.staticTexts["Recent Recipe"].exists)
    }

    func testFilterByRecentlyCooked() throws {
        let filterButton = app.buttons["filter-button"]
        filterButton.tap()

        let recentlyCookedFilter = app.buttons.containing(NSPredicate(format: "label CONTAINS 'RECENTLY COOKED'")).firstMatch
        XCTAssertTrue(recentlyCookedFilter.waitForExistence(timeout: 2))
        recentlyCookedFilter.tap()

        XCTAssertTrue(app.staticTexts["Cooked Recipe"].exists)
        XCTAssertFalse(app.staticTexts["Old Recipe"].exists)
        XCTAssertFalse(app.staticTexts["Favorite Pasta"].exists)
        XCTAssertFalse(app.staticTexts["Tagged Recipe"].exists)
        XCTAssertFalse(app.staticTexts["Recent Recipe"].exists)
    }

    func testFilterByUncategorized() throws {
        let filterButton = app.buttons["filter-button"]
        filterButton.tap()

        let uncategorizedFilter = app.buttons.containing(NSPredicate(format: "label CONTAINS 'UNCATEGORIZED'")).firstMatch
        XCTAssertTrue(uncategorizedFilter.waitForExistence(timeout: 2))
        uncategorizedFilter.tap()

        XCTAssertTrue(app.staticTexts["Old Recipe"].exists)
        XCTAssertTrue(app.staticTexts["Favorite Pasta"].exists)
        XCTAssertTrue(app.staticTexts["Cooked Recipe"].exists)
        XCTAssertTrue(app.staticTexts["Recent Recipe"].exists)
        XCTAssertFalse(app.staticTexts["Tagged Recipe"].exists)
    }

    func testFilterByTag() throws {
        let filterButton = app.buttons["filter-button"]
        filterButton.tap()
        
        let allFilter = app.buttons.containing(NSPredicate(format: "label CONTAINS 'ALL'")).firstMatch
        XCTAssertTrue(allFilter.waitForExistence(timeout: 2))
        
        app.expandSheet()

        let weeknightFilter = app.buttons.containing(NSPredicate(format: "label CONTAINS 'WEEKNIGHT'")).firstMatch
        XCTAssertTrue(weeknightFilter.waitForExistence(timeout: 2))
        weeknightFilter.tap()

        XCTAssertTrue(app.staticTexts["Tagged Recipe"].exists)
        XCTAssertFalse(app.staticTexts["Old Recipe"].exists)
        XCTAssertFalse(app.staticTexts["Favorite Pasta"].exists)
        XCTAssertFalse(app.staticTexts["Cooked Recipe"].exists)
        XCTAssertFalse(app.staticTexts["Recent Recipe"].exists)
    }

    func testFilterShowsRecipeCounts() throws {
        let filterButton = app.buttons["filter-button"]
        filterButton.tap()

        let allFilter = app.buttons.containing(NSPredicate(format: "label CONTAINS 'ALL'")).firstMatch
        XCTAssertTrue(allFilter.waitForExistence(timeout: 2))
        XCTAssertTrue(allFilter.staticTexts["5"].exists)
        
        app.expandSheet()

        let favoritesFilter = app.buttons.containing(NSPredicate(format: "label CONTAINS 'FAVORITES'")).firstMatch
        XCTAssertTrue(favoritesFilter.staticTexts["1"].exists)

        let uncategorizedFilter = app.buttons.containing(NSPredicate(format: "label CONTAINS 'UNCATEGORIZED'")).firstMatch
        XCTAssertTrue(uncategorizedFilter.staticTexts["4"].exists)

        let weeknightFilter = app.buttons.containing(NSPredicate(format: "label CONTAINS 'WEEKNIGHT'")).firstMatch
        XCTAssertTrue(weeknightFilter.waitForExistence(timeout: 2))
        XCTAssertTrue(weeknightFilter.staticTexts["1"].exists)
    }

    func testFilterByTagShowsCount() throws {
        let filterButton = app.buttons["filter-button"]
        filterButton.tap()

        let allFilter = app.buttons.containing(NSPredicate(format: "label CONTAINS 'ALL'")).firstMatch
        XCTAssertTrue(allFilter.waitForExistence(timeout: 2))
        
        app.expandSheet()

        let weeknightFilter = app.buttons.containing(NSPredicate(format: "label CONTAINS 'WEEKNIGHT'")).firstMatch
        XCTAssertTrue(weeknightFilter.waitForExistence(timeout: 2))
        XCTAssertTrue(weeknightFilter.staticTexts["1"].exists)
    }
}
