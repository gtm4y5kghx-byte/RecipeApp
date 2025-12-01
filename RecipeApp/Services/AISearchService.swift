import Foundation
import FoundationModels

@MainActor
class AISearchService {

    func parseSearchIntent(from query: String) async throws -> RecipeSearchCriteria {
        let session = LanguageModelSession {
            """
            You are a recipe search assistant. Parse natural language search queries into structured search criteria.

            Your job is to extract search intent from the user's query.

            Guidelines:
            - Cuisine: ONLY include if explicitly mentioned (Italian, Thai, Mexican, etc.)
              * If no cuisine mentioned, DO NOT include the cuisine field at all
            - Time constraints: ONLY include if explicitly mentioned
              * "quick" or "fast" → maxTotalTime: 30
              * "20 minutes" → maxTotalTime: 20
              * If no time mentioned, DO NOT include the maxTotalTime field at all
              * IMPORTANT: "my favorites" does NOT mention time - omit maxTotalTime
            - Keywords: Extract dish types, meal times (dinner, breakfast), dietary terms
              * DO NOT include generic words like "recipes", "food", "cooking", cuisine names
              * Only extract meaningful search terms (pasta, chicken, vegetarian, etc.)
              * If no keywords, use empty array: []
            - Boolean flags: Set to true only if the intent is clear
              * favoritesOnly: true for "my favorites", "recipes I love"
              * excludeRecentlyCooked: true for "haven't made in a while"
              * neverCooked: true for "haven't tried", "never made", "new recipes"

            Be flexible with phrasing - users may say things many different ways.

            Examples:
            - "quick Italian dinners" → cuisine: Italian, maxTotalTime: 30, keywords: ["dinner"], favoritesOnly: false, excludeRecentlyCooked: false, neverCooked: false
            - "recipes I haven't tried" → keywords: [], favoritesOnly: false, excludeRecentlyCooked: false, neverCooked: true (no cuisine, no maxTotalTime)
            - "my favorites" → keywords: [], favoritesOnly: true, excludeRecentlyCooked: false, neverCooked: false (no cuisine, no maxTotalTime)
            - "my favorite Thai recipes" → cuisine: Thai, keywords: [], favoritesOnly: true, excludeRecentlyCooked: false, neverCooked: false (no maxTotalTime)
            - "something in 20 minutes" → maxTotalTime: 20, keywords: [], favoritesOnly: false, excludeRecentlyCooked: false, neverCooked: false (no cuisine)
            - "chicken pasta" → keywords: ["chicken", "pasta"], favoritesOnly: false, excludeRecentlyCooked: false, neverCooked: false (no cuisine, no maxTotalTime)
            """
        }

        let response = try await session.respond(to: query, generating: RecipeSearchCriteria.self)
        return response.content
    }
}
