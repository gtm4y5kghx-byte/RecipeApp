import Foundation

@MainActor
protocol RecipeGenerating {
    func getGeneratedRecipes(recipes: [Recipe]) async throws -> [GeneratedRecipe]
}

@MainActor
class RecipeGenerationService: RecipeGenerating {

    private let claudeClient: ClaudeAPIClient
    private let cacheKey = "generated_recipe_cache"
    
    init() {
        self.claudeClient = ClaudeAPIClient(apiKey: Config.claudeAPIKey)
    }
    
    // MARK: - Public API

    func getGeneratedRecipes(recipes: [Recipe]) async throws -> [GeneratedRecipe] {
        try await getGeneratedRecipes(recipes: recipes, forceRefresh: false)
    }

    func getGeneratedRecipes(recipes: [Recipe], forceRefresh: Bool) async throws -> [GeneratedRecipe] {
        if !forceRefresh, let cache = loadCache(), !cache.isStale {
            return cache.recipes
        }
        
        let generatedRecipes = try await generateRecipes(recipes: recipes)
        
        let cache = GeneratedRecipeCache(recipes: generatedRecipes, generatedAt: Date())
        saveCache(cache)
        
        return generatedRecipes
    }
    
    func generateRecipes(recipes: [Recipe], count: Int = 3) async throws -> [GeneratedRecipe] {
        let systemPrompt = buildSystemPrompt()
        let userPrompt = buildUserPrompt(recipes: recipes, count: count)
        
        let jsonResponse = try await claudeClient.sendMessage(
            prompt: userPrompt,
            systemPrompt: systemPrompt,
            model: .sonnet,
            maxTokens: 4096
        )
        
        return try parseGeneratedRecipes(from: jsonResponse)
    }
    
    // MARK: - Prompt Building
    
    private func buildSystemPrompt() -> String {
        """
        You are a professional recipe creator. Generate complete, realistic recipes based on user's cooking patterns.
        
        CRITICAL RULES:
        1. Return ONLY raw JSON - no markdown formatting, no ```json blocks, no explanation text
        2. Your entire response must be valid JSON that can be directly parsed
        3. Generate exactly the requested number of recipes
        4. Recipes must be realistic, safe, and use standard cooking techniques
        5. Ingredients must include quantities and be commonly available
        6. Instructions must be clear, sequential, and detailed enough for a home cook
        
        Return JSON array matching this exact schema:
        [
          {
            "title": "Recipe Name",
            "description": "Brief 1-2 sentence description",
            "ingredients": [
               {"quantity": "2 cups", "unit": "cups", "item": "all-purpose flour", "preparation": null},
               {"quantity": "1 lb", "unit": "lb", "item": "chicken breast", "preparation": "boneless and skinless"}
             ],
            "instructions": ["Preheat oven to 350°F", "Mix dry ingredients", "Bake for 25 minutes"],
            "prepTime": 15,
            "cookTime": 30,
            "servings": 4,
            "cuisine": "Italian",
            "tags": ["quick", "healthy"],
            "nutrition": {
              "calories": 450,
              "carbohydrates": 45.0,
              "protein": 35.0,
              "fat": 12.0,
              "fiber": 3.0,
              "sodium": 600.0,
              "sugar": 2.0
            }
          }
        ]
        
        NOTES:
        - prepTime and cookTime are in minutes (integers)
        - servings is number of people (integer)
        - nutrition values are per serving (calories integer, others doubles in grams, sodium in mg)
        """
    }
    
    private func buildUserPrompt(recipes: [Recipe], count: Int) -> String {
        let analysisContext = analyzeUserCookingPatterns(recipes)
        
        return """
        Current time: \(formatCurrentTime())
        
        User's Recipe Collection Analysis:
        \(analysisContext)
        
        Generate \(count) NEW recipes that match this user's cooking style and preferences.
        These should be recipes they don't already have but would enjoy based on their patterns.
        
        Return ONLY the JSON array, nothing else.
        """
    }
    
    // MARK: - Collection Analysis
    
    private func analyzeUserCookingPatterns(_ recipes: [Recipe]) -> String {
        let totalRecipes = recipes.count
        
        let cuisineDistribution = analyzeCuisines(recipes, total: totalRecipes)
        let timePatterns = analyzeTimingPatterns(recipes)
        let engagementPatterns = analyzeEngagement(recipes, total: totalRecipes)
        let complexityAnalysis = analyzeComplexity(recipes)
        
        return """
        Collection Size: \(totalRecipes) recipes
        
        \(cuisineDistribution)
        \(timePatterns)
        \(engagementPatterns)
        \(complexityAnalysis)
        """
    }
    
