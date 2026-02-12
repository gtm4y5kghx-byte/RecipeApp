import Testing
import Foundation
import SwiftData
@testable import RecipeApp

@Suite("GeneratePlanViewModel Tests")
@MainActor
struct GeneratePlanViewModelTests {

    // MARK: - Initial State

    @Test("init sets dependencies correctly")
    func initSetsDependencies() throws {
        let (viewModel, _, _, _) = try createViewModel()

        #expect(viewModel.selectedMealType == .dinner)
        #expect(viewModel.selectedDayCount == 7)
        #expect(viewModel.results.isEmpty)
        #expect(viewModel.addedResultIDs.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
    }

    // MARK: - Can Generate

    @Test("canGenerate false when recipes empty")
    func canGenerateFalseWhenEmpty() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let mealPlanService = MealPlanService(modelContext: context)
        let mockService = MockMealPlanAIService()
        let viewModel = GeneratePlanViewModel(
            recipes: [],
            mealPlanService: mealPlanService,
            aiService: mockService
        )

        #expect(viewModel.canGenerate == false)
    }

    @Test("canGenerate false when isLoading")
    func canGenerateFalseWhenLoading() async throws {
        let (viewModel, mockService, _, _) = try createViewModel()

        // Start generation but don't await - check loading state
        mockService.mockResults = []
        let task = Task { await viewModel.generatePlan() }

        // Give time for isLoading to be set
        try await Task.sleep(for: .milliseconds(10))

        // After completion, isLoading should be false
        await task.value
        #expect(viewModel.isLoading == false)
    }

    @Test("canGenerate true when recipes exist and not loading")
    func canGenerateTrueWhenReady() throws {
        let (viewModel, _, _, _) = try createViewModel()

        #expect(viewModel.canGenerate == true)
    }

    // MARK: - Generate Plan

    @Test("generatePlan sets isLoading true then false")
    func generatePlanSetsLoading() async throws {
        let (viewModel, mockService, _, _) = try createViewModel()
        mockService.mockResults = []

        await viewModel.generatePlan()

        #expect(viewModel.isLoading == false)
    }

    @Test("generatePlan populates results on success")
    func generatePlanPopulatesOnSuccess() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        let result = MealPlanGenerationResult(date: Date(), recipe: recipes[0])
        mockService.mockResults = [result]

        await viewModel.generatePlan()

        #expect(viewModel.results.count == 1)
        #expect(viewModel.results.first?.recipe.id == recipes[0].id)
        #expect(viewModel.error == nil)
    }

    @Test("generatePlan sets error on failure")
    func generatePlanSetsErrorOnFailure() async throws {
        let (viewModel, mockService, _, _) = try createViewModel()
        mockService.shouldThrowError = true

        await viewModel.generatePlan()

        #expect(viewModel.results.isEmpty)
        #expect(viewModel.error != nil)
    }

    @Test("generatePlan uses selected mealType and dayCount")
    func generatePlanUsesConfiguration() async throws {
        let (viewModel, mockService, _, _) = try createViewModel()
        viewModel.selectedMealType = .breakfast
        viewModel.selectedDayCount = 5
        mockService.mockResults = []

        await viewModel.generatePlan()

        #expect(mockService.lastMealType == .breakfast)
        #expect(mockService.lastDayCount == 5)
    }

    // MARK: - Add Result

    @Test("addResult calls mealPlanService.addEntry")
    func addResultCallsAddEntry() async throws {
        let (viewModel, mockService, recipes, context) = try createViewModel()
        let targetDate = Calendar.current.startOfDay(for: Date())
        let result = MealPlanGenerationResult(date: targetDate, recipe: recipes[0])
        mockService.mockResults = [result]

        await viewModel.generatePlan()
        viewModel.addResult(result)

        let mealPlanService = MealPlanService(modelContext: context)
        let entries = try mealPlanService.allEntries()
        #expect(entries.count == 1)
        #expect(entries.first?.recipe?.id == recipes[0].id)
    }

    @Test("addResult adds result.id to addedResultIDs")
    func addResultAddsToSet() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        let result = MealPlanGenerationResult(date: Date(), recipe: recipes[0])
        mockService.mockResults = [result]

        await viewModel.generatePlan()

        // Get the actual result from viewModel (has same date/recipe but different id)
        let actualResult = viewModel.results.first!
        viewModel.addResult(actualResult)

        #expect(viewModel.addedResultIDs.contains(actualResult.id))
    }

    @Test("addResult uses selectedMealType")
    func addResultUsesMealType() async throws {
        let (viewModel, mockService, recipes, context) = try createViewModel()
        viewModel.selectedMealType = .breakfast
        let result = MealPlanGenerationResult(date: Date(), recipe: recipes[0])
        mockService.mockResults = [result]

        await viewModel.generatePlan()
        viewModel.addResult(result)

        let mealPlanService = MealPlanService(modelContext: context)
        let entries = try mealPlanService.allEntries()
        #expect(entries.first?.mealType == .breakfast)
    }

    // MARK: - Is Added

    @Test("isAdded returns true after addResult")
    func isAddedReturnsTrue() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        let result = MealPlanGenerationResult(date: Date(), recipe: recipes[0])
        mockService.mockResults = [result]

        await viewModel.generatePlan()
        #expect(viewModel.isAdded(result) == false)

        viewModel.addResult(result)
        #expect(viewModel.isAdded(result) == true)
    }

    // MARK: - Remaining Results

    @Test("remainingResults excludes added results")
    func remainingResultsExcludesAdded() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        let result1 = MealPlanGenerationResult(date: Date(), recipe: recipes[0])
        let result2 = MealPlanGenerationResult(
            date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            recipe: recipes[1]
        )
        mockService.mockResults = [result1, result2]

        await viewModel.generatePlan()
        viewModel.addResult(result1)

        #expect(viewModel.remainingResults.count == 1)
        #expect(viewModel.remainingResults.first?.recipe.id == recipes[1].id)
    }

    // MARK: - Add All Remaining

    @Test("addAllRemaining adds all remaining")
    func addAllRemainingAddsAll() async throws {
        let (viewModel, mockService, recipes, context) = try createViewModel()
        let result1 = MealPlanGenerationResult(date: Date(), recipe: recipes[0])
        let result2 = MealPlanGenerationResult(
            date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            recipe: recipes[1]
        )
        mockService.mockResults = [result1, result2]

        await viewModel.generatePlan()
        viewModel.addResult(result1)  // Add first one
        viewModel.addAllRemaining()   // Should add the second

        let mealPlanService = MealPlanService(modelContext: context)
        let entries = try mealPlanService.allEntries()
        #expect(entries.count == 2)
        #expect(viewModel.addedResultIDs.count == 2)
    }

    // MARK: - Has Added Any

    @Test("hasAddedAny false initially")
    func hasAddedAnyFalseInitially() throws {
        let (viewModel, _, _, _) = try createViewModel()

        #expect(viewModel.hasAddedAny == false)
    }

    @Test("hasAddedAny true after adding one result")
    func hasAddedAnyTrueAfterAdding() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        let result = MealPlanGenerationResult(date: Date(), recipe: recipes[0])
        mockService.mockResults = [result]

        await viewModel.generatePlan()
        viewModel.addResult(result)

        #expect(viewModel.hasAddedAny == true)
    }

    @Test("hasAddedAny false after removing all added")
    func hasAddedAnyFalseAfterRemovingAll() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        let result = MealPlanGenerationResult(date: Date(), recipe: recipes[0])
        mockService.mockResults = [result]

        await viewModel.generatePlan()
        let actualResult = viewModel.results.first!
        viewModel.addResult(actualResult)
        #expect(viewModel.hasAddedAny == true)

        viewModel.removeResult(actualResult)
        #expect(viewModel.hasAddedAny == false)
    }

    // MARK: - All Results Added

    @Test("allResultsAdded true when all added")
    func allResultsAddedTrueWhenAllAdded() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        let result = MealPlanGenerationResult(date: Date(), recipe: recipes[0])
        mockService.mockResults = [result]

        await viewModel.generatePlan()
        #expect(viewModel.allResultsAdded == false)

        viewModel.addResult(result)
        #expect(viewModel.allResultsAdded == true)
    }

    @Test("allResultsAdded false when results empty")
    func allResultsAddedFalseWhenEmpty() throws {
        let (viewModel, _, _, _) = try createViewModel()

        #expect(viewModel.allResultsAdded == false)
    }

    // MARK: - Swap Recipe

    @Test("swapRecipe replaces recipe in results")
    func swapRecipeReplacesRecipe() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        let originalResult = MealPlanGenerationResult(date: Date(), recipe: recipes[0])
        mockService.mockResults = [originalResult]

        await viewModel.generatePlan()
        viewModel.swapRecipe(for: originalResult, with: recipes[1])

        #expect(viewModel.results.first?.recipe.id == recipes[1].id)
        #expect(viewModel.results.first?.date == originalResult.date)
    }

    @Test("swapRecipe preserves addedResultIDs")
    func swapRecipePreservesAddedIDs() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        let result1 = MealPlanGenerationResult(date: Date(), recipe: recipes[0])
        let result2 = MealPlanGenerationResult(
            date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            recipe: recipes[1]
        )
        mockService.mockResults = [result1, result2]

        await viewModel.generatePlan()

        // Get actual results from viewModel
        let actualResult1 = viewModel.results[0]
        let actualResult2 = viewModel.results[1]

        viewModel.addResult(actualResult1)  // Mark first as added

        // Swap second result's recipe
        viewModel.swapRecipe(for: actualResult2, with: recipes[2])

        // First should still be marked as added (by result.id)
        #expect(viewModel.addedResultIDs.contains(actualResult1.id))
        #expect(viewModel.addedResultIDs.count == 1)
    }

    @Test("swapRecipe preserves result ID")
    func swapRecipePreservesResultID() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        let result = MealPlanGenerationResult(date: Date(), recipe: recipes[0])
        mockService.mockResults = [result]

        await viewModel.generatePlan()
        let originalID = viewModel.results.first!.id

        viewModel.swapRecipe(for: viewModel.results.first!, with: recipes[1])

        // ID should remain the same after swap
        #expect(viewModel.results.first!.id == originalID)
        // But recipe should be different
        #expect(viewModel.results.first!.recipe.id == recipes[1].id)
    }

    // MARK: - Remove Result

    @Test("removeResult removes from addedResultIDs")
    func removeResultRemovesFromSet() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        let result = MealPlanGenerationResult(date: Date(), recipe: recipes[0])
        mockService.mockResults = [result]

        await viewModel.generatePlan()
        let actualResult = viewModel.results.first!

        viewModel.addResult(actualResult)
        #expect(viewModel.isAdded(actualResult) == true)

        viewModel.removeResult(actualResult)
        #expect(viewModel.isAdded(actualResult) == false)
    }

    @Test("removeResult removes entry from meal plan")
    func removeResultRemovesEntry() async throws {
        let (viewModel, mockService, recipes, context) = try createViewModel()
        let result = MealPlanGenerationResult(date: Date(), recipe: recipes[0])
        mockService.mockResults = [result]

        await viewModel.generatePlan()
        let actualResult = viewModel.results.first!

        viewModel.addResult(actualResult)
        let mealPlanService = MealPlanService(modelContext: context)
        #expect(try mealPlanService.allEntries().count == 1)

        viewModel.removeResult(actualResult)
        #expect(try mealPlanService.allEntries().count == 0)
    }

    @Test("removeResult does nothing if not added")
    func removeResultDoesNothingIfNotAdded() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        let result = MealPlanGenerationResult(date: Date(), recipe: recipes[0])
        mockService.mockResults = [result]

        await viewModel.generatePlan()
        let actualResult = viewModel.results.first!

        // Never added, so remove should do nothing
        viewModel.removeResult(actualResult)
        #expect(viewModel.addedResultIDs.isEmpty)
    }

    @Test("remainingResults updates after remove")
    func remainingResultsUpdatesAfterRemove() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        let result1 = MealPlanGenerationResult(date: Date(), recipe: recipes[0])
        let result2 = MealPlanGenerationResult(
            date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            recipe: recipes[1]
        )
        mockService.mockResults = [result1, result2]

        await viewModel.generatePlan()
        let actualResult1 = viewModel.results[0]
        let actualResult2 = viewModel.results[1]

        // Add both
        viewModel.addResult(actualResult1)
        viewModel.addResult(actualResult2)
        #expect(viewModel.remainingResults.count == 0)

        // Remove one
        viewModel.removeResult(actualResult1)
        #expect(viewModel.remainingResults.count == 1)
        #expect(viewModel.remainingResults.first?.id == actualResult1.id)
    }

    // MARK: - Delete Result

    @Test("deleteResult removes from results array")
    func deleteResultRemovesFromArray() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        let result = MealPlanGenerationResult(date: Date(), recipe: recipes[0])
        mockService.mockResults = [result]

        await viewModel.generatePlan()
        #expect(viewModel.results.count == 1)

        viewModel.deleteResult(viewModel.results.first!)
        #expect(viewModel.results.isEmpty)
    }

    @Test("deleteResult removes from meal plan if added")
    func deleteResultRemovesFromMealPlanIfAdded() async throws {
        let (viewModel, mockService, recipes, context) = try createViewModel()
        let result = MealPlanGenerationResult(date: Date(), recipe: recipes[0])
        mockService.mockResults = [result]

        await viewModel.generatePlan()
        let actualResult = viewModel.results.first!
        viewModel.addResult(actualResult)

        let mealPlanService = MealPlanService(modelContext: context)
        #expect(try mealPlanService.allEntries().count == 1)

        viewModel.deleteResult(actualResult)
        #expect(try mealPlanService.allEntries().count == 0)
        #expect(viewModel.addedResultIDs.isEmpty)
    }

    @Test("deleteResult updates remainingResults")
    func deleteResultUpdatesRemainingResults() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        let result1 = MealPlanGenerationResult(date: Date(), recipe: recipes[0])
        let result2 = MealPlanGenerationResult(
            date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            recipe: recipes[1]
        )
        mockService.mockResults = [result1, result2]

        await viewModel.generatePlan()

        // Delete first result (not added)
        viewModel.deleteResult(viewModel.results.first!)

        #expect(viewModel.results.count == 1)
        #expect(viewModel.remainingResults.count == 1)
    }

    @Test("hasResults false after deleting all results")
    func hasResultsFalseAfterDeletingAll() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        let result = MealPlanGenerationResult(date: Date(), recipe: recipes[0])
        mockService.mockResults = [result]

        await viewModel.generatePlan()
        #expect(viewModel.hasResults == true)

        viewModel.deleteResult(viewModel.results.first!)
        #expect(viewModel.hasResults == false)
    }

    // MARK: - Reset

    @Test("reset clears results and addedResultIDs")
    func resetClearsResults() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        let result = MealPlanGenerationResult(date: Date(), recipe: recipes[0])
        mockService.mockResults = [result]

        await viewModel.generatePlan()
        viewModel.addResult(result)
        viewModel.reset()

        #expect(viewModel.results.isEmpty)
        #expect(viewModel.addedResultIDs.isEmpty)
        #expect(viewModel.error == nil)
    }

    @Test("reset preserves configuration")
    func resetPreservesConfiguration() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        viewModel.selectedMealType = .lunch
        viewModel.selectedDayCount = 3
        let result = MealPlanGenerationResult(date: Date(), recipe: recipes[0])
        mockService.mockResults = [result]

        await viewModel.generatePlan()
        viewModel.reset()

        #expect(viewModel.selectedMealType == .lunch)
        #expect(viewModel.selectedDayCount == 3)
    }

    // MARK: - Has Results

    @Test("hasResults true when results exist")
    func hasResultsTrueWhenExist() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        let result = MealPlanGenerationResult(date: Date(), recipe: recipes[0])
        mockService.mockResults = [result]

        #expect(viewModel.hasResults == false)
        await viewModel.generatePlan()
        #expect(viewModel.hasResults == true)
    }

    // MARK: - Weekly Limit

    @Test("remainingGenerations is 3 initially")
    func remainingGenerationsInitially() throws {
        let defaults = freshUserDefaults()
        let (viewModel, _, _, _) = try createViewModel(defaults: defaults)

        #expect(viewModel.remainingGenerations == 3)
    }

    @Test("hasReachedWeeklyLimit is false initially")
    func hasReachedWeeklyLimitFalseInitially() throws {
        let defaults = freshUserDefaults()
        let (viewModel, _, _, _) = try createViewModel(defaults: defaults)

        #expect(viewModel.hasReachedWeeklyLimit == false)
    }

    @Test("successful generation decrements remaining count")
    func successfulGenerationDecrements() async throws {
        let defaults = freshUserDefaults()
        let (viewModel, mockService, recipes, _) = try createViewModel(defaults: defaults)
        mockService.mockResults = [MealPlanGenerationResult(date: Date(), recipe: recipes[0])]

        await viewModel.generatePlan()

        #expect(viewModel.remainingGenerations == 2)
    }

    @Test("failed generation does not decrement remaining count")
    func failedGenerationDoesNotDecrement() async throws {
        let defaults = freshUserDefaults()
        let (viewModel, mockService, _, _) = try createViewModel(defaults: defaults)
        mockService.shouldThrowError = true

        await viewModel.generatePlan()

        #expect(viewModel.remainingGenerations == 3)
    }

    @Test("generatePlan sets error when weekly limit reached")
    func generatePlanSetsErrorWhenLimitReached() async throws {
        let defaults = freshUserDefaults()
        let (viewModel, mockService, recipes, _) = try createViewModel(defaults: defaults)
        mockService.mockResults = [MealPlanGenerationResult(date: Date(), recipe: recipes[0])]

        await viewModel.generatePlan()
        await viewModel.generatePlan()
        await viewModel.generatePlan()

        #expect(viewModel.remainingGenerations == 0)
        #expect(viewModel.hasReachedWeeklyLimit == true)

        mockService.mockResults = [MealPlanGenerationResult(date: Date(), recipe: recipes[1])]
        await viewModel.generatePlan()

        #expect(viewModel.error is AIError)
    }

    @Test("limit resets after 7 days")
    func limitResetsAfterSevenDays() async throws {
        let defaults = freshUserDefaults()
        let (viewModel, mockService, recipes, _) = try createViewModel(defaults: defaults)
        mockService.mockResults = [MealPlanGenerationResult(date: Date(), recipe: recipes[0])]

        await viewModel.generatePlan()
        await viewModel.generatePlan()
        await viewModel.generatePlan()
        #expect(viewModel.remainingGenerations == 0)

        let eightDaysAgo = Date(timeIntervalSinceNow: -8 * 24 * 60 * 60)
        defaults.set(eightDaysAgo, forKey: "meal_plan_week_start")

        #expect(viewModel.remainingGenerations == 3)
        #expect(viewModel.hasReachedWeeklyLimit == false)
    }

    @Test("empty results do not count toward limit")
    func emptyResultsDoNotCount() async throws {
        let defaults = freshUserDefaults()
        let (viewModel, mockService, _, _) = try createViewModel(defaults: defaults)
        mockService.mockResults = []

        await viewModel.generatePlan()

        #expect(viewModel.remainingGenerations == 3)
    }

    // MARK: - Helpers

    private func createViewModel(defaults: UserDefaults? = nil) throws -> (
        GeneratePlanViewModel,
        MockMealPlanAIService,
        [Recipe],
        ModelContext
    ) {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let recipes = createRecipesInContext(context, count: 3)
        let mealPlanService = MealPlanService(modelContext: context)
        let mockService = MockMealPlanAIService()
        let viewModel = GeneratePlanViewModel(
            recipes: recipes,
            mealPlanService: mealPlanService,
            aiService: mockService,
            defaults: defaults ?? freshUserDefaults()
        )
        return (viewModel, mockService, recipes, context)
    }

    private func createRecipesInContext(_ context: ModelContext, count: Int) -> [Recipe] {
        let recipes = (0..<count).map { index in
            RecipeTestFixtures.createRecipe(title: "Recipe \(index)")
        }
        recipes.forEach { context.insert($0) }
        return recipes
    }

    private func freshUserDefaults() -> UserDefaults {
        let suiteName = "test.generate.plan.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}
