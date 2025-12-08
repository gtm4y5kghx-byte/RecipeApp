import Foundation

@MainActor
class AISuggestionEngineService {

    private let claudeClient: ClaudeAPIClient
    private let cacheKey = "suggestion_cache"
    private let minimumRecipeCount = 20

    init() {
        self.claudeClient = ClaudeAPIClient(apiKey: Config.claudeAPIKey)
    }

    func getSuggestions(recipes: [Recipe], forceRefresh: Bool = false) async -> [RecipeSuggestion] {
        guard recipes.count >= minimumRecipeCount else {
            return []
        }

        if !forceRefresh, let cache = loadCache(), !cache.isStale {
            return cache.suggestions
        }

        do {
            let suggestions = try await generateSuggestions(recipes: recipes)

            let cache = SuggestionCache(suggestions: suggestions, generatedAt: Date())
            saveCache(cache)

            return suggestions
        } catch {
            if let cache = loadCache() {
                return cache.suggestions
            }

            return []
        }
    }

    func generateSuggestions(recipes: [Recipe]) async throws -> [RecipeSuggestion] {
        let recipeContext = RecipeContextFormatter.formatCatalog(recipes)
        let systemPrompt = buildSuggestionSystemPrompt()
        let userPrompt = buildSuggestionUserPrompt(recipeContext: recipeContext)

        let jsonResponse = try await claudeClient.sendMessage(
            prompt: userPrompt,
            systemPrompt: systemPrompt
        )

        return try parseSuggestions(from: jsonResponse, recipes: recipes)
    }

    private func buildSuggestionSystemPrompt() -> String {
        """
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
    }

    private func buildSuggestionUserPrompt(recipeContext: String) -> String {
        """
        Current time: \(formatCurrentTime())

        Recipe Catalog:
        \(recipeContext)

        Generate 3-5 personalized recipe suggestions with natural language reasons.
        """
    }

    private func formatCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d 'at' h:mm a"
        return formatter.string(from: Date())
    }

    private func parseSuggestions(from jsonResponse: String, recipes: [Recipe]) throws -> [RecipeSuggestion] {
        let cleanedJSON = jsonResponse.strippingMarkdownCodeFences()

        guard let jsonData = cleanedJSON.data(using: .utf8) else {
            throw NSError(domain: "AISuggestionEngine", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON"])
        }

        struct SuggestionResponse: Codable {
            let recipe_id: String
            let reason: String
        }

        let responses = try JSONDecoder().decode([SuggestionResponse].self, from: jsonData)

        return responses.compactMap { response in
            guard let recipeUUID = UUID(uuidString: response.recipe_id) else {
                return nil
            }
            return RecipeSuggestion(recipeID: recipeUUID, aiGeneratedReason: response.reason)
        }
    }

    private func loadCache() -> SuggestionCache? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else {
            return nil
        }
        return try? JSONDecoder().decode(SuggestionCache.self, from: data)
    }

    private func saveCache(_ cache: SuggestionCache) {
        if let data = try? JSONEncoder().encode(cache) {
            UserDefaults.standard.set(data, forKey: cacheKey)
        }
    }
}
