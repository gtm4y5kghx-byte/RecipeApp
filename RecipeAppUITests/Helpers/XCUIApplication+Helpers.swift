import XCTest

extension XCUIApplication {

    // MARK: - Tab Navigation

    func tapRecipesTab() {
        tabBars.buttons["tab-recipes"].tap()
    }

    func tapMealPlanTab() {
        tabBars.buttons["tab-meal-plan"].tap()
    }

    func tapShoppingListTab() {
        tabBars.buttons["tab-shopping-list"].tap()
    }

    // MARK: - Wait Helpers

    @discardableResult
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        element.waitForExistence(timeout: timeout)
    }

    // MARK: - Recipe List Helpers

    /// Find a recipe card by its title text. Cards use dynamic UUIDs so we match by label content.
    func recipeCard(titled title: String) -> XCUIElement {
        staticTexts[title].firstMatch
    }

    func openRecipeListMenu() {
        buttons["recipe-list-menu-button"].tap()
    }

    func tapNewRecipe() {
        buttons["menu-new-recipe-button"].tap()
    }

    // MARK: - Recipe Detail Helpers

    func openRecipeDetailMenu() {
        buttons["recipe-detail-menu-button"].tap()
    }

    // MARK: - Search

    func searchFor(_ text: String) {
        swipeDown()
        let searchField = searchFields.firstMatch
        _ = waitForElement(searchField)
        searchField.tap()
        searchField.typeText(text)
    }

    func clearSearch() {
        let searchField = searchFields.firstMatch
        if searchField.exists {
            searchField.buttons["Clear text"].tap()
        }
    }

    // MARK: - Alerts

    /// Tap the destructive action in a confirmation alert (e.g. "Delete")
    func confirmDestructiveAlert() {
        let alert = alerts.firstMatch
        _ = waitForElement(alert)
        // Destructive buttons are typically the first non-cancel button
        let deleteButton = alert.buttons.element(boundBy: 1)
        if deleteButton.exists {
            deleteButton.tap()
        }
    }
}
