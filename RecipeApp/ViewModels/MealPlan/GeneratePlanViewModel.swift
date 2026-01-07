import Foundation
import Observation

@Observable
@MainActor
class GeneratePlanViewModel {

    // MARK: - Configuration State

    var selectedMealType: MealType = .dinner
    var selectedDayCount: Int = 7

    // MARK: - Results State

    private(set) var results: [MealPlanGenerationResult] = []
    private(set) var addedResultIDs: Set<UUID> = []
    private(set) var isLoading: Bool = false
    private(set) var error: Error?

    // MARK: - Dependencies

    private let aiService: MealPlanAIService
    private let mealPlanService: MealPlanService
    private let recipes: [Recipe]

    // MARK: - Init

    init(
        recipes: [Recipe],
        mealPlanService: MealPlanService,
        aiService: MealPlanAIService
    ) {
        self.recipes = recipes
        self.mealPlanService = mealPlanService
        self.aiService = aiService
    }

    // MARK: - Computed Properties

    var hasResults: Bool {
        !results.isEmpty
    }

    var canGenerate: Bool {
        !recipes.isEmpty && !isLoading
    }

    var remainingResults: [MealPlanGenerationResult] {
        results.filter { !addedResultIDs.contains($0.recipe.id) }
    }

    var allResultsAdded: Bool {
        !results.isEmpty && remainingResults.isEmpty
    }

    // MARK: - Actions

    func generatePlan() async {
        isLoading = true
        error = nil

        do {
            results = try await aiService.generatePlan(
                for: selectedMealType,
                recipes: recipes,
                dayCount: selectedDayCount
            )
        } catch {
            self.error = error
            results = []
        }

        isLoading = false
    }

    func addResult(_ result: MealPlanGenerationResult) {
        _ = try? mealPlanService.addEntry(
            date: result.date,
            mealType: selectedMealType,
            recipe: result.recipe
        )
        addedResultIDs.insert(result.recipe.id)
    }

    func addAllRemaining() {
        for result in remainingResults {
            addResult(result)
        }
    }

    func swapRecipe(for result: MealPlanGenerationResult, with recipe: Recipe) {
        guard let index = results.firstIndex(where: { $0.date == result.date }) else { return }
        results[index] = MealPlanGenerationResult(date: result.date, recipe: recipe)
    }

    func isAdded(_ result: MealPlanGenerationResult) -> Bool {
        addedResultIDs.contains(result.recipe.id)
    }

    func reset() {
        results = []
        addedResultIDs = []
        error = nil
    }
}
