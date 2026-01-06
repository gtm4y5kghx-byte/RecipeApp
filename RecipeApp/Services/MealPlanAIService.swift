import Foundation

@MainActor
class MealPlanAIService {

    private let claudeClient: ClaudeAPIClient
    private let minimumRecipeCount = 3

    init() {
        self.claudeClient = ClaudeAPIClient(apiKey: Config.claudeAPIKey)
    }

    // MARK: - Public API

    func generatePlan(
        for mealType: MealType,
        recipes: [Recipe],
        dayCount: Int = 7
    ) async throws -> [MealPlanGenerationResult] {
        guard !recipes.isEmpty else {
            throw MealPlanAIError.emptyCollection
        }

        guard recipes.count >= minimumRecipeCount else {
            throw MealPlanAIError.insufficientRecipes(available: recipes.count, required: minimumRecipeCount)
        }

        let systemPrompt = buildGeneratePlanSystemPrompt(dayCount: dayCount)
        let userPrompt = buildGeneratePlanUserPrompt(mealType: mealType, recipes: recipes, dayCount: dayCount)

        let jsonResponse = try await claudeClient.sendMessage(
            prompt: userPrompt,
            systemPrompt: systemPrompt,
            model: .haiku,
            maxTokens: 1024
        )

        return try parseGeneratePlanResponse(from: jsonResponse, recipes: recipes)
    }

    func reviewPlan(entries: [MealPlanEntry], recipes: [Recipe]) async throws -> [MealPlanInsight] {
        guard !recipes.isEmpty else {
            return []
        }

        let today = Calendar.current.startOfDay(for: Date())
        let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: today)!
        let weekEntries = entries.filter { entry in
            entry.date >= today && entry.date < weekEnd
        }

        let systemPrompt = buildReviewPlanSystemPrompt()
        let userPrompt = buildReviewPlanUserPrompt(entries: weekEntries, recipes: recipes)

        let jsonResponse = try await claudeClient.sendMessage(
            prompt: userPrompt,
            systemPrompt: systemPrompt,
            model: .haiku,
            maxTokens: 1024
        )

