import Foundation
@testable import RecipeApp

@MainActor
class MockClaudeAPIClient: ClaudeAPIClient {
    var shouldThrowError = false
    var mockResponse: String = ""
    var mockScreenResult: Bool = true

    override func sendMessage(prompt: String, systemPrompt: String?) async throws -> String {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        return mockResponse
    }

    override func screenUserInput(_ input: String) async throws -> Bool {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        return mockScreenResult
    }
}
