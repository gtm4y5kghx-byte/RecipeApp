import XCTest

final class SettingsViewUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "RESET_USER_DEFAULTS"]
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    // MARK: - Helper Methods

    private func openSettings() {
        let menuButton = app.buttons["recipes-menu-button"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 5), "Menu button should exist")
        menuButton.tap()

        let settingsRow = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Settings'")).firstMatch
        XCTAssertTrue(settingsRow.waitForExistence(timeout: 2), "Settings row should exist")
        settingsRow.tap()

        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 2), "Settings view should open")
    }

    private func closeSettings() {
        let closeButton = app.buttons["settings-close-button"]
        XCTAssertTrue(closeButton.exists, "Close button should exist")
        closeButton.tap()
    }

    // MARK: - Tests

    func testOpenAndCloseSettings() {
        openSettings()

        // Verify settings content is visible
        let cookingModeToggle = app.switches["cooking-mode-toggle"]
        XCTAssertTrue(cookingModeToggle.exists, "Cooking mode toggle should be visible")

        closeSettings()

        // Verify we're back to recipe list
        let menuButton = app.buttons["recipes-menu-button"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 2), "Should return to recipe list")
    }

    func testToggleCookingModeSettingPersists() {
        openSettings()

        let cookingModeToggle = app.switches["cooking-mode-toggle"]
        XCTAssertTrue(cookingModeToggle.exists, "Cooking mode toggle should exist")

        let defaultValue = cookingModeToggle.value as! String
        XCTAssertEqual(defaultValue, "1", "Cooking mode should default to ON")

        cookingModeToggle.tap()

        closeSettings()
        openSettings()

        let persistedValue = app.switches["cooking-mode-toggle"].value as! String
        XCTAssertEqual(persistedValue, "0", "Cooking mode OFF state should persist")
    }

    func testToggleViewingRecipesSettingPersists() {
        openSettings()

        let viewingRecipesToggle = app.switches["viewing-recipes-toggle"]
        XCTAssertTrue(viewingRecipesToggle.exists, "Viewing recipes toggle should exist")

        let defaultValue = viewingRecipesToggle.value as! String
        XCTAssertEqual(defaultValue, "0", "Viewing recipes should default to OFF")

        viewingRecipesToggle.tap()

        closeSettings()
        openSettings()

        let persistedValue = app.switches["viewing-recipes-toggle"].value as! String
        XCTAssertEqual(persistedValue, "1", "Viewing recipes ON state should persist")
    }

    func testSubscriptionSectionDisplays() {
        openSettings()

        // Scroll to subscription section if needed
        let subscriptionLabel = app.staticTexts["Subscription"]
        if !subscriptionLabel.isHittable {
            app.swipeUp()
        }

        XCTAssertTrue(subscriptionLabel.exists, "Subscription section should exist")

        // Check for either free or premium status
        let freeStatusExists = app.staticTexts["Free Plan"].exists
        let premiumStatusExists = app.staticTexts["Premium"].exists

        XCTAssertTrue(freeStatusExists || premiumStatusExists, "Should show either free or premium status")

        // Verify appropriate button exists
        if freeStatusExists {
            let upgradeButton = app.buttons["upgrade-premium-button"]
            XCTAssertTrue(upgradeButton.exists, "Upgrade button should exist for free users")
        } else {
            let manageButton = app.buttons["manage-subscription-button"]
            XCTAssertTrue(manageButton.exists, "Manage subscription button should exist for premium users")
        }
    }
}
