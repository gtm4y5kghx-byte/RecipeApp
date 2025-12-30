import Testing
import Foundation
import SwiftData
@testable import RecipeApp

@Suite("DiscoverViewModel Tests")
@MainActor
struct DiscoverViewModelTests {

    // MARK: - Initial State Tests

    @Test("Initial state has empty generated recipes")
    func initialStateEmptyRecipes() {
        let viewModel = createViewModel()
        #expect(viewModel.generatedRecipes.isEmpty)
    }

    @Test("Initial state is not loading")
    func initialStateNotLoading() {
        let viewModel = createViewModel()
        #expect(viewModel.isLoading == false)
    }

    @Test("Initial state has no error")
    func initialStateNoError() {
        let viewModel = createViewModel()
        #expect(viewModel.error == nil)
    }

    // MARK: - Premium & Threshold Tests

    @Test("isPremium reflects subscription service")
    func isPremiumReflectsService() {
        setPremium(true)
        let viewModel = createViewModel()
        #expect(viewModel.isPremium == true)

        setPremium(false)
        let viewModel2 = createViewModel()
        #expect(viewModel2.isPremium == false)
    }

    @Test("canGenerate is true when premium and has 10+ recipes")
    func canGenerateWhenEligible() {
        setPremium(true)
        let recipes = createRecipes(count: 10)
        let viewModel = createViewModel(recipes: recipes)

        #expect(viewModel.canGenerate == true)
    }

    @Test("canGenerate is false when not premium")
    func canGenerateFalseWhenNotPremium() {
        setPremium(false)
        let recipes = createRecipes(count: 15)
        let viewModel = createViewModel(recipes: recipes)

        #expect(viewModel.canGenerate == false)
    }

    @Test("canGenerate is false when below threshold")
    func canGenerateFalseBelowThreshold() {
        setPremium(true)
        let recipes = createRecipes(count: 5)
        let viewModel = createViewModel(recipes: recipes)

        #expect(viewModel.canGenerate == false)
    }

    // MARK: - Load Generated Recipes Tests

    @Test("loadGeneratedRecipes populates recipes on success")
    func loadPopulatesRecipes() async {
        setPremium(true)
        let mockService = MockRecipeGenerationService()
        mockService.mockGeneratedRecipes = [
            RecipeTestFixtures.createGeneratedRecipe(title: "Recipe 1"),
            RecipeTestFixtures.createGeneratedRecipe(title: "Recipe 2")
        ]

        let recipes = createRecipes(count: 10)
        let viewModel = createViewModel(recipes: recipes, generationService: mockService)

        await viewModel.loadGeneratedRecipes()

        #expect(viewModel.generatedRecipes.count == 2)
        #expect(viewModel.generatedRecipes[0].title == "Recipe 1")
    }

    @Test("loadGeneratedRecipes sets isLoading during load")
    func loadSetsIsLoading() async {
        setPremium(true)
        let mockService = MockRecipeGenerationService()
        mockService.mockGeneratedRecipes = [RecipeTestFixtures.createGeneratedRecipe()]

        let recipes = createRecipes(count: 10)
        let viewModel = createViewModel(recipes: recipes, generationService: mockService)

        #expect(viewModel.isLoading == false)

        await viewModel.loadGeneratedRecipes()

        #expect(viewModel.isLoading == false)
    }

    @Test("loadGeneratedRecipes sets error on failure")
    func loadSetsErrorOnFailure() async {
        setPremium(true)
        let mockService = MockRecipeGenerationService()
        mockService.shouldThrowError = true

        let recipes = createRecipes(count: 10)
        let viewModel = createViewModel(recipes: recipes, generationService: mockService)

        await viewModel.loadGeneratedRecipes()

        #expect(viewModel.error != nil)
        #expect(viewModel.generatedRecipes.isEmpty)
    }

    @Test("loadGeneratedRecipes does nothing when not premium")
    func loadDoesNothingWhenNotPremium() async {
        setPremium(false)
        let mockService = MockRecipeGenerationService()
        mockService.mockGeneratedRecipes = [RecipeTestFixtures.createGeneratedRecipe()]

        let recipes = createRecipes(count: 10)
        let viewModel = createViewModel(recipes: recipes, generationService: mockService)

        await viewModel.loadGeneratedRecipes()

        #expect(mockService.getGeneratedRecipesCallCount == 0)
        #expect(viewModel.generatedRecipes.isEmpty)
    }

    @Test("loadGeneratedRecipes does nothing below threshold")
    func loadDoesNothingBelowThreshold() async {
        setPremium(true)
        let mockService = MockRecipeGenerationService()
        mockService.mockGeneratedRecipes = [RecipeTestFixtures.createGeneratedRecipe()]

        let recipes = createRecipes(count: 5)
        let viewModel = createViewModel(recipes: recipes, generationService: mockService)

        await viewModel.loadGeneratedRecipes()

        #expect(mockService.getGeneratedRecipesCallCount == 0)
        #expect(viewModel.generatedRecipes.isEmpty)
    }

    // MARK: - Save to Collection Tests

    @Test("saveToCollection creates recipe with ai_generated sourceType")
    func saveCreatesRecipeWithCorrectSourceType() {
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = createViewModel(modelContext: modelContext)

        let generatedRecipe = RecipeTestFixtures.createGeneratedRecipe(title: "New Recipe")
        viewModel.generatedRecipes = [generatedRecipe]

        viewModel.saveToCollection(generatedRecipe)

        let fetchDescriptor = FetchDescriptor<Recipe>()
        let savedRecipes = try? modelContext.fetch(fetchDescriptor)

        #expect(savedRecipes?.count == 1)
        #expect(savedRecipes?.first?.sourceType == .ai_generated)
        #expect(savedRecipes?.first?.title == "New Recipe")
    }

    @Test("saveToCollection removes recipe from generatedRecipes")
    func saveRemovesFromGeneratedRecipes() {
        let viewModel = createViewModel()

        let recipe1 = RecipeTestFixtures.createGeneratedRecipe(title: "Recipe 1")
        let recipe2 = RecipeTestFixtures.createGeneratedRecipe(title: "Recipe 2")
        viewModel.generatedRecipes = [recipe1, recipe2]

        viewModel.saveToCollection(recipe1)

        #expect(viewModel.generatedRecipes.count == 1)
        #expect(viewModel.generatedRecipes.first?.title == "Recipe 2")
    }

    // MARK: - Test Helpers

    private func createViewModel(
        recipes: [Recipe] = [],
        modelContext: ModelContext? = nil,
        generationService: RecipeGenerating? = nil
    ) -> DiscoverViewModel {
        let context = modelContext ?? RecipeTestFixtures.createInMemoryModelContext()
        let service = generationService ?? MockRecipeGenerationService()

        return DiscoverViewModel(
            recipes: recipes,
            modelContext: context,
            generationService: service
        )
    }

    private func setPremium(_ value: Bool) {
        UserSubscriptionService.mockIsPremium = value
    }

    private func createRecipes(count: Int) -> [Recipe] {
        (0..<count).map { i in
            RecipeTestFixtures.createRecipe(title: "Recipe \(i)")
        }
    }
}
