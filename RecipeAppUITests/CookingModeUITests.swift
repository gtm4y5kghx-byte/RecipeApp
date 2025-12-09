import XCTest

final class CookingModeUITests: BaseUITestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()

        createRecipeWithProperties(
            title: "Test Cooking Recipe",
            ingredients: ["Ingredient 1", "Ingredient 2"],
            instructions: ["Step 1 instruction", "Step 2 instruction", "Step 3 instruction"]
        )

        let recipeTitle = app.staticTexts["Test Cooking Recipe"]
        recipeTitle.tap()

        let startCookingButton = app.buttons["start-cooking-button"]
        startCookingButton.tap()
    }

    func testNavigateForwardThroughSteps() throws {
        XCTAssertTrue(app.staticTexts["Step 1 of 3"].exists)

        let nextButton = app.buttons["next-step-button"]
        XCTAssertTrue(nextButton.exists)

        nextButton.tap()
        XCTAssertTrue(app.staticTexts["Step 2 of 3"].waitForExistence(timeout: 2))

        nextButton.tap()
        XCTAssertTrue(app.staticTexts["Step 3 of 3"].waitForExistence(timeout: 2))

        XCTAssertFalse(nextButton.exists)
    }

    func testNavigateBackwardThroughSteps() throws {
        let nextButton = app.buttons["next-step-button"]
        nextButton.tap()
        XCTAssertTrue(app.staticTexts["Step 2 of 3"].waitForExistence(timeout: 2))

        let previousButton = app.buttons["previous-step-button"]
        XCTAssertTrue(previousButton.exists)
        XCTAssertTrue(previousButton.isEnabled)

        previousButton.tap()
        XCTAssertTrue(app.staticTexts["Step 1 of 3"].waitForExistence(timeout: 2))

        XCTAssertFalse(previousButton.isEnabled)
    }

    func testMarkAsCookedOnFinalStep() throws {
        let nextButton = app.buttons["next-step-button"]

        nextButton.tap()
        nextButton.tap()

        XCTAssertTrue(app.staticTexts["Step 3 of 3"].waitForExistence(timeout: 2))

        XCTAssertFalse(nextButton.exists)

        let markAsCookedButton = app.buttons["mark-as-cooked-button"]
        XCTAssertTrue(markAsCookedButton.exists)

        markAsCookedButton.tap()

        XCTAssertTrue(app.staticTexts["Test Cooking Recipe"].waitForExistence(timeout: 2))

        XCTAssertTrue(app.staticTexts["Cooked 1 time"].exists)
    }

    func testExitCookingMode() throws {
        let exitButton = app.buttons["exit-cooking-mode-button"]
        XCTAssertTrue(exitButton.exists)

        exitButton.tap()

        XCTAssertTrue(app.staticTexts["Test Cooking Recipe"].waitForExistence(timeout: 2))

        XCTAssertTrue(app.staticTexts["Never cooked"].exists)
    }

    func testReferenceSheetOpens() throws {
        let referenceButton = app.buttons["reference-button"]
        XCTAssertTrue(referenceButton.exists)

        referenceButton.tap()

        XCTAssertTrue(app.staticTexts["Quick Reference"].waitForExistence(timeout: 2))

        XCTAssertTrue(app.staticTexts["Ingredients"].exists)
        XCTAssertTrue(app.staticTexts["Ingredient 1"].exists)

        let disclosureGroup = app.buttons["All Steps (3)"]
        XCTAssertTrue(disclosureGroup.exists)

        disclosureGroup.tap()

        let step1Container = app.otherElements["reference-step-0"]
        XCTAssertTrue(step1Container.exists)
        XCTAssertTrue(step1Container.staticTexts["Step 1 instruction"].exists)
        XCTAssertTrue(step1Container.images["current-step-indicator"].exists)

        let step2Container = app.otherElements["reference-step-1"]
        XCTAssertTrue(step2Container.exists)
        XCTAssertTrue(step2Container.staticTexts["Step 2 instruction"].exists)
        XCTAssertFalse(step2Container.images["current-step-indicator"].exists)

        let step3Container = app.otherElements["reference-step-2"]
        XCTAssertTrue(step3Container.exists)
        XCTAssertTrue(step3Container.staticTexts["Step 3 instruction"].exists)
        XCTAssertFalse(step3Container.images["current-step-indicator"].exists)

        let closeButton = app.buttons["Close"]
        closeButton.tap()

        XCTAssertTrue(app.staticTexts["Step 1 of 3"].waitForExistence(timeout: 2))
    }
}
