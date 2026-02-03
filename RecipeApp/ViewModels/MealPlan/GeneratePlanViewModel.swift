import Foundation
import Observation

@Observable
@MainActor
class GeneratePlanViewModel {
    
    // MARK: - Configuration State
    
    var selectedMealType: MealType = .dinner
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
        results.filter { !addedResultIDs.contains($0.id) }
    }
    
    var allResultsAdded: Bool {
        !results.isEmpty && remainingResults.isEmpty
    }

    var hasFewerResultsThanRequested: Bool {
        !results.isEmpty && results.count < selectedDayCount
    }

    var resultCountMessage: String? {
        guard hasFewerResultsThanRequested else { return nil }
        return String(localized: "Generated \(results.count) of \(selectedDayCount) days based on your recipes")
    }

    // MARK: - Actions
    
    func generatePlan() async {
        guard NetworkMonitor.shared.isConnected else {
            error = AIError.networkError
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
                mealType: selectedMealType,
                recipe: result.recipe
            )
            addedEntries[result.id] = entry
            addedResultIDs.insert(result.id)
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
