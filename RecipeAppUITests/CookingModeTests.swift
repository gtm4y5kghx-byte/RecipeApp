import XCTest

final class CookingModeTests: XCTestCase {

    // MARK: - Start Cooking Mode

    func testStartCookingMode() throws {
        let app = AppLauncher.launchWith(recipes: ["apple_pie"])

        let card = app.recipeCard(titled: "Grandma's Apple Pie")
        XCTAssertTrue(app.waitForElement(card))
        card.tap()

        // Menu → Start Cooking
        let menuButton = app.buttons["recipe-detail-menu-button"]
        XCTAssertTrue(app.waitForElement(menuButton))
        menuButton.tap()
        app.buttons["recipe-detail-start-cooking-button"].tap()

        // Verify cooking mode is presented
        let closeButton = app.buttons["cooking-mode-close-button"]
        XCTAssertTrue(app.waitForElement(closeButton, timeout: 3), "Cooking mode should be presented")
    }

    // MARK: - Cannot Start Without Instructions

    func testCookingModeCannotStartWithoutInstructions() throws {
        let app = AppLauncher.launchWith(recipes: ["untitled_draft"])

        let card = app.recipeCard(titled: "Untitled Draft")
        XCTAssertTrue(app.waitForElement(card))
        card.tap()

        // Menu → Start Cooking
        let menuButton = app.buttons["recipe-detail-menu-button"]
        XCTAssertTrue(app.waitForElement(menuButton))
        menuButton.tap()
        app.buttons["recipe-detail-start-cooking-button"].tap()

        // Cooking mode should NOT appear
        let closeButton = app.buttons["cooking-mode-close-button"]
        XCTAssertFalse(closeButton.waitForExistence(timeout: 2), "Cooking mode should not open for a recipe without instructions")

        let detailMenu = app.buttons["recipe-detail-menu-button"]
        XCTAssertTrue(detailMenu.exists, "Should remain on detail view")
    }

    // MARK: - Step Navigation via Steps Sheet

    func testCookingModeStepNavigation() throws {
        let app = AppLauncher.launchWith(recipes: ["apple_pie"])

        let card = app.recipeCard(titled: "Grandma's Apple Pie")
        XCTAssertTrue(app.waitForElement(card))
        card.tap()

        let menuButton = app.buttons["recipe-detail-menu-button"]
        XCTAssertTrue(app.waitForElement(menuButton))
        menuButton.tap()
        app.buttons["recipe-detail-start-cooking-button"].tap()

        // Open cooking mode menu → Steps
        let cookingMenuButton = app.buttons["cooking-mode-menu-button"]
        XCTAssertTrue(app.waitForElement(cookingMenuButton, timeout: 3))
        cookingMenuButton.tap()
        app.buttons["cooking-mode-steps-button"].tap()

        let doneButton = app.buttons["cooking-mode-steps-done-button"]
        XCTAssertTrue(app.waitForElement(doneButton, timeout: 3), "Steps sheet should open with Done button")
        doneButton.tap()
    }

    // MARK: - Ingredients Sheet

    func testCookingModeIngredientsSheet() throws {
        let app = AppLauncher.launchWith(recipes: ["apple_pie"])

        let card = app.recipeCard(titled: "Grandma's Apple Pie")
        XCTAssertTrue(app.waitForElement(card))
        card.tap()

        let menuButton = app.buttons["recipe-detail-menu-button"]
        XCTAssertTrue(app.waitForElement(menuButton))
        menuButton.tap()
        app.buttons["recipe-detail-start-cooking-button"].tap()

        // Open cooking mode menu → Ingredients
        let cookingMenuButton = app.buttons["cooking-mode-menu-button"]
        XCTAssertTrue(app.waitForElement(cookingMenuButton, timeout: 3))
        cookingMenuButton.tap()
        app.buttons["cooking-mode-ingredients-button"].tap()

        let doneButton = app.buttons["cooking-mode-ingredients-done-button"]
        XCTAssertTrue(app.waitForElement(doneButton, timeout: 3), "Ingredients sheet should open")
        doneButton.tap()
    }

    // MARK: - Exit Cooking Mode

    func testCookingModeExit() throws {
        let app = AppLauncher.launchWith(recipes: ["apple_pie"])

        let card = app.recipeCard(titled: "Grandma's Apple Pie")
        XCTAssertTrue(app.waitForElement(card))
        card.tap()

        let menuButton = app.buttons["recipe-detail-menu-button"]
        XCTAssertTrue(app.waitForElement(menuButton))
        menuButton.tap()
        app.buttons["recipe-detail-start-cooking-button"].tap()

        let closeButton = app.buttons["cooking-mode-close-button"]
        XCTAssertTrue(app.waitForElement(closeButton, timeout: 3))
        closeButton.tap()

        let detailMenu = app.buttons["recipe-detail-menu-button"]
        XCTAssertTrue(app.waitForElement(detailMenu, timeout: 3), "Should return to recipe detail after closing cooking mode")
    }
}
