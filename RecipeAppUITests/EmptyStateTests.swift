import XCTest

/// Verify empty states render correctly when there's no data.
/// Catches nil/empty data crashes in SwiftUI body computation.
final class EmptyStateTests: XCTestCase {

    func testRecipeListEmptyState() throws {
        let app = AppLauncher.launchClean()

        let emptyState = app.otherElements["recipe-list-empty-state"]
        XCTAssertTrue(app.waitForElement(emptyState, timeout: 3), "Recipe list should show empty state with no recipes")
    }

    func testShoppingListEmptyState() throws {
        let app = AppLauncher.launchClean()

        app.tapShoppingListTab()

        let emptyState = app.otherElements["shopping-list-empty-state"]
        XCTAssertTrue(app.waitForElement(emptyState, timeout: 3), "Shopping list should show empty state with no items")
    }

    func testMealPlanLoadsEmpty() throws {
        let app = AppLauncher.launchClean()

        app.tapMealPlanTab()

        // Meal plan shows a calendar with empty date rows (no dedicated empty state).
        // Just verify it loads without crashing.
        let todayButton = app.buttons["meal-plan-today-button"]
        XCTAssertTrue(app.waitForElement(todayButton, timeout: 3), "Meal plan should load with no entries")
    }
}
