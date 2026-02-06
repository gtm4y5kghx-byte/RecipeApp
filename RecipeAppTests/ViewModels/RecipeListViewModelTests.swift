import Testing
import Foundation
import SwiftData
@testable import RecipeApp

@Suite("RecipeListViewModel Tests")
@MainActor
struct RecipeListViewModelTests {
    
    // MARK: - Delete Test
    
    @Test("Delete single recipe removes it from collection")
    func testDeleteSingleRecipe() throws {
        let recipes = RecipeTestFixtures.createSampleRecipes()
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)
        
        for recipe in recipes {
            modelContext.insert(recipe)
        }
        try modelContext.save()
        
        let initialCount = recipes.count
        let recipeToDelete = recipes[0]
        
        viewModel.deleteRecipe(recipeToDelete)
        
        let descriptor = FetchDescriptor<Recipe>()
        let remainingRecipes = try modelContext.fetch(descriptor)
        
        #expect(remainingRecipes.count == initialCount - 1)
        #expect(!remainingRecipes.contains { $0.id == recipeToDelete.id })
    }
    
    // MARK: - Search Tests

    private func waitForSearch() async {
        try? await Task.sleep(for: .milliseconds(350))
    }

    @Test("Search filters recipes by title substring")
    func testSearchByTitleSubstring() async throws {
        let recipes = RecipeTestFixtures.createSampleRecipes()
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)

        viewModel.performSearch(query: "pasta", scope: .title)
        await waitForSearch()

        try #require(viewModel.filteredResults.count == 1)
        #expect(viewModel.filteredResults[0].title == "Pasta Carbonara")
    }

    @Test("Search with empty query returns no results")
    func testSearchEmptyQuery() async {
        let recipes = RecipeTestFixtures.createSampleRecipes()
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)

        viewModel.performSearch(query: "", scope: .all)
        await waitForSearch()

        #expect(viewModel.filteredResults.isEmpty)
        #expect(viewModel.isSearching == false)
    }

    @Test("Search in all fields finds matches")
    func testSearchAllFields() async {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Test Recipe",
            ingredients: [("2", "cups", "pasta")],
            instructions: ["Boil water"]
        )
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: [recipe], modelContext: modelContext)

        viewModel.performSearch(query: "pasta", scope: .all)
        await waitForSearch()

        #expect(viewModel.filteredResults.count == 1)
    }

    @Test("Search is case insensitive")
    func testSearchCaseInsensitive() async throws {
        let recipes = RecipeTestFixtures.createSampleRecipes()
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)

        viewModel.performSearch(query: "PASTA", scope: .title)
        await waitForSearch()

        try #require(viewModel.filteredResults.count == 1)
        #expect(viewModel.filteredResults[0].title == "Pasta Carbonara")
    }

    @Test("Search does not match typos or fuzzy matches")
    func testSearchNoFuzzyMatching() async {
        let recipes = RecipeTestFixtures.createSampleRecipes()
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)

        // "pasto" should NOT match "Pasta" (no fuzzy matching)
        viewModel.performSearch(query: "pasto", scope: .title)
        await waitForSearch()
        #expect(viewModel.filteredResults.isEmpty)

        // "past" SHOULD match "Pasta" (substring)
        viewModel.performSearch(query: "past", scope: .title)
        await waitForSearch()
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
    func testDisplayedRecipesRecentlyCooked() throws {
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

        try #require(displayed.count == 1)
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
    func testSortedTags() throws {
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "R1", tags: ["dinner", "pasta"]),
            RecipeTestFixtures.createRecipe(title: "R2", tags: ["dinner"]),
            RecipeTestFixtures.createRecipe(title: "R3", tags: ["lunch"])
        ]
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)

        let tags = viewModel.sortedTags

        try #require(tags.count == 3)
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
    func testSearchZeroResultsWithFavoritesFilter() async {
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
        await waitForSearch()

        // Should show zero results (not all favorites)
        let displayed = viewModel.displayedRecipes
        #expect(displayed.isEmpty)
        #expect(viewModel.isSearching == true)
    }

    @Test("Clearing search shows all filtered recipes")
    func testClearSearchShowsFilteredRecipes() async {
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
        await waitForSearch()
        #expect(viewModel.isSearching == true)

        // Clear search (empty query)
        viewModel.performSearch(query: "", scope: .title)
        await waitForSearch()

        // Should show all favorites (2 recipes)
        let displayed = viewModel.displayedRecipes
        #expect(displayed.count == 2)
        #expect(viewModel.isSearching == false)
    }

    @Test("Search with results respects active filter")
    func testSearchWithResultsRespectsFilter() async throws {
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
        await waitForSearch()

        let displayed = viewModel.displayedRecipes
        try #require(displayed.count == 1)
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
    func testSuggestionsAlwaysPrioritized() throws {
        // Given: ViewModel with suggestions for first 2 recipes
        let (viewModel, recipes) = RecipeTestFixtures.createViewModelWithSuggestions(suggestionCount: 2)

        // When: Getting displayed recipes
        let displayed = viewModel.displayedRecipes

        // Then: First 2 recipes should be the suggested ones
        try #require(displayed.count == recipes.count) // Same total count
        #expect(displayed[0].id == recipes[0].id)  // First suggested recipe first
        #expect(displayed[1].id == recipes[1].id)  // Second suggested recipe second
    }
    
    @Test("Tracks suggested recipe IDs from suggestions")
    func testSuggestedRecipeIDsTracking() throws {
        let (viewModel, recipes) = RecipeTestFixtures.createViewModelWithSuggestions(suggestionCount: 2)

        let suggestedIDs = viewModel.suggestedRecipeIDs

        try #require(suggestedIDs.count == 2)
        try #require(recipes.count >= 2)
        #expect(suggestedIDs.contains(recipes[0].id))
        #expect(suggestedIDs.contains(recipes[1].id))
    }
    
    @Test("Suggestion reasons are accessible by recipe ID")
    func testSuggestionReasonsMapping() throws {
        // Given: ViewModel with loaded suggestions
        let (viewModel, recipes) = RecipeTestFixtures.createViewModelWithSuggestions(suggestionCount: 2)

        // When: Looking up reason for suggested recipe
        try #require(recipes.count >= 3)
        let firstRecipeReason = viewModel.suggestionReasons[recipes[0].id]
        let nonSuggestedReason = viewModel.suggestionReasons[recipes[2].id]

        // Then: Should return correct AI-generated reason for suggested recipes only
        #expect(firstRecipeReason == "Try this again!")
        #expect(nonSuggestedReason == nil)
    }

    // MARK: - AI Generated Suggestions Tests

    @Test("aiGeneratedSuggestions filters only AI-generated suggestions")
    func testAIGeneratedSuggestionsFilter() throws {
        let (viewModel, _, generatedRecipes) = RecipeTestFixtures.createViewModelWithMixedSuggestions(
            collectionCount: 2,
            aiGeneratedCount: 2
        )

        let aiSuggestions = viewModel.aiGeneratedSuggestions

        try #require(aiSuggestions.count == 2)
        #expect(aiSuggestions.allSatisfy { $0.isAIGenerated })
        #expect(aiSuggestions[0].generatedRecipe?.title == generatedRecipes[0].title)
        #expect(aiSuggestions[1].generatedRecipe?.title == generatedRecipes[1].title)
    }

    @Test("suggestedRecipeIDs excludes AI-generated suggestions")
    func testSuggestedRecipeIDsExcludesAIGenerated() {
        let (viewModel, recipes, _) = RecipeTestFixtures.createViewModelWithMixedSuggestions(
            collectionCount: 2,
            aiGeneratedCount: 2
        )

        let suggestedIDs = viewModel.suggestedRecipeIDs

        // Should only contain IDs from collection suggestions (first 2 recipes)
        #expect(suggestedIDs.count == 2)
        #expect(suggestedIDs.contains(recipes[0].id))
        #expect(suggestedIDs.contains(recipes[1].id))
    }

    @Test("suggestionReasons excludes AI-generated suggestions")
    func testSuggestionReasonsExcludesAIGenerated() {
        let (viewModel, recipes, _) = RecipeTestFixtures.createViewModelWithMixedSuggestions(
            collectionCount: 2,
            aiGeneratedCount: 2
        )

        let reasons = viewModel.suggestionReasons

        // Should only contain reasons for collection suggestions
        #expect(reasons.count == 2)
        #expect(reasons[recipes[0].id] == "Try this again!")
        #expect(reasons[recipes[1].id] == "Try this again!")
    }

    @Test("saveGeneratedRecipe adds AI Generated tag")
    func testSaveGeneratedRecipeAddsTag() throws {
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: [], modelContext: modelContext)

        let generatedRecipe = RecipeTestFixtures.createGeneratedRecipe(
            title: "AI Pasta",
            tags: ["quick", "dinner"]
        )

        let _ = viewModel.saveGeneratedRecipe(generatedRecipe)

        let descriptor = FetchDescriptor<Recipe>()
        let savedRecipes = try modelContext.fetch(descriptor)

        #expect(savedRecipes.count == 1)
        #expect(savedRecipes[0].title == "AI Pasta")
        #expect(savedRecipes[0].userTags.contains("AI Generated"))
        #expect(savedRecipes[0].userTags.contains("quick"))
        #expect(savedRecipes[0].userTags.contains("dinner"))
    }

    @Test("saveGeneratedRecipe removes from suggestions list")
    func testSaveGeneratedRecipeRemovesFromSuggestions() throws {
        let (viewModel, _, generatedRecipes) = RecipeTestFixtures.createViewModelWithMixedSuggestions(
            collectionCount: 2,
            aiGeneratedCount: 2
        )

        #expect(viewModel.suggestions.count == 4)

        // Save the first AI-generated recipe
        let _ = viewModel.saveGeneratedRecipe(generatedRecipes[0])

        // Should have removed that suggestion
        #expect(viewModel.suggestions.count == 3)
        #expect(viewModel.aiGeneratedSuggestions.count == 1)
        #expect(viewModel.aiGeneratedSuggestions[0].generatedRecipe?.title == generatedRecipes[1].title)
    }

    @Test("saveGeneratedRecipe sets source type to ai_generated")
    func testSaveGeneratedRecipeSourceType() throws {
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: [], modelContext: modelContext)

        let generatedRecipe = RecipeTestFixtures.createGeneratedRecipe(title: "AI Recipe")

        let _ = viewModel.saveGeneratedRecipe(generatedRecipe)

        let descriptor = FetchDescriptor<Recipe>()
        let savedRecipes = try modelContext.fetch(descriptor)

        #expect(savedRecipes[0].sourceType == .ai_generated)
    }

    @Test("saveGeneratedRecipe returns saved recipe for navigation")
    func testSaveGeneratedRecipeReturnsRecipe() throws {
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: [], modelContext: modelContext)

        let generatedRecipe = RecipeTestFixtures.createGeneratedRecipe(title: "AI Pasta")

        let savedRecipe = viewModel.saveGeneratedRecipe(generatedRecipe)

        #expect(savedRecipe != nil)
        #expect(savedRecipe?.title == "AI Pasta")
        #expect(savedRecipe?.userTags.contains("AI Generated") == true)
    }

    // MARK: - Displayed Items Tests

    @Test("displayedItems returns RecipeListItem array")
    func testDisplayedItemsReturnsRecipeListItemArray() {
        let recipes = RecipeTestFixtures.createSampleRecipes()
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)

        let items = viewModel.displayedItems

        #expect(!items.isEmpty)
        #expect(items.count >= recipes.count)
    }

    @Test("displayedItems places collection suggestions at top with reasons")
    func testDisplayedItemsCollectionSuggestionsAtTop() throws {
        let (viewModel, recipes) = RecipeTestFixtures.createViewModelWithSuggestions(suggestionCount: 2)

        let items = viewModel.displayedItems

        // First 2 items should be the suggested recipes with reasons
        try #require(items.count >= 2)
        #expect(items[0].recipe?.id == recipes[0].id)
        #expect(items[0].suggestionReason == "Try this again!")
        #expect(items[1].recipe?.id == recipes[1].id)
        #expect(items[1].suggestionReason == "Try this again!")
    }

    @Test("displayedItems regular recipes have no suggestion reason")
    func testDisplayedItemsRegularRecipesNoReason() {
        let (viewModel, recipes) = RecipeTestFixtures.createViewModelWithSuggestions(suggestionCount: 2)

        let items = viewModel.displayedItems

        // Find a non-suggested recipe item
        let regularItems = items.filter { item in
            guard let recipe = item.recipe else { return false }
            return recipe.id != recipes[0].id && recipe.id != recipes[1].id
        }

        #expect(!regularItems.isEmpty)
        #expect(regularItems.allSatisfy { $0.suggestionReason == nil })
    }

    @Test("displayedItems intersperses AI-generated recipes among regular recipes")
    func testDisplayedItemsInterspersesAIGenerated() throws {
        let (viewModel, recipes, generatedRecipes) = RecipeTestFixtures.createViewModelWithMixedSuggestions(
            collectionCount: 2,
            aiGeneratedCount: 2
        )

        let items = viewModel.displayedItems

        // Should contain both recipe and generatedRecipe items
        let recipeItems = items.filter { $0.recipe != nil }
        let generatedItems = items.filter { $0.generatedRecipe != nil }

        #expect(recipeItems.count == recipes.count)
        #expect(generatedItems.count == generatedRecipes.count)

        // AI-generated should NOT be at the very top (collection suggestions are)
        try #require(items.count >= 2)
        #expect(items[0].isGenerated == false)
        #expect(items[1].isGenerated == false)
    }

    @Test("displayedItems excludes AI-generated when searching")
    func testDisplayedItemsExcludesAIGeneratedWhenSearching() async {
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Chicken Soup"),
            RecipeTestFixtures.createRecipe(title: "Beef Stew"),
            RecipeTestFixtures.createRecipe(title: "Chicken Curry")
        ]
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)

        // Add AI-generated suggestion
        let generated = RecipeTestFixtures.createGeneratedRecipe(title: "AI Chicken Recipe")
        viewModel.suggestions = [.aiGenerated(generated, reason: "Made for you")]

        // Search for "chicken"
        viewModel.performSearch(query: "chicken", scope: .title)
        await waitForSearch()

        let items = viewModel.displayedItems

        // Should only have matching recipes, no AI-generated
        #expect(items.count == 2)
        #expect(items.allSatisfy { $0.recipe != nil })
        #expect(items.allSatisfy { $0.generatedRecipe == nil })
    }

    @Test("displayedItems shows matching collection suggestions at top when searching")
    func testDisplayedItemsShowsMatchingSuggestionsWhenSearching() async throws {
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Chicken Soup"),
            RecipeTestFixtures.createRecipe(title: "Beef Stew"),
            RecipeTestFixtures.createRecipe(title: "Chicken Curry")
        ]
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)

        // Suggest Chicken Soup
        let suggestion = RecipeSuggestion(recipeID: recipes[0].id, aiGeneratedReason: "You haven't made this lately")
        viewModel.suggestions = [.fromCollection(suggestion)]

        // Search for "chicken"
        viewModel.performSearch(query: "chicken", scope: .title)
        await waitForSearch()

        let items = viewModel.displayedItems

        // Should have 2 results, with Chicken Soup (suggested) at top
        try #require(items.count == 2)
        #expect(items[0].recipe?.title == "Chicken Soup")
        #expect(items[0].suggestionReason == "You haven't made this lately")
    }

    @Test("displayedItems excludes AI-generated when filtering by section")
    func testDisplayedItemsExcludesAIGeneratedWhenFiltering() throws {
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Favorite Recipe", isFavorite: true),
            RecipeTestFixtures.createRecipe(title: "Regular Recipe", isFavorite: false)
        ]
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)

        // Add AI-generated suggestion
        let generated = RecipeTestFixtures.createGeneratedRecipe(title: "AI Recipe")
        viewModel.suggestions = [.aiGenerated(generated, reason: "Made for you")]

        // Filter by favorites
        viewModel.selectedSection = .favorites

        let items = viewModel.displayedItems

        // Should only have the favorite recipe, no AI-generated
        try #require(items.count == 1)
        #expect(items[0].recipe?.title == "Favorite Recipe")
        #expect(items[0].generatedRecipe == nil)
    }

    @Test("displayedItems with no suggestions returns all recipes without reasons")
    func testDisplayedItemsNoSuggestions() {
        let recipes = RecipeTestFixtures.createSampleRecipes()
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)

        // No suggestions set
        viewModel.suggestions = []

        let items = viewModel.displayedItems

        #expect(items.count == recipes.count)
        #expect(items.allSatisfy { $0.recipe != nil })
        #expect(items.allSatisfy { $0.suggestionReason == nil })
    }

    @Test("displayedItems with only collection suggestions has no AI-generated items")
    func testDisplayedItemsOnlyCollectionSuggestions() {
        let (viewModel, _) = RecipeTestFixtures.createViewModelWithSuggestions(suggestionCount: 3)

        let items = viewModel.displayedItems

        #expect(items.allSatisfy { $0.generatedRecipe == nil })
    }
}
