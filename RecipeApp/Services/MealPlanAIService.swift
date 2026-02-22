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
        for mealType: MealType?,
        recipes: [Recipe],
        dayCount: Int = 7
    ) async throws -> [MealPlanGenerationResult] {
        guard !recipes.isEmpty else {
            throw AIError.emptyCollection
        }

        guard recipes.count >= minimumRecipeCount else {
            throw AIError.insufficientRecipes(available: recipes.count, required: minimumRecipeCount)
        }

        let candidates = RecipeCandidateSelector.selectCandidates(from: recipes, for: mealType)

        let systemPrompt = buildGeneratePlanSystemPrompt(mealType: mealType, dayCount: dayCount)
        let userPrompt = buildGeneratePlanUserPrompt(mealType: mealType, recipes: candidates, dayCount: dayCount)

        let maxTokens = mealType == nil ? 2048 : 1024

        let jsonResponse = try await claudeClient.sendMessage(
            prompt: userPrompt,
            systemPrompt: systemPrompt,
            model: .haiku,
            maxTokens: maxTokens
        )

        return try parseGeneratePlanResponse(from: jsonResponse, mealType: mealType, recipes: candidates)
    }

    // MARK: - Generate Plan Prompts

    private func buildGeneratePlanSystemPrompt(mealType: MealType?, dayCount: Int) -> String {
        let maxDayOffset = dayCount - 1
        let mealsPerDay = mealType == nil ? "three (breakfast, lunch, dinner)" : "one"
        let mealTypeNote = mealType == nil
            ? "- mealType: one of \"breakfast\", \"lunch\", or \"dinner\""
            : "- mealType: always \"\(mealType!.rawValue)\""

        return """
        You are a meal planning assistant. Select recipes from the user's collection to create a meal plan.

        CRITICAL RULES:
        1. Return ONLY raw JSON - no markdown, no ```json blocks, no explanation
        2. Select \(mealsPerDay) recipe(s) per day for the specified number of days
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
          {"dayOffset": 0, "mealType": "dinner", "recipeID": "uuid-here"},
          {"dayOffset": 1, "mealType": "dinner", "recipeID": "uuid-here"}
        ]

        NOTES:
        - dayOffset: 0 = today, 1 = tomorrow, ..., \(maxDayOffset) = \(maxDayOffset) days from now
        \(mealTypeNote)
        - If fewer suitable recipes exist than slots requested, return what you can
        """
    }

    private func buildGeneratePlanUserPrompt(mealType: MealType?, recipes: [Recipe], dayCount: Int) -> String {
        let catalogContext = RecipeContextFormatter.formatCatalog(recipes)
        let mealTypeLabel = mealType?.rawValue.capitalized ?? "All meals (breakfast, lunch, dinner)"
        let instruction: String
        if let mealType {
            instruction = "Create a \(mealType.rawValue) plan for the next \(dayCount) days. Select \(dayCount) recipes."
        } else {
            instruction = "Create a full meal plan (breakfast, lunch, and dinner) for the next \(dayCount) days. Select up to \(dayCount * 3) recipes."
        }

        return """
        Current time: \(formatCurrentTime())
        Meal type: \(mealTypeLabel)
        Days to plan: \(dayCount)

        User's Recipe Collection (\(recipes.count) recipes):
        \(catalogContext)

        \(instruction)
        Provide variety and match the user's cooking patterns.

        Return ONLY the JSON array, nothing else.
        """
    }

    // MARK: - Response Parsing

    private func parseGeneratePlanResponse(from jsonResponse: String, mealType: MealType?, recipes: [Recipe]) throws -> [MealPlanGenerationResult] {
        let cleanedJSON = jsonResponse.strippingMarkdownCodeFences()

        guard let jsonData = cleanedJSON.data(using: .utf8) else {
            throw AIError.parsingFailed
        }

        let assignments: [MealPlanAssignment]
        do {
            assignments = try JSONDecoder().decode([MealPlanAssignment].self, from: jsonData)
        } catch {
            throw AIError.parsingFailed
        }

        let recipesByID = Dictionary(uniqueKeysWithValues: recipes.map { ($0.id, $0) })

        var results: [MealPlanGenerationResult] = []

        for assignment in assignments {
            guard let recipeUUID = UUID(uuidString: assignment.recipeID),
                  let recipe = recipesByID[recipeUUID] else {
                continue
            }

            let resolvedMealType = MealType(rawValue: assignment.mealType) ?? mealType ?? .dinner
            let targetDate = dateForDayOffset(assignment.dayOffset)
            results.append(MealPlanGenerationResult(date: targetDate, mealType: resolvedMealType, recipe: recipe))
        }

        guard !results.isEmpty else {
            throw AIError.parsingFailed
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
