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
        let viewModel = RecipeDetailViewModel(recipe: recipe)
        
        viewModel.toggleFavorite()
        
        #expect(recipe.isFavorite == true)
    }
    
    @Test("Toggle favorite from true to false")
    func testToggleFavoriteOff() {
        let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe", isFavorite: true)
        let viewModel = RecipeDetailViewModel(recipe: recipe)
        
        viewModel.toggleFavorite()
        
        #expect(recipe.isFavorite == false)
    }
    
    // MARK: - Mark as Cooked Tests
    
    @Test("Mark as cooked increments counter and sets timestamp")
    func testMarkAsCooked() {
        let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe", timesCooked: 2)
        let initialCount = recipe.timesCooked
        let viewModel = RecipeDetailViewModel(recipe: recipe)
        
        viewModel.markAsCooked()
        
        #expect(recipe.timesCooked == initialCount + 1)
        #expect(recipe.lastMade != nil)
    }
    
    @Test("Mark as cooked sets recent timestamp")
    func testMarkAsCookedTimestamp() {
        let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe")
        let viewModel = RecipeDetailViewModel(recipe: recipe)
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
        let viewModel = RecipeDetailViewModel(recipe: recipe)
        
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
        variation1.parentRecipeID = parentRecipe.id
        
        let variation2 = RecipeTestFixtures.createRecipe(title: "Gluten-Free Version")
        variation2.parentRecipeID = parentRecipe.id
        
        let unrelatedRecipe = RecipeTestFixtures.createRecipe(title: "Different Recipe")
        
        let allRecipes = [parentRecipe, variation1, variation2, unrelatedRecipe]
        let viewModel = RecipeDetailViewModel(recipe: parentRecipe)
        
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
        let viewModel = RecipeDetailViewModel(recipe: recipe)
        
        let variations = viewModel.getVariations(from: allRecipes)
        
        #expect(variations.isEmpty)
    }
}
