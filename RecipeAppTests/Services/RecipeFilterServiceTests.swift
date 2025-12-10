import Testing
import Foundation
@testable import RecipeApp

@Suite("RecipeFilterService Tests")
@MainActor
struct RecipeFilterServiceTests {

    // MARK: - Cuisine Filter Tests

    @Test("Filter by cuisine matches case-insensitively")
    func testFilterByCuisine() {
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Pasta", cuisine: "Italian"),
            RecipeTestFixtures.createRecipe(title: "Curry", cuisine: "Indian"),
            RecipeTestFixtures.createRecipe(title: "Taco", cuisine: "Mexican")
        ]

        let criteria = RecipeSearchCriteria(
            cuisine: "italian",
            maxTotalTime: nil,
            favoritesOnly: false,
            onlyNeverCooked: false,
            onlyCookedLongAgo: false,
            onlyCookedRecently: false,
            titleKeywords: [],
            ingredientKeywords: [],
            notesKeywords: [],
            combineMode: "and"
        )

        let filtered = RecipeFilterService.filterRecipes(recipes, using: criteria)

        #expect(filtered.count == 1)
        #expect(filtered[0].title == "Pasta")
    }

    @Test("Filter by cuisine with partial match")
    func testFilterByCuisinePartialMatch() {
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Pasta", cuisine: "Italian"),
            RecipeTestFixtures.createRecipe(title: "Curry", cuisine: "Indian")
        ]

        let criteria = RecipeSearchCriteria(
            cuisine: "ital",
            maxTotalTime: nil,
            favoritesOnly: false,
            onlyNeverCooked: false,
            onlyCookedLongAgo: false,
            onlyCookedRecently: false,
            titleKeywords: [],
            ingredientKeywords: [],
            notesKeywords: [],
            combineMode: "and"
        )

        let filtered = RecipeFilterService.filterRecipes(recipes, using: criteria)

        #expect(filtered.count == 1)
        #expect(filtered[0].title == "Pasta")
    }

    @Test("Filter by cuisine returns all when no cuisine specified")
    func testFilterByCuisineNoCriteria() {
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Pasta", cuisine: "Italian"),
            RecipeTestFixtures.createRecipe(title: "Curry", cuisine: "Indian")
        ]

        let criteria = RecipeSearchCriteria(
            cuisine: nil,
            maxTotalTime: nil,
            favoritesOnly: false,
            onlyNeverCooked: false,
            onlyCookedLongAgo: false,
            onlyCookedRecently: false,
            titleKeywords: [],
            ingredientKeywords: [],
            notesKeywords: [],
            combineMode: "and"
        )

        let filtered = RecipeFilterService.filterRecipes(recipes, using: criteria)

        #expect(filtered.count == 2)
    }

    // MARK: - Time Filter Tests

    @Test("Filter by max time excludes recipes over threshold")
    func testFilterByMaxTime() {
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Quick Pasta", prepTime: 10, cookTime: 20), // 30 min
            RecipeTestFixtures.createRecipe(title: "Slow Roast", prepTime: 15, cookTime: 90), // 105 min
            RecipeTestFixtures.createRecipe(title: "Medium Dish", prepTime: 20, cookTime: 25) // 45 min
        ]

        let criteria = RecipeSearchCriteria(
            cuisine: nil,
            maxTotalTime: 60,
            favoritesOnly: false,
            onlyNeverCooked: false,
            onlyCookedLongAgo: false,
            onlyCookedRecently: false,
            titleKeywords: [],
            ingredientKeywords: [],
            notesKeywords: [],
            combineMode: "and"
        )

        let filtered = RecipeFilterService.filterRecipes(recipes, using: criteria)

        #expect(filtered.count == 2)
        #expect(filtered.contains(where: { $0.title == "Quick Pasta" }))
        #expect(filtered.contains(where: { $0.title == "Medium Dish" }))
        #expect(!filtered.contains(where: { $0.title == "Slow Roast" }))
    }

    @Test("Filter by max time includes recipes without time data")
    func testFilterByMaxTimeIncludesNoTimeData() {
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "With Time", prepTime: 10, cookTime: 90), // 100 min
            RecipeTestFixtures.createRecipe(title: "No Time") // No time data
        ]

        let criteria = RecipeSearchCriteria(
            cuisine: nil,
            maxTotalTime: 60,
            favoritesOnly: false,
            onlyNeverCooked: false,
            onlyCookedLongAgo: false,
            onlyCookedRecently: false,
            titleKeywords: [],
            ingredientKeywords: [],
            notesKeywords: [],
            combineMode: "and"
        )

        let filtered = RecipeFilterService.filterRecipes(recipes, using: criteria)

        #expect(filtered.count == 1)
        #expect(filtered[0].title == "No Time")
    }

    @Test("Filter by max time returns all when no time specified")
    func testFilterByMaxTimeNoCriteria() {
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Quick", prepTime: 10, cookTime: 20),
            RecipeTestFixtures.createRecipe(title: "Slow", prepTime: 15, cookTime: 90)
        ]

        let criteria = RecipeSearchCriteria(
            cuisine: nil,
            maxTotalTime: nil,
            favoritesOnly: false,
            onlyNeverCooked: false,
            onlyCookedLongAgo: false,
            onlyCookedRecently: false,
            titleKeywords: [],
            ingredientKeywords: [],
            notesKeywords: [],
            combineMode: "and"
        )

        let filtered = RecipeFilterService.filterRecipes(recipes, using: criteria)

        #expect(filtered.count == 2)
    }

    // MARK: - Favorites Filter Tests

    @Test("Filter by favorites only returns favorites")
    func testFilterByFavoritesOnly() {
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Favorite", isFavorite: true),
            RecipeTestFixtures.createRecipe(title: "Not Favorite", isFavorite: false)
        ]

        let criteria = RecipeSearchCriteria(
            cuisine: nil,
            maxTotalTime: nil,
            favoritesOnly: true,
            onlyNeverCooked: false,
            onlyCookedLongAgo: false,
            onlyCookedRecently: false,
            titleKeywords: [],
            ingredientKeywords: [],
            notesKeywords: [],
            combineMode: "and"
        )

        let filtered = RecipeFilterService.filterRecipes(recipes, using: criteria)

        #expect(filtered.count == 1)
        #expect(filtered[0].title == "Favorite")
    }

    @Test("Filter by favorites returns all when not enabled")
    func testFilterByFavoritesDisabled() {
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Favorite", isFavorite: true),
            RecipeTestFixtures.createRecipe(title: "Not Favorite", isFavorite: false)
        ]

        let criteria = RecipeSearchCriteria(
            cuisine: nil,
            maxTotalTime: nil,
            favoritesOnly: false,
            onlyNeverCooked: false,
            onlyCookedLongAgo: false,
            onlyCookedRecently: false,
            titleKeywords: [],
            ingredientKeywords: [],
            notesKeywords: [],
            combineMode: "and"
        )

        let filtered = RecipeFilterService.filterRecipes(recipes, using: criteria)

        #expect(filtered.count == 2)
    }

    // MARK: - Cooking History Filter Tests

    @Test("Filter by never cooked returns recipes with zero times cooked")
    func testFilterByNeverCooked() {
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Never Cooked", timesCooked: 0),
            RecipeTestFixtures.createRecipe(title: "Cooked Once", timesCooked: 1),
            RecipeTestFixtures.createRecipe(title: "Cooked Many", timesCooked: 5)
        ]

        let criteria = RecipeSearchCriteria(
            cuisine: nil,
            maxTotalTime: nil,
            favoritesOnly: false,
            onlyNeverCooked: true,
            onlyCookedLongAgo: false,
            onlyCookedRecently: false,
            titleKeywords: [],
            ingredientKeywords: [],
            notesKeywords: [],
            combineMode: "and"
        )

        let filtered = RecipeFilterService.filterRecipes(recipes, using: criteria)

        #expect(filtered.count == 1)
        #expect(filtered[0].title == "Never Cooked")
    }

    @Test("Filter by cooked long ago returns recipes cooked over 30 days ago")
    func testFilterByCookedLongAgo() {
        let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let thirtyFiveDaysAgo = Calendar.current.date(byAdding: .day, value: -35, to: Date())!

        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Recent", timesCooked: 1, lastMade: fiveDaysAgo),
            RecipeTestFixtures.createRecipe(title: "Long Ago", timesCooked: 1, lastMade: thirtyFiveDaysAgo),
            RecipeTestFixtures.createRecipe(title: "Never", timesCooked: 0)
        ]

        let criteria = RecipeSearchCriteria(
            cuisine: nil,
            maxTotalTime: nil,
            favoritesOnly: false,
            onlyNeverCooked: false,
            onlyCookedLongAgo: true,
            onlyCookedRecently: false,
            titleKeywords: [],
            ingredientKeywords: [],
            notesKeywords: [],
            combineMode: "and"
        )

        let filtered = RecipeFilterService.filterRecipes(recipes, using: criteria)

        #expect(filtered.count == 1)
        #expect(filtered[0].title == "Long Ago")
    }

    @Test("Filter by cooked recently returns recipes cooked within 30 days")
    func testFilterByCookedRecently() {
        let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let thirtyFiveDaysAgo = Calendar.current.date(byAdding: .day, value: -35, to: Date())!

        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Recent", timesCooked: 1, lastMade: fiveDaysAgo),
            RecipeTestFixtures.createRecipe(title: "Long Ago", timesCooked: 1, lastMade: thirtyFiveDaysAgo),
            RecipeTestFixtures.createRecipe(title: "Never", timesCooked: 0)
        ]

        let criteria = RecipeSearchCriteria(
            cuisine: nil,
            maxTotalTime: nil,
            favoritesOnly: false,
            onlyNeverCooked: false,
            onlyCookedLongAgo: false,
            onlyCookedRecently: true,
            titleKeywords: [],
            ingredientKeywords: [],
            notesKeywords: [],
            combineMode: "and"
        )

        let filtered = RecipeFilterService.filterRecipes(recipes, using: criteria)

        #expect(filtered.count == 1)
        #expect(filtered[0].title == "Recent")
    }

    // MARK: - Multiple Criteria Tests

    @Test("Filter with multiple criteria combines filters with AND logic")
    func testFilterMultipleCriteria() {
        let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: Date())!

        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Perfect Match", cuisine: "Italian", timesCooked: 1, lastMade: fiveDaysAgo, isFavorite: true, prepTime: 10, cookTime: 20),
            RecipeTestFixtures.createRecipe(title: "Wrong Cuisine", cuisine: "Mexican", timesCooked: 1, lastMade: fiveDaysAgo, isFavorite: true, prepTime: 10, cookTime: 20),
            RecipeTestFixtures.createRecipe(title: "Too Slow", cuisine: "Italian", timesCooked: 1, lastMade: fiveDaysAgo, isFavorite: true, prepTime: 30, cookTime: 90),
            RecipeTestFixtures.createRecipe(title: "Not Favorite", cuisine: "Italian", timesCooked: 1, lastMade: fiveDaysAgo, isFavorite: false, prepTime: 10, cookTime: 20)
        ]

        let criteria = RecipeSearchCriteria(
            cuisine: "Italian",
            maxTotalTime: 60,
            favoritesOnly: true,
            onlyNeverCooked: false,
            onlyCookedLongAgo: false,
            onlyCookedRecently: true,
            titleKeywords: [],
            ingredientKeywords: [],
            notesKeywords: [],
            combineMode: "and"
        )

        let filtered = RecipeFilterService.filterRecipes(recipes, using: criteria)

        #expect(filtered.count == 1)
        #expect(filtered[0].title == "Perfect Match")
    }

    @Test("Filter with no criteria returns all recipes")
    func testFilterNoCriteria() {
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Recipe 1"),
            RecipeTestFixtures.createRecipe(title: "Recipe 2"),
            RecipeTestFixtures.createRecipe(title: "Recipe 3")
        ]

        let criteria = RecipeSearchCriteria(
            cuisine: nil,
            maxTotalTime: nil,
            favoritesOnly: false,
            onlyNeverCooked: false,
            onlyCookedLongAgo: false,
            onlyCookedRecently: false,
            titleKeywords: [],
            ingredientKeywords: [],
            notesKeywords: [],
            combineMode: "and"
        )

        let filtered = RecipeFilterService.filterRecipes(recipes, using: criteria)

        #expect(filtered.count == 3)
    }

    @Test("Filter returns empty array when no recipes match")
    func testFilterNoMatches() {
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Pasta", cuisine: "Italian"),
            RecipeTestFixtures.createRecipe(title: "Curry", cuisine: "Indian")
        ]

        let criteria = RecipeSearchCriteria(
            cuisine: "Mexican",
            maxTotalTime: nil,
            favoritesOnly: false,
            onlyNeverCooked: false,
            onlyCookedLongAgo: false,
            onlyCookedRecently: false,
            titleKeywords: [],
            ingredientKeywords: [],
            notesKeywords: [],
            combineMode: "and"
        )

        let filtered = RecipeFilterService.filterRecipes(recipes, using: criteria)

        #expect(filtered.isEmpty)
    }
}
