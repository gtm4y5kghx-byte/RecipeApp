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
}
