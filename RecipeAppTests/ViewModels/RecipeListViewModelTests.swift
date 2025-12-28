import Testing
import Foundation
import SwiftData
@testable import RecipeApp

@Suite("RecipeListViewModel Tests")
@MainActor
struct RecipeListViewModelTests {
    
    // MARK: - Search Tests
    
    @Test("Search filters recipes by title substring")
    func testSearchByTitleSubstring() {
        let recipes = RecipeTestFixtures.createSampleRecipes()
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)
        
        viewModel.performSearch(query: "pasta", scope: .title)
        
        #expect(viewModel.filteredResults.count == 1)
        #expect(viewModel.filteredResults[0].title == "Pasta Carbonara")
    }
    
    @Test("Search with empty query returns no results")
    func testSearchEmptyQuery() {
        let recipes = RecipeTestFixtures.createSampleRecipes()
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)
        
        viewModel.performSearch(query: "", scope: .all)
        
        #expect(viewModel.filteredResults.isEmpty)
        #expect(viewModel.isSearching == false)
    }
    
    @Test("Search in all fields finds matches")
    func testSearchAllFields() {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Test Recipe",
            ingredients: [("2", "cups", "pasta")],
            instructions: ["Boil water"]
        )
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: [recipe], modelContext: modelContext)
        
        viewModel.performSearch(query: "pasta", scope: .all)
        
        #expect(viewModel.filteredResults.count == 1)
    }
    
    @Test("Search is case insensitive")
    func testSearchCaseInsensitive() {
        let recipes = RecipeTestFixtures.createSampleRecipes()
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)
        
        viewModel.performSearch(query: "PASTA", scope: .title)
        
        #expect(viewModel.filteredResults.count == 1)
        #expect(viewModel.filteredResults[0].title == "Pasta Carbonara")
    }
    
    @Test("Search does not match typos or fuzzy matches")
    func testSearchNoFuzzyMatching() {
        let recipes = RecipeTestFixtures.createSampleRecipes()
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)
        
        // "pasto" should NOT match "Pasta" (no fuzzy matching)
        viewModel.performSearch(query: "pasto", scope: .title)
        #expect(viewModel.filteredResults.isEmpty)
        
        // "past" SHOULD match "Pasta" (substring)
        viewModel.performSearch(query: "past", scope: .title)
        #expect(viewModel.filteredResults.count == 1)
    }
    
    // MARK: - Displayed Recipes Tests
    
    @Test("Displayed recipes returns all when section is all")
    func testDisplayedRecipesAll() {
        let recipes = RecipeTestFixtures.createSampleRecipes()
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)
        
        viewModel.selectedSection = .all
        let displayed = viewModel.displayedRecipes
        
        #expect(displayed.count == recipes.count)
    }
    
    @Test("Displayed recipes returns recently added sorted by date")
    func testDisplayedRecipesRecentlyAdded() {
        let recipes = RecipeTestFixtures.createSampleRecipes()
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)
        
        viewModel.selectedSection = .recentlyAdded
        let displayed = viewModel.displayedRecipes
        
        // Should be sorted by dateAdded descending
        #expect(displayed.count == recipes.count)
        for i in 0..<(displayed.count - 1) {
            #expect(displayed[i].dateAdded >= displayed[i + 1].dateAdded)
        }
    }
    
    @Test("Displayed recipes returns recently cooked only")
    func testDisplayedRecipesRecentlyCooked() {
        let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let thirtyFiveDaysAgo = Calendar.current.date(byAdding: .day, value: -35, to: Date())!
        
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Recent", lastMade: fiveDaysAgo),
            RecipeTestFixtures.createRecipe(title: "Old", lastMade: thirtyFiveDaysAgo),
            RecipeTestFixtures.createRecipe(title: "Never")
        ]
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)
        
        viewModel.selectedSection = .recentlyCooked
        let displayed = viewModel.displayedRecipes
        
        #expect(displayed.count == 1)
        #expect(displayed[0].title == "Recent")
    }
    
    @Test("Displayed recipes returns favorites only")
    func testDisplayedRecipesFavorites() {
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Favorite 1", isFavorite: true),
            RecipeTestFixtures.createRecipe(title: "Not Favorite", isFavorite: false),
            RecipeTestFixtures.createRecipe(title: "Favorite 2", isFavorite: true)
        ]
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)
        
        viewModel.selectedSection = .favorites
        let displayed = viewModel.displayedRecipes
        
        #expect(displayed.count == 2)
        #expect(displayed.allSatisfy { $0.isFavorite })
    }
    
    @Test("Displayed recipes returns uncategorized only")
    func testDisplayedRecipesUncategorized() {
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Tagged", tags: ["dinner"]),
            RecipeTestFixtures.createRecipe(title: "Untagged 1"),
            RecipeTestFixtures.createRecipe(title: "Untagged 2")
        ]
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)
        
        viewModel.selectedSection = .uncategorized
        let displayed = viewModel.displayedRecipes
        
        #expect(displayed.count == 2)
        #expect(displayed.allSatisfy { $0.userTags.isEmpty })
    }
    
    @Test("Displayed recipes returns recipes by tag")
    func testDisplayedRecipesByTag() {
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Recipe 1", tags: ["dinner", "pasta"]),
            RecipeTestFixtures.createRecipe(title: "Recipe 2", tags: ["lunch"]),
            RecipeTestFixtures.createRecipe(title: "Recipe 3", tags: ["dinner"])
        ]
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)
        
        viewModel.selectedSection = .tag("dinner")
        let displayed = viewModel.displayedRecipes
        
        #expect(displayed.count == 2)
        #expect(displayed.allSatisfy { $0.userTags.contains("dinner") })
    }
    
    // MARK: - Recipe Count Tests
    
    @Test("Recipe count for all section")
    func testRecipeCountAll() {
        let recipes = RecipeTestFixtures.createSampleRecipes()
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)
        
        let count = viewModel.recipeCount(for: .all)
        
        #expect(count == recipes.count)
    }
    
    @Test("Recipe count for favorites section")
    func testRecipeCountFavorites() {
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Fav 1", isFavorite: true),
            RecipeTestFixtures.createRecipe(title: "Not Fav"),
            RecipeTestFixtures.createRecipe(title: "Fav 2", isFavorite: true)
        ]
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)
        
        let count = viewModel.recipeCount(for: .favorites)
        
        #expect(count == 2)
    }
    
    // MARK: - Sorted Tags Tests
    
    @Test("Sorted tags returns tags by count descending")
    func testSortedTags() {
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "R1", tags: ["dinner", "pasta"]),
            RecipeTestFixtures.createRecipe(title: "R2", tags: ["dinner"]),
            RecipeTestFixtures.createRecipe(title: "R3", tags: ["lunch"])
        ]
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)
        
        let tags = viewModel.sortedTags
        
        #expect(tags.count == 3)
        #expect(tags[0].0 == "dinner")  // Most common (2)
        #expect(tags[0].1 == 2)
        #expect(tags[1].1 == 1)  // pasta (1)
        #expect(tags[2].1 == 1)  // lunch (1)
    }
    
    @Test("Sorted tags returns empty array when no tags")
    func testSortedTagsEmpty() {
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "R1"),
            RecipeTestFixtures.createRecipe(title: "R2")
        ]
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)
        
        let tags = viewModel.sortedTags
        
        #expect(tags.isEmpty)
    }
    
    // MARK: - Search State Tests
    
    @Test("Search with zero results shows empty array when favorites filter active")
    func testSearchZeroResultsWithFavoritesFilter() {
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Italian Pasta", isFavorite: true),
            RecipeTestFixtures.createRecipe(title: "Mexican Tacos", isFavorite: true),
            RecipeTestFixtures.createRecipe(title: "Thai Curry", isFavorite: false)
        ]
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)
        
        // Set favorites filter
        viewModel.selectedSection = .favorites
        
        // Search for something that won't match
        viewModel.performSearch(query: "zzzzz", scope: .title)
        
        // Should show zero results (not all favorites)
        let displayed = viewModel.displayedRecipes
        #expect(displayed.isEmpty)
        #expect(viewModel.isSearching == true)
    }
    
    @Test("Clearing search shows all filtered recipes")
    func testClearSearchShowsFilteredRecipes() {
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Italian Pasta", isFavorite: true),
            RecipeTestFixtures.createRecipe(title: "Mexican Tacos", isFavorite: true),
            RecipeTestFixtures.createRecipe(title: "Thai Curry", isFavorite: false)
        ]
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)
        
        // Set favorites filter
        viewModel.selectedSection = .favorites
        
        // Search for something
        viewModel.performSearch(query: "pasta", scope: .title)
        #expect(viewModel.isSearching == true)
        
        // Clear search (empty query)
        viewModel.performSearch(query: "", scope: .title)
        
        // Should show all favorites (2 recipes)
        let displayed = viewModel.displayedRecipes
        #expect(displayed.count == 2)
        #expect(viewModel.isSearching == false)
    }
    
    @Test("Search with results respects active filter")
    func testSearchWithResultsRespectsFilter() {
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Italian Pasta", isFavorite: true),
            RecipeTestFixtures.createRecipe(title: "Italian Pizza", isFavorite: false),
            RecipeTestFixtures.createRecipe(title: "Mexican Tacos", isFavorite: true)
        ]
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)
        
        // Set favorites filter
        viewModel.selectedSection = .favorites
        
        // Search for "italian" - should find 2 recipes but only 1 is favorite
        viewModel.performSearch(query: "italian", scope: .title)
        
        let displayed = viewModel.displayedRecipes
        #expect(displayed.count == 1)
        #expect(displayed[0].title == "Italian Pasta")
        #expect(viewModel.isSearching == true)
    }
    
    @Test("isSearching flag is false by default")
    func testIsSearchingDefaultFalse() {
        let recipes = RecipeTestFixtures.createSampleRecipes()
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)
        
        #expect(viewModel.isSearching == false)
    }
    
    // MARK: - Recipe Import Tests
    
    @Test("Create recipe from import with all data")
    func testCreateRecipeFromImportWithAllData() throws {
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: [], modelContext: modelContext)
        
        let nutritionData = NutritionImportData(
            calories: 500,
            carbohydrates: 60.0,
            protein: 25.0,
            fat: 15.0,
            fiber: 5.0,
            sodium: 800.0,
            sugar: 10.0
        )
        
        let importData = RecipeTestFixtures.createImportData(
            title: "Imported Pasta",
            description: "Delicious pasta dish",
            sourceURL: "https://example.com/pasta",
            prepTime: 10,
            cookTime: 20,
            servings: 4,
            cuisine: "Italian",
            ingredients: ["200g pasta", "2 tbsp olive oil"],
            instructions: ["Boil water", "Cook pasta"],
            nutrition: nutritionData
        )
        
        try SharedDataManager.shared.savePendingImport(importData)
        viewModel.handlePendingImport()
        
        let descriptor = FetchDescriptor<Recipe>()
        let recipes = try modelContext.fetch(descriptor)
        
        #expect(recipes.count == 1)
        let recipe = recipes[0]
        
        // Basic properties
        #expect(recipe.title == "Imported Pasta")
        #expect(recipe.sourceType == .web_imported)
        #expect(recipe.sourceURL == "https://example.com/pasta")
        #expect(recipe.notes == "Delicious pasta dish")
        #expect(recipe.prepTime == 10)
        #expect(recipe.cookTime == 20)
        #expect(recipe.servings == 4)
        #expect(recipe.cuisine == "Italian")
        
        // Ingredients
        let sortedIngredients = recipe.sortedIngredients
        #expect(sortedIngredients.count == 2)
        #expect(sortedIngredients[0].item == "200g pasta")
        #expect(sortedIngredients[0].order == 0)
        #expect(sortedIngredients[1].item == "2 tbsp olive oil")
        #expect(sortedIngredients[1].order == 1)
        
        // Instructions
        let sortedInstructions = recipe.sortedInstructions
        #expect(sortedInstructions.count == 2)
        #expect(sortedInstructions[0].instruction == "Boil water")
        #expect(sortedInstructions[0].order == 0)
        #expect(sortedInstructions[1].instruction == "Cook pasta")
        #expect(sortedInstructions[1].order == 1)
        
        // Nutrition
        #expect(recipe.nutrition != nil)
        #expect(recipe.nutrition?.calories == 500)
        #expect(recipe.nutrition?.carbohydrates == 60.0)
        #expect(recipe.nutrition?.protein == 25.0)
        #expect(recipe.nutrition?.fat == 15.0)
        #expect(recipe.nutrition?.fiber == 5.0)
        #expect(recipe.nutrition?.sodium == 800.0)
        #expect(recipe.nutrition?.sugar == 10.0)
    }
    
    @Test("Create recipe from import with minimal data")
    func testCreateRecipeFromImportWithMinimalData() throws {
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: [], modelContext: modelContext)
        
        let importData = RecipeTestFixtures.createImportData(
            title: "Simple Recipe",
            ingredients: ["flour"],
            instructions: ["Mix"],
            nutrition: nil
        )
        
        try SharedDataManager.shared.savePendingImport(importData)
        viewModel.handlePendingImport()
        
        let descriptor = FetchDescriptor<Recipe>()
        let recipes = try modelContext.fetch(descriptor)
        
        #expect(recipes.count == 1)
        let recipe = recipes[0]
        #expect(recipe.title == "Simple Recipe")
        #expect(recipe.sourceType == .web_imported)
        #expect(recipe.sortedIngredients.count == 1)
        #expect(recipe.sortedInstructions.count == 1)
        #expect(recipe.nutrition == nil)
        #expect(recipe.sourceURL == nil)
        #expect(recipe.servings == nil)
    }
    
    // MARK: - Suggested Recipes
    
    @Test("Suggestions are always prioritized at top of displayed recipes")
    func testSuggestionsAlwaysPrioritized() async throws {
        // Given: ViewModel with suggestions for first 2 recipes
        let (viewModel, recipes) = RecipeTestFixtures.createViewModelWithSuggestions(suggestionCount: 2)
        
        // When: Getting displayed recipes
        let displayed = viewModel.displayedRecipes
        
        // Then: First 2 recipes should be the suggested ones
        #expect(displayed.count == recipes.count) // Same total count
        #expect(displayed[0].id == recipes[0].id)  // First suggested recipe first
        #expect(displayed[1].id == recipes[1].id)  // Second suggested recipe second
    }
    
    @Test("Tracks suggested recipe IDs from suggestions")
    func testSuggestedRecipeIDsTracking() async throws {
        let (viewModel, recipes) = RecipeTestFixtures.createViewModelWithSuggestions(suggestionCount: 2)
        
        let suggestedIDs = viewModel.suggestedRecipeIDs
        
        #expect(suggestedIDs.count == 2)
        #expect(suggestedIDs.contains(recipes[0].id))
        #expect(suggestedIDs.contains(recipes[1].id))
    }
    
    @Test("Suggestion reasons are accessible by recipe ID") 
    func testSuggestionReasonsMapping() async throws {
        // Given: ViewModel with loaded suggestions
        let (viewModel, recipes) = RecipeTestFixtures.createViewModelWithSuggestions(suggestionCount: 2)
        
        // When: Looking up reason for suggested recipe
        let firstRecipeReason = viewModel.suggestionReasons[recipes[0].id]
        let nonSuggestedReason = viewModel.suggestionReasons[recipes[2].id]
        
        // Then: Should return correct AI-generated reason for suggested recipes only
        #expect(firstRecipeReason == "Try this again!")
        #expect(nonSuggestedReason == nil)
    }

    @Test("Should trigger suggestions when crossing 10 recipe threshold")
    func testShouldTriggerSuggestionsAtThreshold() async throws {
        UserDefaults.standard.removeObject(forKey: "suggestions_threshold_met")
        
        let recipes = Array(0..<10).map { i in
            RecipeTestFixtures.createRecipe(title: "Recipe \(i)")
        }
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)
        
        let shouldTrigger = viewModel.shouldTriggerSuggestionGeneration()
        
        #expect(shouldTrigger == true)
    }

    @Test("Should not trigger suggestions when already met threshold")
    func testShouldNotTriggerSuggestionsWhenAlreadyMet() async throws {
        UserDefaults.standard.set(true, forKey: "suggestions_threshold_met")
        
        let recipes = Array(0..<15).map { i in
            RecipeTestFixtures.createRecipe(title: "Recipe \(i)")
        }
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)
        
        let shouldTrigger = viewModel.shouldTriggerSuggestionGeneration()
        
        #expect(shouldTrigger == false)
        
        UserDefaults.standard.removeObject(forKey: "suggestions_threshold_met")
    }

    @Test("Should not trigger suggestions below threshold")
    func testShouldNotTriggerSuggestionsBelowThreshold() async throws {
        UserDefaults.standard.removeObject(forKey: "suggestions_threshold_met")
        
        let recipes = Array(0..<5).map { i in
            RecipeTestFixtures.createRecipe(title: "Recipe \(i)")
        }
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)
        
        let shouldTrigger = viewModel.shouldTriggerSuggestionGeneration()
        
        #expect(shouldTrigger == false)
    }
}
