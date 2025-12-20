import Testing
import Foundation
@testable import RecipeApp

@Suite("RecipeDetailViewModel Tests")
@MainActor
struct RecipeDetailViewModelTests {
    
    // MARK: - Toggle Favorite Tests
    
    @Test("Toggle favorite from false to true")
    func testToggleFavoriteOn() {
        let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe", isFavorite: false)
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeDetailViewModel(recipe: recipe, modelContext: modelContext)

        viewModel.toggleFavorite()

        #expect(recipe.isFavorite == true)
    }

    @Test("Toggle favorite from true to false")
    func testToggleFavoriteOff() {
        let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe", isFavorite: true)
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeDetailViewModel(recipe: recipe, modelContext: modelContext)

        viewModel.toggleFavorite()

        #expect(recipe.isFavorite == false)
    }
    
    // MARK: - Mark as Cooked Tests
    
    @Test("Mark as cooked increments counter and sets timestamp")
    func testMarkAsCooked() {
        let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe", timesCooked: 2)
        let initialCount = recipe.timesCooked
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeDetailViewModel(recipe: recipe, modelContext: modelContext)

        viewModel.markAsCooked()

        #expect(recipe.timesCooked == initialCount + 1)
        #expect(recipe.lastMade != nil)
    }

    @Test("Mark as cooked sets recent timestamp")
    func testMarkAsCookedTimestamp() {
        let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe")
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeDetailViewModel(recipe: recipe, modelContext: modelContext)
        let beforeTime = Date()

        viewModel.markAsCooked()

        let afterTime = Date()
        #expect(recipe.lastMade != nil)
        #expect(recipe.lastMade! >= beforeTime)
        #expect(recipe.lastMade! <= afterTime)
    }

    @Test("Mark as cooked on never-cooked recipe")
    func testMarkAsCookedFirstTime() {
        let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe", timesCooked: 0)
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeDetailViewModel(recipe: recipe, modelContext: modelContext)

        #expect(recipe.lastMade == nil)

        viewModel.markAsCooked()

        #expect(recipe.timesCooked == 1)
        #expect(recipe.lastMade != nil)
    }
    
    // MARK: - Recipe Variations Tests
    
    @Test("Get recipe variations filters by parent ID")
    func testRecipeVariations() {
        let parentRecipe = RecipeTestFixtures.createRecipe(title: "Original Recipe")

        let variation1 = RecipeTestFixtures.createRecipe(title: "Vegan Version")
        variation1.basedOnRecipeID = parentRecipe.id

        let variation2 = RecipeTestFixtures.createRecipe(title: "Gluten-Free Version")
        variation2.basedOnRecipeID = parentRecipe.id

        let unrelatedRecipe = RecipeTestFixtures.createRecipe(title: "Different Recipe")

        let allRecipes = [parentRecipe, variation1, variation2, unrelatedRecipe]
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeDetailViewModel(recipe: parentRecipe, modelContext: modelContext)

        let variations = viewModel.getVariations(from: allRecipes)

        #expect(variations.count == 2)
        #expect(variations.contains { $0.id == variation1.id })
        #expect(variations.contains { $0.id == variation2.id })
        #expect(!variations.contains { $0.id == unrelatedRecipe.id })
    }

    @Test("Get recipe variations returns empty when no variations exist")
    func testRecipeVariationsEmpty() {
        let recipe = RecipeTestFixtures.createRecipe(title: "Original Recipe")
        let allRecipes = [recipe]
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeDetailViewModel(recipe: recipe, modelContext: modelContext)

        let variations = viewModel.getVariations(from: allRecipes)

        #expect(variations.isEmpty)
    }
}
