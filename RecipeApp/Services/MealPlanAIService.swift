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

        let candidates = RecipeCandidateSelector.selectCandidates(from: recipes, for: mealType)

        let systemPrompt = buildGeneratePlanSystemPrompt(dayCount: dayCount)
        let userPrompt = buildGeneratePlanUserPrompt(mealType: mealType, recipes: candidates, dayCount: dayCount)

        let jsonResponse = try await claudeClient.sendMessage(
            prompt: userPrompt,
            systemPrompt: systemPrompt,
            model: .haiku,
            maxTokens: 1024
        )

        return try parseGeneratePlanResponse(from: jsonResponse, recipes: candidates)
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
