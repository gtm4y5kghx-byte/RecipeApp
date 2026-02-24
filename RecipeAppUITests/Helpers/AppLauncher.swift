import XCTest

enum AppLauncher {
    /// Launch with empty database (for create flows)
    static func launchClean() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "RESET_USER_DEFAULTS"]
        app.launch()
        return app
    }

    /// Launch with all 22 sample recipes pre-loaded (for search, filter tests)
    static func launchWithSampleData() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "RESET_USER_DEFAULTS", "SEED_SAMPLE_DATA"]
        app.launch()
        return app
    }

    /// Launch with specific recipes only (for targeted tests)
    static func launchWith(recipes: [String]) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "RESET_USER_DEFAULTS"]
        app.launchEnvironment = ["SEED_RECIPES": recipes.joined(separator: ",")]
        app.launch()
        return app
    }
}
