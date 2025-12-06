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
        
        print("🔍 [parseSearchIntent] Input query: \"\(query)\"")
        
        let systemPrompt = """
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
        
        let userPrompt = """
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
        
        print("🔍 [parseSearchIntent] Sending to Claude API...")
        
        let jsonResponse = try await claudeClient.sendMessage(
            prompt: userPrompt,
            systemPrompt: systemPrompt
        )
        
        print("🔍 [parseSearchIntent] Claude raw response: \(jsonResponse)")
        
        // Strip markdown code blocks if present (```json ... ```)
        var cleanedJSON = jsonResponse.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanedJSON.hasPrefix("```json") {
            cleanedJSON = cleanedJSON
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            print("🔍 [parseSearchIntent] Stripped markdown code blocks")
        } else if cleanedJSON.hasPrefix("```") {
            cleanedJSON = cleanedJSON
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            print("🔍 [parseSearchIntent] Stripped generic markdown code blocks")
        }
        
        print("🔍 [parseSearchIntent] Cleaned JSON: \(cleanedJSON)")
        
        // Parse JSON into RecipeSearchCriteria
        guard let jsonData = cleanedJSON.data(using: .utf8) else {
            throw ClaudeAPIClient.ClaudeError.decodingError(NSError(domain: "AISearchService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not convert response to data"]))
        }
        
        do {
            let criteria = try JSONDecoder().decode(RecipeSearchCriteria.self, from: jsonData)
            print("✅ [parseSearchIntent] Successfully parsed criteria:")
            print("   - cuisine: \(criteria.cuisine ?? "nil")")
            print("   - maxTotalTime: \(criteria.maxTotalTime?.description ?? "nil")")
            print("   - favoritesOnly: \(criteria.favoritesOnly)")
            print("   - onlyNeverCooked: \(criteria.onlyNeverCooked)")
            print("   - onlyCookedLongAgo: \(criteria.onlyCookedLongAgo)")
            print("   - onlyCookedRecently: \(criteria.onlyCookedRecently)")
            print("   - titleKeywords: \(criteria.titleKeywords)")
            print("   - ingredientKeywords: \(criteria.ingredientKeywords)")
            print("   - notesKeywords: \(criteria.notesKeywords)")
            print("   - combineMode: \(criteria.combineMode)")
            return criteria
        } catch {
            print("❌ [parseSearchIntent] Failed to decode JSON: \(error)")
            print("❌ [parseSearchIntent] Raw JSON: \(jsonResponse)")
            throw ClaudeAPIClient.ClaudeError.decodingError(error)
        }
    }
    
    /* OLD ON-DEVICE IMPLEMENTATION - REMOVED
     * This used FoundationModels but was not reliable enough
     * Keeping search(), filterBy*(), combineResults() methods below
     */
    
    func search(query: String, recipes: [Recipe]) async throws -> [Recipe] {
        
        print("\n" + String(repeating: "=", count: 60))
        print("🔍 [search] Starting search for: \"\(query)\"")
        print("🔍 [search] Total recipes to search: \(recipes.count)")
        print(String(repeating: "=", count: 60))
        
        // Step 1: Claude API parses query into dual criteria
        let criteria = try await parseSearchIntent(from: query)
        
        // Step 2: Execute dual-path filtering
        print("\n🔍 [search] Executing dual-path filtering...")
        let structuredMatches = filterByStructuredCriteria(recipes, criteria)
        let textMatches = filterByTextSearch(recipes, criteria)
        
        print("🔍 [search] Structured path matches: \(structuredMatches.count)")
        print("🔍 [search] Text search path matches: \(textMatches.count)")
        
        // Step 3: Combine results based on mode
        print("🔍 [search] Combining results using '\(criteria.combineMode)' mode...")
        let combined = combineResults(
            structured: structuredMatches,
            text: textMatches,
            criteria: criteria
        )
        
        print("🔍 [search] Sorting results by relevance...")
        let ranked = combined.sorted { recipe1, recipe2 in
            calculateRelevanceScore(recipe1, criteria) > calculateRelevanceScore(recipe2, criteria)
        }
        
        print("🔍 [search] Final result count: \(ranked.count)")
        if ranked.count > 0 {
            print("🔍 [search] Result titles (ranked by relevance):")
            for (index, recipe) in ranked.prefix(10).enumerated() {
                let score = calculateRelevanceScore(recipe, criteria)
                print("   \(index + 1). \(recipe.title) (score: \(score))")
            }
            if ranked.count > 10 {
                print("   ... and \(ranked.count - 10) more")
            }
        }
        print(String(repeating: "=", count: 60) + "\n")
        
        return ranked
    }
    
    private func filterByStructuredCriteria(_ recipes: [Recipe], _ criteria: RecipeSearchCriteria) -> [Recipe] {
        return RecipeFilterService.filterRecipes(recipes, using: criteria)
    }
    
    private func filterByTextSearch(_ recipes: [Recipe], _ criteria: RecipeSearchCriteria) -> [Recipe] {
        // If no text search keywords, return empty (no text filter applied)
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
        // Check if any keywords were requested
        let hasKeywords = !criteria.titleKeywords.isEmpty ||
        !criteria.ingredientKeywords.isEmpty ||
        !criteria.notesKeywords.isEmpty
        
        switch criteria.combineMode.lowercased() {
        case "and":
            // Intersection: Recipe must match BOTH structured AND text search
            
            // Special case: If no keywords were requested, use only structured results
            if !hasKeywords {
                print("🔍 [combineResults] No keywords requested, returning structured results only")
                return structured
            }
            
            // Keywords were requested but no matches found → intersection is empty
            if text.isEmpty {
                print("🔍 [combineResults] Keywords requested but no text matches found, returning empty")
                return []
            }
            
            // Intersection: Find recipes in BOTH arrays
            print("🔍 [combineResults] Finding intersection of structured and text matches")
            let textIDs = Set(text.map(\.id))
            return structured.filter { textIDs.contains($0.id) }
            
        case "or":
            // Union: Recipe can match structured OR text search (deduplicate)
            let structuredIDs = Set(structured.map(\.id))
            var combined = structured
            
            for recipe in text where !structuredIDs.contains(recipe.id) {
                combined.append(recipe)
            }
            
            return combined
            
        default:
            // Default to "and" behavior if AI returns unexpected value
            print("⚠️ [combineResults] Unexpected combineMode: '\(criteria.combineMode)', defaulting to 'and'")
            
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
        
        // Check title keywords (OR logic within titleKeywords)
        if !criteria.titleKeywords.isEmpty {
            titleMatch = criteria.titleKeywords.contains { keyword in
                recipe.title.localizedCaseInsensitiveContains(keyword)
            }
        }
        
        // Check ingredient keywords (OR logic within ingredientKeywords)
        if !criteria.ingredientKeywords.isEmpty {
            ingredientMatch = criteria.ingredientKeywords.contains { keyword in
                recipe.ingredients.contains { ingredient in
                    ingredient.item.localizedCaseInsensitiveContains(keyword)
                }
            }
        }
        
        // Check notes keywords (OR logic within notesKeywords)
        if !criteria.notesKeywords.isEmpty {
            notesMatch = criteria.notesKeywords.contains { keyword in
                recipe.notes?.localizedCaseInsensitiveContains(keyword) ?? false
            }
        }
        
        // Match if ANY keyword category matches (OR across categories)
        return titleMatch || ingredientMatch || notesMatch
    }
    
    // Calculate relevance score for ranking search results
    private func calculateRelevanceScore(
        _ recipe: Recipe,
        _ criteria: RecipeSearchCriteria
    ) -> Int {
        var score = 0
        
        // Exact keyword matches in title (highest priority)
        for keyword in criteria.titleKeywords {
            if recipe.title.localizedCaseInsensitiveContains(keyword) {
                score += 10
            }
        }
        
        // Cuisine match (high priority)
        if let searchCuisine = criteria.cuisine,
           let recipeCuisine = recipe.cuisine,
           recipeCuisine.localizedCaseInsensitiveCompare(searchCuisine) == .orderedSame {
            score += 8
        }
        
        // Time constraint match (medium priority)
        if let maxTime = criteria.maxTotalTime,
           let totalTime = recipe.totalTime,
           totalTime <= maxTime {
            score += 5
        }
        
        // Favorited recipes (boost slightly)
        if recipe.isFavorite {
            score += 3
        }
        
        // Recently cooked (deprioritize to encourage variety)
        if let lastMade = recipe.lastMade {
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            if lastMade > thirtyDaysAgo {
                score -= 2
            }
        }
        
        return score
    }
}
