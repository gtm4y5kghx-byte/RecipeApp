import Foundation

enum Config {
    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("UI_TESTING")
    }

    static var isTesting: Bool {
        NSClassFromString("XCTestCase") != nil
    }

    static var claudeAPIKey: String {
        if isUITesting {
            return "mock-claude-api-key-for-testing"
        }

        // Primary: read from Info.plist (populated by Secrets.xcconfig)
        if let key = Bundle.main.infoDictionary?["ClaudeAPIKey"] as? String, !key.isEmpty {
            return key
        }

        // Fallback: environment variable (for running integration tests locally)
        if let key = ProcessInfo.processInfo.environment["CLAUDE_API_KEY"], !key.isEmpty {
            return key
        }

        // Unit tests use mocks and don't need a real key
        if isTesting {
            return "test-placeholder-key"
        }

        fatalError("""
        Claude API key not configured.

        Copy Secrets.xcconfig.template to Secrets.xcconfig and add your key.
        Then set the xcconfig in Project > Info > Configurations.
        """)
    }

}
