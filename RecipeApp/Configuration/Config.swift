import Foundation

enum Config {
    /// Claude API key for search parsing
    /// Set via: UserDefaults.standard.set("sk-ant-...", forKey: "claude_api_key")
    static var claudeAPIKey: String {
        // Try environment variable first (for development)
        if let key = ProcessInfo.processInfo.environment["CLAUDE_API_KEY"], !key.isEmpty {
            return key
        }

        // Try UserDefaults (for production)
        if let key = UserDefaults.standard.string(forKey: "claude_api_key"), !key.isEmpty {
            return key
        }

        // Fallback error
        fatalError("""
        Claude API key not configured.

        To set the key, run this in your app:
        UserDefaults.standard.set("your-api-key", forKey: "claude_api_key")

        Or set CLAUDE_API_KEY environment variable.
        """)
    }

    /// Spoonacular API key for recipe discovery
    /// Set via: UserDefaults.standard.set("your-key", forKey: "spoonacular_api_key")
    static var spoonacularAPIKey: String {
        // Try environment variable first (for development)
        if let key = ProcessInfo.processInfo.environment["SPOONACULAR_API_KEY"], !key.isEmpty {
            return key
        }

        // Try UserDefaults (for production)
        if let key = UserDefaults.standard.string(forKey: "spoonacular_api_key"), !key.isEmpty {
            return key
        }

        // Fallback error
        fatalError("""
        Spoonacular API key not configured.

        To set the key, run this in your app:
        UserDefaults.standard.set("your-api-key", forKey: "spoonacular_api_key")

        Or set SPOONACULAR_API_KEY environment variable.
        """)
    }
}
