import Testing
import Foundation
import SwiftData
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

    // MARK: - CRUD Operations
    
    @Test("Delete recipe returns true on success")
     func testDeleteRecipeSuccess() {
         let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe")
         let modelContext = RecipeTestFixtures.createInMemoryModelContext()
         let viewModel = RecipeDetailViewModel(recipe: recipe, modelContext: modelContext)
         
         let result = viewModel.deleteRecipe()
         
         #expect(result == true)
     }

     @Test("Delete recipe removes from context")
     func testDeleteRecipeRemovesFromContext() {
         let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe")
         let modelContext = RecipeTestFixtures.createInMemoryModelContext()
         modelContext.insert(recipe)
         let viewModel = RecipeDetailViewModel(recipe: recipe, modelContext: modelContext)
         
         _ = viewModel.deleteRecipe()
         
         let fetchDescriptor = FetchDescriptor<Recipe>()
         let remainingRecipes = try? modelContext.fetch(fetchDescriptor)
         #expect(remainingRecipes?.isEmpty == true)
     }
    
    // MARK: Total Time formatting
    
    @Test("Formatted time shows minutes only when under 60")
      func testFormattedTimeMinutesOnly() {
          let recipe = RecipeTestFixtures.createRecipe(title: "Quick Recipe")
          recipe.prepTime = 25
          let modelContext = RecipeTestFixtures.createInMemoryModelContext()
          let viewModel = RecipeDetailViewModel(recipe: recipe, modelContext: modelContext)

          #expect(viewModel.formattedTotalTime == "25 min")
      }

      @Test("Formatted time shows hours only when exact hour")
      func testFormattedTimeExactHour() {
          let recipe = RecipeTestFixtures.createRecipe(title: "One Hour Recipe")
          recipe.prepTime = 60
          let modelContext = RecipeTestFixtures.createInMemoryModelContext()
          let viewModel = RecipeDetailViewModel(recipe: recipe, modelContext: modelContext)

          #expect(viewModel.formattedTotalTime == "1h")
      }

      @Test("Formatted time shows hours and minutes")
      func testFormattedTimeHoursAndMinutes() {
          let recipe = RecipeTestFixtures.createRecipe(title: "Long Recipe")
          recipe.prepTime = 90
          let modelContext = RecipeTestFixtures.createInMemoryModelContext()
          let viewModel = RecipeDetailViewModel(recipe: recipe, modelContext: modelContext)

          #expect(viewModel.formattedTotalTime == "1h 30m")
      }

      @Test("Formatted time returns nil when no time set")
      func testFormattedTimeReturnsNil() {
          let recipe = RecipeTestFixtures.createRecipe(title: "No Time Recipe")
          let modelContext = RecipeTestFixtures.createInMemoryModelContext()
          let viewModel = RecipeDetailViewModel(recipe: recipe, modelContext: modelContext)

          #expect(viewModel.formattedTotalTime == nil)
      }
}
