import Foundation

enum SpoonacularError: Error {
    case invalidURL
    case invalidResponse
    case apiError(String)
}

class SpoonacularService: SpoonacularServiceProtocol {
    private let session: URLSessionProtocol
    private let apiKey: String
    private let baseURL = "https://api.spoonacular.com"

    init(session: URLSessionProtocol = URLSession.shared, apiKey: String) {
        self.session = session
        self.apiKey = apiKey
    }

    func searchRecipes(criteria: SpoonacularSearchCriteria) async throws -> SpoonacularSearchResponse {
        let url = try buildSearchURL(criteria: criteria)
        let request = URLRequest(url: url)

        let (data, response) = try await session.data(for: request)

        try validateResponse(response)

        let decoder = JSONDecoder()
        return try decoder.decode(SpoonacularSearchResponse.self, from: data)
    }

    func getRecipe(id: Int) async throws -> DiscoveredRecipe {
        let url = try buildRecipeURL(id: id)
        let request = URLRequest(url: url)

        let (data, response) = try await session.data(for: request)

        try validateResponse(response)

        let decoder = JSONDecoder()
        return try decoder.decode(DiscoveredRecipe.self, from: data)
    }

    private func buildSearchURL(criteria: SpoonacularSearchCriteria) throws -> URL {
        var components = URLComponents(string: "\(baseURL)/recipes/complexSearch")
        components?.queryItems = criteria.toQueryItems(apiKey: apiKey)

        guard let url = components?.url else {
            throw SpoonacularError.invalidURL
        }

        return url
    }

    private func buildRecipeURL(id: Int) throws -> URL {
        var components = URLComponents(string: "\(baseURL)/recipes/\(id)/information")
        components?.queryItems = [
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "includeNutrition", value: "true")
        ]

        guard let url = components?.url else {
            throw SpoonacularError.invalidURL
        }

        return url
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SpoonacularError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw SpoonacularError.apiError("HTTP \(httpResponse.statusCode)")
        }
    }
}
