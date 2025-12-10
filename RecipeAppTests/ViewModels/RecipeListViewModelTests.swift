import Testing
import Foundation
import SwiftData
@testable import RecipeApp

@Suite("RecipeListViewModel Tests")
@MainActor
struct RecipeListViewModelTests {
    
    // MARK: - Fuzzy Search Tests
    
    @Test("Perform fuzzy search filters recipes by title")
    func testPerformFuzzySearchTitle() {
        let recipes = RecipeTestFixtures.createSampleRecipes()
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)

        viewModel.performFuzzySearch(query: "pasta", scope: .title)

        #expect(viewModel.filteredResults.count == 1)
        #expect(viewModel.filteredResults[0].title == "Pasta Carbonara")
    }

    @Test("Perform fuzzy search with empty query returns all recipes")
    func testPerformFuzzySearchEmpty() {
        let recipes = RecipeTestFixtures.createSampleRecipes()
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)

        viewModel.performFuzzySearch(query: "", scope: .all)

        #expect(viewModel.filteredResults.isEmpty)
    }

    @Test("Perform fuzzy search in all fields")
    func testPerformFuzzySearchAll() {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Test Recipe",
            ingredients: [("2", "cups", "pasta")],
            instructions: ["Boil water"]
        )
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: [recipe], modelContext: modelContext)

        viewModel.performFuzzySearch(query: "pasta", scope: .all)

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
}
