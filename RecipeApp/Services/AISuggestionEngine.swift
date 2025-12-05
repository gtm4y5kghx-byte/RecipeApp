import Foundation

@MainActor
class AISuggestionEngine {
    
    private let claudeClient: ClaudeAPIClient
    
    init() {
        self.claudeClient = ClaudeAPIClient(apiKey: Config.claudeAPIKey)
    }
    
    func generateSuggestions(
        recipes: [Recipe]
    ) async throws -> [RecipeSuggestion] {
        
        let recipeContext = buildRecipeContext(recipes)
        
        let systemPrompt = """
          You are a personalized recipe recommendation assistant. Generate 3-5 recipe suggestions
          based on the user's cooking history and preferences.
          
          CRITICAL RULES:
          1. Return ONLY raw JSON - no markdown, no ```json blocks, no explanation
          2. Your entire response must be valid JSON that can be directly parsed
          3. Generate exactly 3-5 suggestions (no more, no less)
          4. Each suggestion must have a recipe_id (UUID from the catalog) and a personalized reason
          5. Reasons should be natural, conversational, and specific to the user's history
          
          Suggestion Categories (choose mix that fits user's situation):
          - "Try Again" - Favorites not cooked recently (> 30 days)
          - "New to Try" - Never-cooked recipes (timesCooked = 0)
          - "Mix It Up" - Different cuisines from recent cooking
          - "Quick & Easy" - Low time commitment (< 30 min total)
          - "Perfect for [time of day]" - Contextual (breakfast at 8am, dinner at 6pm)
          
          Return JSON array:
          [
            {
              "recipe_id": "uuid-here",
              "reason": "You loved this 3 months ago - time to make it again?"
            }
          ]
          """
        
        let userPrompt = """
          Current time: \(formatCurrentTime())
          
          Recipe Catalog:
          \(recipeContext)
          
          Generate 3-5 personalized recipe suggestions with natural language reasons.
          """
        
        let jsonResponse = try await claudeClient.sendMessage(
            prompt: userPrompt,
            systemPrompt: systemPrompt
        )
        
        return try parseSuggestions(from: jsonResponse, recipes: recipes)
    }
    
    private func buildRecipeContext(_ recipes: [Recipe]) -> String {
        var context = ""
        
        for (index, recipe) in recipes.enumerated() {
            context += "\n[\(index + 1)] \(recipe.title) (ID: \(recipe.id))\n"
            context += "   Cuisine: \(recipe.cuisine ?? "Unknown")\n"
            context += "   Total Time: \(recipe.totalTime ?? 0) min\n"
            context += "   Times Cooked: \(recipe.timesCooked)\n"
            
            if let lastMade = recipe.lastMade {
                let daysAgo = Calendar.current.dateComponents([.day], from: lastMade, to: Date()).day ?? 0
                context += "   Last Made: \(daysAgo) days ago\n"
            } else {
                context += "   Last Made: Never\n"
            }
            
            context += "   Favorite: \(recipe.isFavorite ? "Yes" : "No")\n"
        }
        
        return context
    }
    
    private func formatCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d 'at' h:mm a"
        return formatter.string(from: Date())
    }
    
    private func parseSuggestions(from jsonResponse: String, recipes: [Recipe]) throws -> [RecipeSuggestion] {
        // TODO: Consolidate markdown stripping logic with AISearchService during polish phase
        // Strip markdown if present
        var cleanedJSON = jsonResponse.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanedJSON.hasPrefix("```json") {
            cleanedJSON = cleanedJSON
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        guard let jsonData = cleanedJSON.data(using: .utf8) else {
            throw NSError(domain: "AISuggestionEngine", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON"])
        }
        
        // Parse JSON array
        struct SuggestionResponse: Codable {
            let recipe_id: String
            let reason: String
        }
        
        let responses = try JSONDecoder().decode([SuggestionResponse].self, from: jsonData)
        
        // Convert to RecipeSuggestion objects
        return responses.compactMap { response in
            guard let recipeUUID = UUID(uuidString: response.recipe_id) else {
                return nil
            }
            return RecipeSuggestion(recipeID: recipeUUID, aiGeneratedReason: response.reason)
        }
    }
    
}
