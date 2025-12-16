import Foundation

enum Config {
    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("UI_TESTING")
    }

    static var claudeAPIKey: String {
        if isUITesting {
            return "mock-claude-api-key-for-testing"
        }

        if let key = ProcessInfo.processInfo.environment["CLAUDE_API_KEY"], !key.isEmpty {
            return key
        }

        if let key = UserDefaults.standard.string(forKey: "claude_api_key"), !key.isEmpty {
            return key
        }

        fatalError("""
        Claude API key not configured.

        To set the key, run this in your app:
        UserDefaults.standard.set("your-api-key", forKey: "claude_api_key")

        Or set CLAUDE_API_KEY environment variable.
        """)
    }

    static var spoonacularAPIKey: String {
        if isUITesting {
            return "mock-spoonacular-api-key-for-testing"
        }

        if let key = ProcessInfo.processInfo.environment["SPOONACULAR_API_KEY"], !key.isEmpty {
            return key
        }

        if let key = UserDefaults.standard.string(forKey: "spoonacular_api_key"), !key.isEmpty {
            return key
        }

        fatalError("""
        Spoonacular API key not configured.

        To set the key, run this in your app:
        UserDefaults.standard.set("your-api-key", forKey: "spoonacular_api_key")

        Or set SPOONACULAR_API_KEY environment variable.
        """)
    }
}
