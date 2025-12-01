import Foundation

/// Client for interacting with Anthropic's Claude API
class ClaudeAPIClient {
    private let apiKey: String
    private let baseURL = "https://api.anthropic.com/v1"
    private let model = "claude-sonnet-4-5-20250929" // Claude Sonnet 4.5 (latest)

    enum ClaudeError: Error {
        case invalidResponse
        case apiError(String)
        case networkError(Error)
        case decodingError(Error)
    }

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    /// Send a prompt to Claude and get a text response
    func sendMessage(prompt: String, systemPrompt: String? = nil) async throws -> String {
        print("\n🌐 [ClaudeAPIClient] sendMessage called")
        print("🌐 [ClaudeAPIClient] API Key: \(apiKey.prefix(10))...***")

        let url = URL(string: "\(baseURL)/messages")!
        print("🌐 [ClaudeAPIClient] URL: \(url.absoluteString)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")

        print("🌐 [ClaudeAPIClient] Headers set:")
        print("   - x-api-key: \(apiKey.prefix(10))...***")
        print("   - anthropic-version: 2023-06-01")
        print("   - content-type: application/json")

        // Build request body
        var body: [String: Any] = [
            "model": model,
            "max_tokens": 1024,
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ]
        ]

        if let systemPrompt = systemPrompt {
            body["system"] = systemPrompt
        }

        print("🌐 [ClaudeAPIClient] Request body:")
        print("   - model: \(model)")
        print("   - max_tokens: 1024")
        print("   - has systemPrompt: \(systemPrompt != nil)")
        print("   - prompt length: \(prompt.count) chars")

        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        print("🌐 [ClaudeAPIClient] Request body serialized successfully")

        // Make request
        print("🌐 [ClaudeAPIClient] Sending request...")
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            print("🌐 [ClaudeAPIClient] Response received")

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ [ClaudeAPIClient] Invalid response - not HTTPURLResponse")
                throw ClaudeError.invalidResponse
            }

            print("🌐 [ClaudeAPIClient] HTTP Status Code: \(httpResponse.statusCode)")
            print("🌐 [ClaudeAPIClient] Response headers: \(httpResponse.allHeaderFields)")

            guard httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("❌ [ClaudeAPIClient] API Error - Status \(httpResponse.statusCode)")
                print("❌ [ClaudeAPIClient] Error response body: \(errorMessage)")
                throw ClaudeError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
            }

            // Parse response
            let rawResponse = String(data: data, encoding: .utf8) ?? "Unable to decode"
            print("🌐 [ClaudeAPIClient] Raw response data: \(rawResponse)")

            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard let content = json?["content"] as? [[String: Any]],
                  let firstContent = content.first,
                  let text = firstContent["text"] as? String else {
                print("❌ [ClaudeAPIClient] Failed to parse response structure")
                print("❌ [ClaudeAPIClient] JSON: \(json ?? [:])")
                throw ClaudeError.invalidResponse
            }

            print("✅ [ClaudeAPIClient] Successfully extracted text response")
            return text

        } catch let error as ClaudeError {
            print("❌ [ClaudeAPIClient] ClaudeError thrown: \(error)")
            throw error
        } catch {
            print("❌ [ClaudeAPIClient] Network error: \(error.localizedDescription)")
            throw ClaudeError.networkError(error)
        }
    }
}
