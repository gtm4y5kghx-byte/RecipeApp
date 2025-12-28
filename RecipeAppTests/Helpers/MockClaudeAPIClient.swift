import Foundation
@testable import RecipeApp

@MainActor
class MockClaudeAPIClient: ClaudeAPIClient {
    var shouldThrowError = false
    var mockResponse: String = ""
    var mockScreenResult: Bool = true
    var sendMessageCallCount = 0
    var screenUserInputCallCount = 0
    var lastPrompt: String?
    var lastSystemPrompt: String?
    var lastModel: Model?
    var lastMaxTokens: Int?
    var lastQuery: String?

    init() {
        super.init(apiKey: "mock-api-key-for-testing")
    }

    override func sendMessage(prompt: String, systemPrompt: String, model: Model = .sonnet, maxTokens: Int = 1024) async throws -> String {
        sendMessageCallCount += 1
        lastPrompt = prompt
        lastSystemPrompt = systemPrompt
        lastModel = model
        lastMaxTokens = maxTokens

        if shouldThrowError {
            throw ClaudeError.networkError(NSError(domain: "MockError", code: 1, userInfo: nil))
        }
        return mockResponse
    }

    override func screenUserInput(_ input: String) async throws -> Bool {
        screenUserInputCallCount += 1
        lastQuery = input

        if shouldThrowError {
            throw ClaudeError.networkError(NSError(domain: "MockError", code: 1, userInfo: nil))
        }
        return mockScreenResult
    }

    func reset() {
        mockResponse = ""
        mockScreenResult = true
        shouldThrowError = false
        sendMessageCallCount = 0
        screenUserInputCallCount = 0
        lastPrompt = nil
        lastSystemPrompt = nil
        lastModel = nil
        lastMaxTokens = nil
        lastQuery = nil
    }
}