    private func analyzeCuisines(_ recipes: [Recipe], total: Int) -> String {
        let cuisineDistribution = Dictionary(grouping: recipes.compactMap { $0.cuisine }, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
            .prefix(5)
        
        var result = "Cuisine Preferences:"
        for (cuisine, count) in cuisineDistribution {
            let percentage = (count * 100) / total
            result += "\n- \(cuisine): \(count) recipes (\(percentage)%)"
        }
        return result
    }
    
    private func analyzeTimingPatterns(_ recipes: [Recipe]) -> String {
        let cookTimes = recipes.compactMap { $0.totalTime }
        guard !cookTimes.isEmpty else { return "" }
        
        let averageCookTime = cookTimes.reduce(0, +) / cookTimes.count
        let quickRecipes = cookTimes.filter { $0 <= 30 }.count
        let preference = quickRecipes > cookTimes.count / 2 ? "quick" : "longer"
        
        return """
        
        Cooking Time Patterns:
        - Average total time: \(averageCookTime) minutes
        - Quick recipes (≤30 min): \(quickRecipes) out of \(cookTimes.count)
        - Prefers \(preference) cooking times
        """
    }
    
    private func analyzeEngagement(_ recipes: [Recipe], total: Int) -> String {
        let favoriteCount = recipes.filter { $0.isFavorite }.count
        let favoritePercentage = total > 0 ? (favoriteCount * 100) / total : 0
        let cookedRecipes = recipes.filter { $0.timesCooked > 0 }.count
        let frequentlyCookedCount = recipes.filter { $0.timesCooked >= 3 }.count
        
        return """
        
        Engagement Patterns:
        - Favorites: \(favoriteCount) recipes (\(favoritePercentage)%)
        - Actually cooked: \(cookedRecipes) recipes
        - Frequently cooked (3+ times): \(frequentlyCookedCount) recipes
        """
    }
    
    private func analyzeComplexity(_ recipes: [Recipe]) -> String {
        guard !recipes.isEmpty else { return "" }
        
        let avgIngredientCount = recipes.map { $0.ingredients.count }.reduce(0, +) / recipes.count
        let avgInstructionCount = recipes.map { $0.instructions.count }.reduce(0, +) / recipes.count
        let complexityLevel = avgIngredientCount <= 8 && avgInstructionCount <= 6 ? "Simple" : "Moderate"
        
        return """
        
        Complexity Preference:
        - Average ingredients per recipe: \(avgIngredientCount)
        - Average instruction steps: \(avgInstructionCount)
        - Complexity level: \(complexityLevel)
        """
    }
    
    // MARK: - Response Parsing
    
    private func parseGeneratedRecipes(from jsonResponse: String) throws -> [GeneratedRecipe] {
        let cleanedJSON = jsonResponse.strippingMarkdownCodeFences()
        
        guard let jsonData = cleanedJSON.data(using: .utf8) else {
            throw AIError.apiError("Could not parse recipe data")
        }
        
        do {
            let generatedRecipes = try JSONDecoder().decode([GeneratedRecipe].self, from: jsonData)
            let validRecipes = generatedRecipes.filter { isValid($0) }
            
            guard !validRecipes.isEmpty else {
                throw AIError.apiError("No valid recipes were generated")
            }
            
            return validRecipes
        } catch let decodingError as DecodingError {
            throw AIError.apiError("Invalid recipe format: \(decodingError.localizedDescription)")
        }
    }
    
    private func isValid(_ recipe: GeneratedRecipe) -> Bool {
        guard !recipe.title.isEmpty else { return false }
        guard !recipe.ingredients.isEmpty else { return false }
        guard !recipe.instructions.isEmpty else { return false }
        
        if let prepTime = recipe.prepTime, prepTime < 0 { return false }
        if let cookTime = recipe.cookTime, cookTime < 0 { return false }
        if let servings = recipe.servings, servings < 1 { return false }
        
        return true
    }
    
    // MARK: - Caching
    
    private func loadCache() -> GeneratedRecipeCache? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else {
            return nil
        }
        return try? JSONDecoder().decode(GeneratedRecipeCache.self, from: data)
    }
    
    private func saveCache(_ cache: GeneratedRecipeCache) {
        if let data = try? JSONEncoder().encode(cache) {
            UserDefaults.standard.set(data, forKey: cacheKey)
        }
    }
    
    // MARK: - Helpers
    
    private func formatCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d 'at' h:mm a"
        return formatter.string(from: Date())
    }
}
