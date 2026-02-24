import XCTest

final class MadeItTests: XCTestCase {

    func testMadeItIncrementsCounter() throws {
        // tacos has timesCooked = 0
        let app = AppLauncher.launchWith(recipes: ["tacos"])

        let card = app.recipeCard(titled: "Easy Beef Tacos")
        XCTAssertTrue(app.waitForElement(card))
        card.tap()

        // Wait for detail to load
        let cookedButton = app.buttons["recipe-detail-cooked-button"]
        XCTAssertTrue(app.waitForElement(cookedButton))

        // Tap "Made It"
        cookedButton.tap()

        // Counter should now show 1
        let counter = app.staticTexts["1"]
        XCTAssertTrue(counter.waitForExistence(timeout: 2), "Counter should appear after first tap of Made It")
    }

    func testMadeItMultipleTaps() throws {
        // pasta has timesCooked = 0
        let app = AppLauncher.launchWith(recipes: ["pasta"])

        let card = app.recipeCard(titled: "Garlic Butter Pasta")
        XCTAssertTrue(app.waitForElement(card))
        card.tap()

        let cookedButton = app.buttons["recipe-detail-cooked-button"]
        XCTAssertTrue(app.waitForElement(cookedButton))

        // Tap twice
        cookedButton.tap()
        sleep(1)
        cookedButton.tap()

        // Counter should show 2
        let counter = app.staticTexts["2"]
        XCTAssertTrue(counter.waitForExistence(timeout: 2), "Counter should show 2 after tapping Made It twice")
    }
}
