import Foundation
import Observation

@Observable
@MainActor
class GeneratePlanViewModel {
    
    // MARK: - Configuration State
    
    var selectedMealType: MealType?
    var selectedDayCount: Int = 7
    
    // MARK: - Results State
    
    var results: [MealPlanGenerationResult] = []
    var addedResultIDs: Set<UUID> = []
    var isLoading: Bool = false
    var error: Error?
    
    private var addedEntries: [UUID: MealPlanEntry] = [:]
    
    // MARK: - Dependencies

    private let aiService: MealPlanAIService
    private let mealPlanService: MealPlanService
    private let recipes: [Recipe]
    private let defaults: UserDefaults

    // MARK: - Weekly Limit Constants

    private let weeklyLimit = 3
    private let generationCountKey = "meal_plan_generation_count"
    private let weekStartKey = "meal_plan_week_start"
    private let weekDuration: TimeInterval = 7 * 24 * 60 * 60

    // MARK: - Init

    init(
        recipes: [Recipe],
        mealPlanService: MealPlanService,
        aiService: MealPlanAIService,
        defaults: UserDefaults = .standard
    ) {
        self.recipes = recipes
        self.mealPlanService = mealPlanService
        self.aiService = aiService
        self.defaults = defaults
    }
    
    // MARK: - Computed Properties
    
    var hasResults: Bool {
        !results.isEmpty
    }
    
    var canGenerate: Bool {
        !recipes.isEmpty && !isLoading
    }

    var canAccessGeneration: Bool {
        UserSubscriptionService.shared.canGenerateMealPlan
    }
    
    var remainingResults: [MealPlanGenerationResult] {
        results.filter { !addedResultIDs.contains($0.id) }
    }
    
    var hasAddedAny: Bool {
        !addedResultIDs.isEmpty
    }

    var allResultsAdded: Bool {
        !results.isEmpty && remainingResults.isEmpty
    }

    var expectedResultCount: Int {
        selectedMealType == nil ? selectedDayCount * 3 : selectedDayCount
    }

    var hasFewerResultsThanRequested: Bool {
        !results.isEmpty && results.count < expectedResultCount
    }

    var resultCountMessage: String? {
        guard hasFewerResultsThanRequested else { return nil }
        let label = selectedMealType == nil ? "meals" : "days"
        return String(localized: "Generated \(results.count) of \(expectedResultCount) \(label) based on your recipes")
    }

    // MARK: - Weekly Limit

    var remainingGenerations: Int {
        resetIfNewWeek()
        let count = defaults.integer(forKey: generationCountKey)
        return max(0, weeklyLimit - count)
    }

    var hasReachedWeeklyLimit: Bool {
        remainingGenerations <= 0
    }

    private func resetIfNewWeek() {
        guard let weekStart = defaults.object(forKey: weekStartKey) as? Date else { return }
        if Date().timeIntervalSince(weekStart) >= weekDuration {
            defaults.set(0, forKey: generationCountKey)
            defaults.removeObject(forKey: weekStartKey)
        }
    }

    private func incrementGenerationCount() {
        resetIfNewWeek()
        if defaults.object(forKey: weekStartKey) == nil {
            defaults.set(Date(), forKey: weekStartKey)
        }
        let count = defaults.integer(forKey: generationCountKey)
        defaults.set(count + 1, forKey: generationCountKey)
    }

    // MARK: - Actions
    
    func generatePlan() async {
        guard NetworkMonitor.shared.isConnected else {
            error = AIError.networkError
            return
        }

        guard !hasReachedWeeklyLimit else {
            error = AIError.weeklyLimitReached
            return
        }

        isLoading = true
        error = nil

        do {
            results = try await aiService.generatePlan(
                for: selectedMealType,
                recipes: recipes,
                dayCount: selectedDayCount
            )
            if !results.isEmpty {
                incrementGenerationCount()
            }
        } catch {
            self.error = error
            results = []
        }

        isLoading = false
    }
    
    func addResult(_ result: MealPlanGenerationResult) {
        do {
            let entry = try mealPlanService.addEntry(
                date: result.date,
                mealType: result.mealType,
                recipe: result.recipe
            )
            addedEntries[result.id] = entry
            addedResultIDs.insert(result.id)
            MealPlanViewModel.needsReload = true
        } catch {
            self.error = MealPlanError.saveFailed
        }
    }

    func removeResult(_ result: MealPlanGenerationResult) {
        guard let entry = addedEntries[result.id] else { return }
        do {
            try mealPlanService.removeEntry(entry)
            addedEntries.removeValue(forKey: result.id)
            addedResultIDs.remove(result.id)
        } catch {
            self.error = MealPlanError.deleteFailed
        }
    }
    
    func deleteResult(_ result: MealPlanGenerationResult) {
        // If already added to meal plan, remove it first
        if addedResultIDs.contains(result.id) {
            removeResult(result)
        }
        // Remove from results array
        results.removeAll { $0.id == result.id }
    }
    
    func addAllRemaining() {
        for result in remainingResults {
            addResult(result)
        }
    }
    
    func swapRecipe(for result: MealPlanGenerationResult, with recipe: Recipe) {
        guard let index = results.firstIndex(where: { $0.id == result.id }) else { return }
        results[index].recipe = recipe
    }
    
    func isAdded(_ result: MealPlanGenerationResult) -> Bool {
        addedResultIDs.contains(result.id)
    }
    
    func reset() {
        results = []
        addedResultIDs = []
        addedEntries = [:]
        error = nil
    }
}
