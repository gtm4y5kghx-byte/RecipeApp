import Foundation

enum SearchError: LocalizedError {
    case outOfScope(String)

    var errorDescription: String? {
        switch self {
        case .outOfScope(let message):
            return message
        }
    }
}

@MainActor
class AISearchService {

    private let claudeClient: ClaudeAPIClient

    init() {
        self.claudeClient = ClaudeAPIClient(apiKey: Config.claudeAPIKey)
    }

    func parseSearchIntent(from query: String) async throws -> RecipeSearchCriteria {
        let isAllowed = try await claudeClient.screenUserInput(query)
        guard isAllowed else {
            throw SearchError.outOfScope("This service only handles recipe and cooking questions.")
        }

        let systemPrompt = buildSearchIntentSystemPrompt()
        let userPrompt = buildSearchIntentUserPrompt(query: query)

        let jsonResponse = try await claudeClient.sendMessage(
            prompt: userPrompt,
            systemPrompt: systemPrompt
        )

        let cleanedJSON = jsonResponse.strippingMarkdownCodeFences()

        guard let jsonData = cleanedJSON.data(using: .utf8) else {
            throw ClaudeAPIClient.ClaudeError.decodingError(
                NSError(domain: "AISearchService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not convert response to data"])
            )
        }

        do {
            let criteria = try JSONDecoder().decode(RecipeSearchCriteria.self, from: jsonData)
            return criteria
        } catch {
            throw ClaudeAPIClient.ClaudeError.decodingError(error)
        }
    }

    func search(query: String, recipes: [Recipe]) async throws -> [Recipe] {
        let criteria = try await parseSearchIntent(from: query)

        let structuredMatches = filterByStructuredCriteria(recipes, criteria)
        let textMatches = filterByTextSearch(recipes, criteria)

        let combined = combineResults(
            structured: structuredMatches,
            text: textMatches,
            criteria: criteria
        )

        let ranked = combined.sorted { recipe1, recipe2 in
            calculateRelevanceScore(recipe1, criteria) > calculateRelevanceScore(recipe2, criteria)
        }

        return ranked
    }

    private func buildSearchIntentSystemPrompt() -> String {
        """
        You are parsing recipe search queries into structured JSON criteria.

        CRITICAL RULES:
        1. Return ONLY raw JSON - no markdown formatting, no ```json blocks, no code fences, no explanation text
        2. Your entire response must be valid JSON that can be directly parsed
        3. Use null for optional fields that aren't mentioned (not "nil" string, not 0)
        4. ONLY set favoritesOnly to true if query explicitly mentions "favorite" or "love"
        5. DO NOT add filters that aren't in the query - only extract what user explicitly asked for
        6. "haven't tried" / "never made" = onlyNeverCooked: true
        7. "in awhile" / "haven't made in a while" = onlyCookedLongAgo: true (cooked before but not recently)
        8. "tried recently" / "made lately" = onlyCookedRecently: true
        9. Each boolean should be true ONLY if explicitly mentioned - default all to false

        Return JSON matching this exact schema:
        {
          "cuisine": string | null,
          "maxTotalTime": number | null,
          "favoritesOnly": boolean,
          "onlyNeverCooked": boolean,
          "onlyCookedLongAgo": boolean,
          "onlyCookedRecently": boolean,
          "titleKeywords": string[],
          "ingredientKeywords": string[],
          "notesKeywords": string[],
          "combineMode": "and" | "or"
        }
        """
    }

    private func buildSearchIntentUserPrompt(query: String) -> String {
        """
        Parse this recipe search query into JSON:

        "\(query)"

        Semantic guidelines:

        1. Cuisine vs Ingredient:
           - "Italian recipes" → cuisine: "Italian", ingredientKeywords: []
           - "Italian sausage pasta" → cuisine: null, ingredientKeywords: ["Italian sausage", "pasta"]

        2. Time vs Dish Name:
           - "quick recipes" → maxTotalTime: 30, titleKeywords: []
           - "Quick Pickles" → maxTotalTime: null, titleKeywords: ["Quick Pickles"]

        3. Favorites:
           - "my favorites" → favoritesOnly: true, titleKeywords: []
           - "favorite chicken" → favoritesOnly: true, ingredientKeywords: ["chicken"], combineMode: "and"
           - "recipes with favorite in title" → favoritesOnly: false, titleKeywords: ["favorite"]

        4. Cooking History:
           - "recipes I haven't tried" → onlyNeverCooked: true, favoritesOnly: false
           - "favorites I haven't made in awhile" → favoritesOnly: true, onlyCookedLongAgo: true, onlyNeverCooked: false
           - "recipes I've tried recently" → onlyCookedRecently: true, favoritesOnly: false

        5. Keywords:
           - Keep phrases together: "grilled cheese", "Italian sausage"
           - Put ingredients in ingredientKeywords
           - Put dish names in titleKeywords
           - Put dietary/technique terms in notesKeywords

        6. Combine Mode:
           - Use "and" when ALL conditions must match (default)
           - Use "or" when query has alternatives like "quick or Italian"

        Examples:

        Query: "quick Italian recipes"
        Output: {"cuisine":"Italian","maxTotalTime":30,"favoritesOnly":false,"onlyNeverCooked":false,"onlyCookedLongAgo":false,"onlyCookedRecently":false,"titleKeywords":[],"ingredientKeywords":[],"notesKeywords":[],"combineMode":"and"}

        Query: "recipes I haven't tried"
        Output: {"cuisine":null,"maxTotalTime":null,"favoritesOnly":false,"onlyNeverCooked":true,"onlyCookedLongAgo":false,"onlyCookedRecently":false,"titleKeywords":[],"ingredientKeywords":[],"notesKeywords":[],"combineMode":"and"}

        Query: "favorites I haven't made in awhile"
        Output: {"cuisine":null,"maxTotalTime":null,"favoritesOnly":true,"onlyNeverCooked":false,"onlyCookedLongAgo":true,"onlyCookedRecently":false,"titleKeywords":[],"ingredientKeywords":[],"notesKeywords":[],"combineMode":"and"}

        Return ONLY the JSON, nothing else.
        """
    }

    private func filterByStructuredCriteria(_ recipes: [Recipe], _ criteria: RecipeSearchCriteria) -> [Recipe] {
        return RecipeFilterService.filterRecipes(recipes, using: criteria)
    }

    private func filterByTextSearch(_ recipes: [Recipe], _ criteria: RecipeSearchCriteria) -> [Recipe] {
        let hasKeywords = !criteria.titleKeywords.isEmpty ||
        !criteria.ingredientKeywords.isEmpty ||
        !criteria.notesKeywords.isEmpty

        guard hasKeywords else {
            return []
        }

        return recipes.filter { recipe in
            matchesTextSearch(recipe, criteria)
        }
    }

    private func combineResults(
        structured: [Recipe],
        text: [Recipe],
        criteria: RecipeSearchCriteria
    ) -> [Recipe] {
        let hasKeywords = !criteria.titleKeywords.isEmpty ||
        !criteria.ingredientKeywords.isEmpty ||
        !criteria.notesKeywords.isEmpty

        switch criteria.combineMode.lowercased() {
        case "and":
            if !hasKeywords {
                return structured
            }

            if text.isEmpty {
                return []
            }

            let textIDs = Set(text.map(\.id))
            return structured.filter { textIDs.contains($0.id) }

        case "or":
            let structuredIDs = Set(structured.map(\.id))
            var combined = structured

            for recipe in text where !structuredIDs.contains(recipe.id) {
                combined.append(recipe)
            }

            return combined

        default:
            if !hasKeywords {
                return structured
            }

            if text.isEmpty {
                return []
            }

            let textIDs = Set(text.map(\.id))
            return structured.filter { textIDs.contains($0.id) }
        }
    }

    private func matchesTextSearch(_ recipe: Recipe, _ criteria: RecipeSearchCriteria) -> Bool {
        var titleMatch = false
        var ingredientMatch = false
        var notesMatch = false

        if !criteria.titleKeywords.isEmpty {
            titleMatch = criteria.titleKeywords.contains { keyword in
                recipe.title.localizedCaseInsensitiveContains(keyword)
            }
        }

        if !criteria.ingredientKeywords.isEmpty {
            ingredientMatch = criteria.ingredientKeywords.contains { keyword in
                recipe.ingredients.contains { ingredient in
                    ingredient.item.localizedCaseInsensitiveContains(keyword)
                }
            }
        }

        if !criteria.notesKeywords.isEmpty {
            notesMatch = criteria.notesKeywords.contains { keyword in
                recipe.notes?.localizedCaseInsensitiveContains(keyword) ?? false
            }
        }

        return titleMatch || ingredientMatch || notesMatch
    }

    private func calculateRelevanceScore(
        _ recipe: Recipe,
        _ criteria: RecipeSearchCriteria
    ) -> Int {
        var score = 0

        for keyword in criteria.titleKeywords {
            if recipe.title.localizedCaseInsensitiveContains(keyword) {
                score += 10
            }
        }

        if let searchCuisine = criteria.cuisine,
           let recipeCuisine = recipe.cuisine,
           recipeCuisine.localizedCaseInsensitiveCompare(searchCuisine) == .orderedSame {
            score += 8
        }

        if let maxTime = criteria.maxTotalTime,
           let totalTime = recipe.totalTime,
           totalTime <= maxTime {
            score += 5
        }

        if recipe.isFavorite {
            score += 3
        }

        if let lastMade = recipe.lastMade {
            if lastMade.isWithinDays(TimeConstants.recentlyCookedThreshold) {
                score -= 2
            }
        }

        return score
    }
}
