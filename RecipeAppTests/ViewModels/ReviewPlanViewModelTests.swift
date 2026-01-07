import Testing
import Foundation
import SwiftData
@testable import RecipeApp

@Suite("ReviewPlanViewModel Tests")
@MainActor
struct ReviewPlanViewModelTests {

    // MARK: - Initial State

    @Test("init sets dependencies correctly")
    func initSetsDependencies() throws {
        let (viewModel, _, _, _) = try createViewModel()

        #expect(viewModel.insights.isEmpty)
        #expect(viewModel.dismissedInsightIDs.isEmpty)
        #expect(viewModel.appliedInsightIDs.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
    }

    // MARK: - Load Insights

    @Test("loadInsights sets isLoading true then false")
    func loadInsightsSetsLoading() async throws {
        let (viewModel, mockService, _, _) = try createViewModel()
        mockService.mockInsights = []

        await viewModel.loadInsights()

        #expect(viewModel.isLoading == false)
    }

    @Test("loadInsights populates insights on success")
    func loadInsightsPopulatesOnSuccess() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        let insight = createInsight(recipe: recipes[0], type: .add)
        mockService.mockInsights = [insight]

        await viewModel.loadInsights()

        #expect(viewModel.insights.count == 1)
        #expect(viewModel.insights.first?.id == insight.id)
        #expect(viewModel.error == nil)
    }

    @Test("loadInsights sets error on failure")
    func loadInsightsSetsErrorOnFailure() async throws {
        let (viewModel, mockService, _, _) = try createViewModel()
        mockService.shouldThrowError = true

        await viewModel.loadInsights()

        #expect(viewModel.insights.isEmpty)
        #expect(viewModel.error != nil)
    }

    // MARK: - Visible Insights

    @Test("visibleInsights excludes dismissed")
    func visibleInsightsExcludesDismissed() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        let insight1 = createInsight(recipe: recipes[0], type: .add)
        let insight2 = createInsight(recipe: recipes[1], type: .swap)
        mockService.mockInsights = [insight1, insight2]

        await viewModel.loadInsights()
        viewModel.dismissInsight(insight1)

        #expect(viewModel.visibleInsights.count == 1)
        #expect(viewModel.visibleInsights.first?.id == insight2.id)
    }

    @Test("visibleInsights excludes applied")
    func visibleInsightsExcludesApplied() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        let insight1 = createInsight(recipe: recipes[0], type: .add, targetDate: Date(), targetMealType: .dinner)
        let insight2 = createInsight(recipe: recipes[1], type: .add, targetDate: Date(), targetMealType: .lunch)
        mockService.mockInsights = [insight1, insight2]

        await viewModel.loadInsights()
        viewModel.applyInsight(insight1)

        #expect(viewModel.visibleInsights.count == 1)
        #expect(viewModel.visibleInsights.first?.id == insight2.id)
    }

    // MARK: - Dismiss Insight

    @Test("dismissInsight adds id to dismissedInsightIDs")
    func dismissInsightAddsToSet() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        let insight = createInsight(recipe: recipes[0], type: .add)
        mockService.mockInsights = [insight]

        await viewModel.loadInsights()
        viewModel.dismissInsight(insight)

        #expect(viewModel.dismissedInsightIDs.contains(insight.id))
    }

    // MARK: - Apply Insight

    @Test("applyInsight for .add calls addEntry")
    func applyInsightAddCallsAddEntry() async throws {
        let (viewModel, mockService, recipes, context) = try createViewModel()
        let targetDate = Calendar.current.startOfDay(for: Date())
        let insight = createInsight(
            recipe: recipes[0],
            type: .add,
            targetDate: targetDate,
            targetMealType: .dinner
        )
        mockService.mockInsights = [insight]

        await viewModel.loadInsights()
        viewModel.applyInsight(insight)

        let mealPlanService = MealPlanService(modelContext: context)
        let entries = try mealPlanService.allEntries()
        #expect(entries.count == 1)
        #expect(entries.first?.recipe?.id == recipes[0].id)
        #expect(entries.first?.mealType == .dinner)
    }

    @Test("applyInsight for .swap removes existing then adds new")
    func applyInsightSwapRemovesThenAdds() async throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let recipes = createRecipesInContext(context, count: 3)
        let mealPlanService = MealPlanService(modelContext: context)

        // Create existing entry to be swapped
        let targetDate = Calendar.current.startOfDay(for: Date())
        try mealPlanService.addEntry(date: targetDate, mealType: .dinner, recipe: recipes[0])

        let mockService = MockMealPlanAIService()
        let entries = try mealPlanService.allEntries()
        let viewModel = ReviewPlanViewModel(
            entries: entries,
            recipes: recipes,
            mealPlanService: mealPlanService,
            aiService: mockService
        )

        let insight = createInsight(
            recipe: recipes[1],  // New recipe to swap in
            type: .swap,
            targetDate: targetDate,
            targetMealType: .dinner
        )
        mockService.mockInsights = [insight]

        await viewModel.loadInsights()
        viewModel.applyInsight(insight)

        let updatedEntries = try mealPlanService.allEntries()
        #expect(updatedEntries.count == 1)
        #expect(updatedEntries.first?.recipe?.id == recipes[1].id)
    }

    @Test("applyInsight adds id to appliedInsightIDs")
    func applyInsightAddsToAppliedSet() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        let insight = createInsight(
            recipe: recipes[0],
            type: .add,
            targetDate: Date(),
            targetMealType: .dinner
        )
        mockService.mockInsights = [insight]

        await viewModel.loadInsights()
        viewModel.applyInsight(insight)

        #expect(viewModel.appliedInsightIDs.contains(insight.id))
    }

    @Test("applyInsightWithRecipe uses provided recipe")
    func applyInsightWithRecipeUsesProvided() async throws {
        let (viewModel, mockService, recipes, context) = try createViewModel()
        let targetDate = Calendar.current.startOfDay(for: Date())
        let insight = createInsight(
            recipe: recipes[0],  // Original suggested recipe
            type: .add,
            targetDate: targetDate,
            targetMealType: .dinner
        )
        mockService.mockInsights = [insight]

        await viewModel.loadInsights()
        viewModel.applyInsightWithRecipe(insight, recipe: recipes[1])  // Different recipe

        let mealPlanService = MealPlanService(modelContext: context)
        let entries = try mealPlanService.allEntries()
        #expect(entries.count == 1)
        #expect(entries.first?.recipe?.id == recipes[1].id)  // Uses provided recipe
    }

    // MARK: - Computed Properties

    @Test("hasInsights false when all handled")
    func hasInsightsFalseWhenAllHandled() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        let insight = createInsight(recipe: recipes[0], type: .add)
        mockService.mockInsights = [insight]

        await viewModel.loadInsights()
        #expect(viewModel.hasInsights == true)

        viewModel.dismissInsight(insight)
        #expect(viewModel.hasInsights == false)
    }

    @Test("allInsightsHandled true when none visible")
    func allInsightsHandledTrueWhenNoneVisible() async throws {
        let (viewModel, mockService, recipes, _) = try createViewModel()
        let insight1 = createInsight(recipe: recipes[0], type: .add)
        let insight2 = createInsight(
            recipe: recipes[1],
            type: .add,
            targetDate: Date(),
            targetMealType: .dinner
        )
        mockService.mockInsights = [insight1, insight2]

        await viewModel.loadInsights()
        #expect(viewModel.allInsightsHandled == false)

        viewModel.dismissInsight(insight1)
        viewModel.applyInsight(insight2)
        #expect(viewModel.allInsightsHandled == true)
    }

    @Test("allInsightsHandled false when insights array is empty")
    func allInsightsHandledFalseWhenEmpty() async throws {
        let (viewModel, mockService, _, _) = try createViewModel()
        mockService.mockInsights = []

        await viewModel.loadInsights()

        #expect(viewModel.allInsightsHandled == false)
    }

    // MARK: - Helpers

    private func createViewModel() throws -> (
        ReviewPlanViewModel,
        MockMealPlanAIService,
        [Recipe],
        ModelContext
    ) {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let recipes = createRecipesInContext(context, count: 3)
        let mealPlanService = MealPlanService(modelContext: context)
        let mockService = MockMealPlanAIService()
        let viewModel = ReviewPlanViewModel(
            entries: [],
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

    private func createInsight(
        recipe: Recipe,
        type: MealPlanSuggestionType,
        targetDate: Date? = nil,
        targetMealType: MealType? = nil
    ) -> MealPlanInsight {
        MealPlanInsight(
            insight: "Test insight",
            recommendation: "Test recommendation",
            suggestedRecipe: recipe,
            suggestionType: type,
            targetDate: targetDate,
            targetMealType: targetMealType
        )
    }
}
