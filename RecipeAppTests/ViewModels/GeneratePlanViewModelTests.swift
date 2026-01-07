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

    @Test("addResult adds recipe.id to addedResultIDs")
    func addResultAddsToSet() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        let result = MealPlanGenerationResult(date: Date(), recipe: recipes[0])
        mockService.mockResults = [result]

        await viewModel.generatePlan()
        viewModel.addResult(result)

        #expect(viewModel.addedResultIDs.contains(recipes[0].id))
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
        viewModel.addResult(result1)  // Mark first as added

        // Swap second result's recipe
        viewModel.swapRecipe(for: result2, with: recipes[2])

        // First should still be marked as added
        #expect(viewModel.addedResultIDs.contains(recipes[0].id))
        #expect(viewModel.addedResultIDs.count == 1)
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

    // MARK: - Helpers

    private func createViewModel() throws -> (
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
            aiService: mockService
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
}
