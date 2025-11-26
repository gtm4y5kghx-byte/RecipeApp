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
            - Extract cuisine if mentioned (Italian, Thai, Mexican, etc.)
            - Interpret time constraints:
              * "quick" or "fast" → 30 minutes total
              * "20 minutes" → 20 minutes total
              * No mention → leave nil
            - Extract keywords: dish types, meal times (dinner, breakfast), dietary terms
              * DO NOT include generic words like "recipes", "food", "cooking", cuisine names
              * Only extract meaningful search terms (pasta, chicken, vegetarian, etc.)
            - Detect intent for favorites: "my favorites", "recipes I love"
            - Detect recency: "haven't made in a while", "haven't tried recently"
            - Detect never cooked: "haven't tried", "never made", "new recipes"

            Be flexible with phrasing - users may say things many different ways.
            When in doubt about time, lean toward common interpretations (quick = 30 min).

            Examples:
            - "quick Italian dinners" → cuisine: Italian, maxTotalTime: 30, keywords: ["dinner"]
            - "recipes I haven't tried" → neverCooked: true, keywords: []
            - "my favorite Thai recipes" → cuisine: Thai, favoritesOnly: true, keywords: []
            - "something in 20 minutes" → maxTotalTime: 20, keywords: []
            - "chicken pasta" → keywords: ["chicken", "pasta"]
            """
        }

        let response = try await session.respond(to: query, generating: RecipeSearchCriteria.self)
        return response.content
    }
}
