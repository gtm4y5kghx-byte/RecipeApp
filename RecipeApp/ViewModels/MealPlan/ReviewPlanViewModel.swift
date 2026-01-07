import Foundation
import Observation

@Observable
@MainActor
class ReviewPlanViewModel {

    // MARK: - State

    private(set) var insights: [MealPlanInsight] = []
    private(set) var dismissedInsightIDs: Set<UUID> = []
    private(set) var appliedInsightIDs: Set<UUID> = []
    private(set) var isLoading: Bool = false
    private(set) var error: Error?

    // MARK: - Dependencies

    private let aiService: MealPlanAIService
    private let mealPlanService: MealPlanService
    private let entries: [MealPlanEntry]
    private let recipes: [Recipe]

    // MARK: - Init

    init(
        entries: [MealPlanEntry],
        recipes: [Recipe],
        mealPlanService: MealPlanService,
        aiService: MealPlanAIService
    ) {
        self.entries = entries
        self.recipes = recipes
        self.mealPlanService = mealPlanService
        self.aiService = aiService
    }

    // MARK: - Computed Properties

    var visibleInsights: [MealPlanInsight] {
        insights.filter { insight in
            !dismissedInsightIDs.contains(insight.id) && !appliedInsightIDs.contains(insight.id)
        }
    }

    var hasInsights: Bool {
        !visibleInsights.isEmpty
    }

    var allInsightsHandled: Bool {
        !insights.isEmpty && visibleInsights.isEmpty
    }

    // MARK: - Actions

    func loadInsights() async {
        isLoading = true
        error = nil

        do {
            insights = try await aiService.reviewPlan(entries: entries, recipes: recipes)
        } catch {
            self.error = error
            insights = []
        }

        isLoading = false
    }

    func applyInsight(_ insight: MealPlanInsight) {
        guard let recipe = insight.suggestedRecipe else { return }
        applyRecipe(recipe, for: insight)
    }

    func applyInsightWithRecipe(_ insight: MealPlanInsight, recipe: Recipe) {
        applyRecipe(recipe, for: insight)
    }

    func dismissInsight(_ insight: MealPlanInsight) {
        dismissedInsightIDs.insert(insight.id)
    }

    // MARK: - Private Helpers

    private func applyRecipe(_ recipe: Recipe, for insight: MealPlanInsight) {
        guard let targetDate = insight.targetDate,
              let targetMealType = insight.targetMealType else { return }

        // For swap: remove existing entry at target date/mealType
        if insight.suggestionType == .swap || insight.suggestionType == .varietyAlert {
            if let existingEntry = findExistingEntry(at: targetDate, mealType: targetMealType) {
                try? mealPlanService.removeEntry(existingEntry)
            }
        }

        // Add new entry
        _ = try? mealPlanService.addEntry(date: targetDate, mealType: targetMealType, recipe: recipe)

        appliedInsightIDs.insert(insight.id)
    }

    private func findExistingEntry(at date: Date, mealType: MealType) -> MealPlanEntry? {
        let targetDay = Calendar.current.startOfDay(for: date)
        return entries.first { entry in
            Calendar.current.startOfDay(for: entry.date) == targetDay && entry.mealType == mealType
        }
    }
}