        return try parseReviewPlanResponse(from: jsonResponse, recipes: recipes)
    }

    // MARK: - Generate Plan Prompts

    private func buildGeneratePlanSystemPrompt(dayCount: Int) -> String {
        let maxDayOffset = dayCount - 1

        return """
        You are a meal planning assistant. Select recipes from the user's collection to create a meal plan.

        CRITICAL RULES:
        1. Return ONLY raw JSON - no markdown, no ```json blocks, no explanation
        2. Select recipes for the specified number of days (one per day)
        3. ONLY use recipe IDs from the provided catalog - never invent new recipes
        4. Each recipe should appear at most once in the plan
        5. Prioritize variety (different cuisines, different cooking styles)

        SELECTION CRITERIA (in order of priority):
        1. Variety - avoid repeating cuisines back-to-back
        2. Recency - prefer recipes not cooked recently (lastMade > 14 days ago or never)
        3. Favorites - include 1-2 favorites if available
        4. Balance - mix quick meals with more involved recipes

        Return JSON array matching this exact schema:
        [
          {"dayOffset": 0, "recipeID": "uuid-here"},
          {"dayOffset": 1, "recipeID": "uuid-here"}
        ]

        NOTES:
        - dayOffset: 0 = today, 1 = tomorrow, ..., \(maxDayOffset) = \(maxDayOffset) days from now
        - Generate one recipe per day for the requested day count
        - If fewer suitable recipes exist than days requested, return what you can
        """
    }

    private func buildGeneratePlanUserPrompt(mealType: MealType, recipes: [Recipe], dayCount: Int) -> String {
        let catalogContext = RecipeContextFormatter.formatCatalog(recipes)

        return """
        Current time: \(formatCurrentTime())
        Meal type: \(mealType.rawValue.capitalized)
        Days to plan: \(dayCount)

        User's Recipe Collection (\(recipes.count) recipes):
        \(catalogContext)

        Create a \(mealType.rawValue) plan for the next \(dayCount) days.
        Select \(dayCount) recipes that provide variety and match the user's cooking patterns.

        Return ONLY the JSON array, nothing else.
        """
    }

    // MARK: - Review Plan Prompts

    private func buildReviewPlanSystemPrompt() -> String {
        """
        You are a meal planning assistant. Analyze the user's meal plan and provide helpful insights.

        CRITICAL RULES:
        1. Return ONLY raw JSON - no markdown, no ```json blocks, no explanation
        2. Generate 1-3 insights (no more than 3)
        3. Only suggest recipes from the user's collection
        4. Be specific and actionable

        INSIGHT CATEGORIES:
        - "varietyAlert": Pattern recognition (e.g., "3 pasta dishes - suggest a Thai alternative")
        - "add": Empty slot suggestions (e.g., "Friday dinner is open - suggest Pad Thai")
        - "swap": Recipe swap suggestions (e.g., "Swap Tuesday's Italian for Thai Green Curry")

        MANDATORY FOR EVERY INSIGHT - NO EXCEPTIONS:
        - suggestedRecipeID: REQUIRED - must be a valid UUID from the catalog
        - targetDayOffset: REQUIRED - must be 0-6
        - targetMealType: REQUIRED - must be "breakfast", "lunch", or "dinner"

        DO NOT generate insights without all three fields. An insight without a suggestion is useless.

        Return JSON array matching this exact schema:
        [
          {
            "insight": "What you noticed",
            "recommendation": "What to do about it",
            "suggestedRecipeID": "uuid-here",
            "suggestionType": "swap|add|varietyAlert",
            "targetDayOffset": 0,
            "targetMealType": "breakfast|lunch|dinner"
          }
        ]
        """
    }

    private func buildReviewPlanUserPrompt(entries: [MealPlanEntry], recipes: [Recipe]) -> String {
        let planContext = RecipeContextFormatter.formatCurrentPlan(entries)
        let catalogContext = RecipeContextFormatter.formatCatalog(recipes)

        return """
        Current time: \(formatCurrentTime())

        CURRENT MEAL PLAN (Next 7 Days):
        \(planContext)

        USER'S RECIPE COLLECTION (\(recipes.count) recipes):
        \(catalogContext)

        Analyze this meal plan and provide 1-3 insights about:
        - Pattern issues (too much of one cuisine/protein)
        - Empty slots that could be filled
        - Forgotten recipes (saved but never cooked)
        - Swap opportunities for better variety

        Return ONLY the JSON array, nothing else.
        """
    }

    // MARK: - Response Parsing

    private func parseGeneratePlanResponse(from jsonResponse: String, recipes: [Recipe]) throws -> [MealPlanGenerationResult] {
        let cleanedJSON = jsonResponse.strippingMarkdownCodeFences()

        guard let jsonData = cleanedJSON.data(using: .utf8) else {
            throw MealPlanAIError.parsingFailed
        }

        let assignments: [MealPlanAssignment]
        do {
            assignments = try JSONDecoder().decode([MealPlanAssignment].self, from: jsonData)
        } catch {
            throw MealPlanAIError.parsingFailed
        }

        let recipesByID = Dictionary(uniqueKeysWithValues: recipes.map { ($0.id, $0) })

        var results: [MealPlanGenerationResult] = []

        for assignment in assignments {
            guard let recipeUUID = UUID(uuidString: assignment.recipeID),
                  let recipe = recipesByID[recipeUUID] else {
                continue
            }

            let targetDate = dateForDayOffset(assignment.dayOffset)
            results.append(MealPlanGenerationResult(date: targetDate, recipe: recipe))
        }

        guard !results.isEmpty else {
            throw MealPlanAIError.parsingFailed
        }

        return results.sorted { $0.date < $1.date }
    }

    private func parseReviewPlanResponse(from jsonResponse: String, recipes: [Recipe]) throws -> [MealPlanInsight] {
        let cleanedJSON = jsonResponse.strippingMarkdownCodeFences()

        guard let jsonData = cleanedJSON.data(using: .utf8) else {
            throw MealPlanAIError.parsingFailed
        }

        let responses: [MealPlanInsightResponse]
        do {
            responses = try JSONDecoder().decode([MealPlanInsightResponse].self, from: jsonData)
        } catch {
            throw MealPlanAIError.parsingFailed
        }

        let recipesByID = Dictionary(uniqueKeysWithValues: recipes.map { ($0.id, $0) })

        return responses.compactMap { response in
            guard let suggestionType = MealPlanSuggestionType(rawValue: response.suggestionType) else {
                return nil
            }

            // Resolve suggested recipe
            var suggestedRecipe: Recipe? = nil
            if let recipeIDString = response.suggestedRecipeID,
               let recipeUUID = UUID(uuidString: recipeIDString) {
                suggestedRecipe = recipesByID[recipeUUID]
            }

            // Resolve target date
            var targetDate: Date? = nil
            if let dayOffset = response.targetDayOffset {
                targetDate = dateForDayOffset(dayOffset)
            }

            // Resolve target meal type
            var targetMealType: MealType? = nil
            if let mealTypeString = response.targetMealType {
                targetMealType = MealType(rawValue: mealTypeString)
            }

            // Filter out non-actionable insights
            guard suggestedRecipe != nil,
                  targetDate != nil,
                  targetMealType != nil else {
                return nil
            }

            return MealPlanInsight(
                insight: response.insight,
                recommendation: response.recommendation,
                suggestedRecipe: suggestedRecipe,
                suggestionType: suggestionType,
                targetDate: targetDate,
                targetMealType: targetMealType
            )
        }
    }

    // MARK: - Helpers

    private func formatCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d 'at' h:mm a"
        return formatter.string(from: Date())
    }

    private func dateForDayOffset(_ offset: Int) -> Date {
        let today = Calendar.current.startOfDay(for: Date())
        return Calendar.current.date(byAdding: .day, value: offset, to: today) ?? today
    }
}
