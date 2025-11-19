import Foundation

struct RecipeAPIService {
    private let baseURL = "https://recipe-backend-neon.vercel.app"
    
    func structureRecipe(from transcript: String) async throws -> RecipeResponse {
        guard let url = URL(string: "\(baseURL)/api/structure-recipe") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["transcript": transcript]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        let recipeResponse = try decoder.decode(RecipeResponse.self, from: data)
        return recipeResponse
    }
}

struct RecipeResponse: Codable {
    let title: String
    let servings: Int?
    let prepTime: Int?
    let cookTime: Int?
    let cuisine: String?
    let ingredients: [IngredientResponse]
    let instructions: [InstructionResponse]
    let notes: String?
}

struct IngredientResponse: Codable {
    let quantity: String?
    let unit: String?
    let item: String
    let preparation: String?
    let section: String?
}

struct InstructionResponse: Codable {
    let order: Int
    let instruction: String
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let code):
            if code >= 500 {
                return "Service temporarily unavailable. Try again."
            } else if code == 408 {
                return "Unable to process recipe. Check connection."
            } else {
                return "Something went wrong. Please try again."
            }
        case .decodingError:
            return "Something went wrong. Please try again."
        }
    }
}
