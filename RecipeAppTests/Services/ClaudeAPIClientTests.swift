import Testing
import Foundation
@testable import RecipeApp

@Suite("ClaudeAPIClient Unit Tests")
@MainActor
struct ClaudeAPIClientTests {

    @Test("sendMessage returns response on success")
    func testSendMessageSuccess() async throws {
        let mock = MockClaudeAPIClient()
        mock.mockResponse = "Test response from Claude"

        let result = try await mock.sendMessage(prompt: "Test prompt", systemPrompt: "Test system")

        #expect(result == "Test response from Claude")
        #expect(mock.sendMessageCallCount == 1)
        #expect(mock.lastPrompt == "Test prompt")
        #expect(mock.lastSystemPrompt == "Test system")
    }

    @Test("sendMessage throws error on network failure")
    func testSendMessageNetworkError() async throws {
        let mock = MockClaudeAPIClient()
        mock.shouldThrowError = true

        await #expect(throws: ClaudeAPIClient.ClaudeError.self) {
            try await mock.sendMessage(prompt: "Test", systemPrompt: "Test system")
        }

        #expect(mock.sendMessageCallCount == 1)
    }

    @Test("screenUserInput returns true for ALLOW verdict")
    func testScreenUserInputAllow() async throws {
        let mock = MockClaudeAPIClient()
        mock.mockScreenResult = true

        let result = try await mock.screenUserInput("How do I make pasta?")

        #expect(result == true)
        #expect(mock.screenUserInputCallCount == 1)
        #expect(mock.lastQuery == "How do I make pasta?")
    }

    @Test("screenUserInput returns false for BLOCK verdict")
    func testScreenUserInputBlock() async throws {
        let mock = MockClaudeAPIClient()
        mock.mockScreenResult = false

        let result = try await mock.screenUserInput("What is the meaning of life?")

        #expect(result == false)
        #expect(mock.screenUserInputCallCount == 1)
        #expect(mock.lastQuery == "What is the meaning of life?")
    }

    @Test("screenUserInput throws error on network failure")
    func testScreenUserInputNetworkError() async throws {
        let mock = MockClaudeAPIClient()
        mock.shouldThrowError = true

        await #expect(throws: ClaudeAPIClient.ClaudeError.self) {
            try await mock.screenUserInput("Test query")
        }

        #expect(mock.screenUserInputCallCount == 1)
    }

    @Test("reset clears all mock state")
    func testReset() async throws {
        let mock = MockClaudeAPIClient()
        mock.mockResponse = "Some response"
        mock.mockScreenResult = false
        mock.shouldThrowError = true

        _ = try? await mock.sendMessage(prompt: "Test", systemPrompt: "System")
        _ = try? await mock.screenUserInput("Query")

        mock.reset()

        #expect(mock.mockResponse == "")
        #expect(mock.mockScreenResult == true)
        #expect(mock.shouldThrowError == false)
        #expect(mock.sendMessageCallCount == 0)
        #expect(mock.screenUserInputCallCount == 0)
        #expect(mock.lastPrompt == nil)
        #expect(mock.lastSystemPrompt == nil)
        #expect(mock.lastQuery == nil)
    }
}
