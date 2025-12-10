import Testing
import Foundation
import SwiftData
@testable import RecipeApp

@Suite("AI Search Service Integration - Manual Validation")
@MainActor
struct AISearchServiceIntegration {

    private let service = AISearchService()

    @Test("Parse search intent - quick Italian recipes")
    func validateQuickItalianRecipes() async throws {
        let criteria = try await service.parseSearchIntent(from: "quick Italian recipes")

        print("\n========== QUICK ITALIAN RECIPES ==========")
        print("Query: \"quick Italian recipes\"")
        print("\nParsed Criteria:")
        print("  - cuisine: \(criteria.cuisine ?? "nil")")
        print("  - maxTotalTime: \(criteria.maxTotalTime?.description ?? "nil")")
        print("  - favoritesOnly: \(criteria.favoritesOnly)")
        print("  - onlyNeverCooked: \(criteria.onlyNeverCooked)")
        print("  - titleKeywords: \(criteria.titleKeywords)")
        print("  - ingredientKeywords: \(criteria.ingredientKeywords)")
        print("  - combineMode: \(criteria.combineMode)")
        print("==========================================\n")
    }

    @Test("Parse search intent - recipes I haven't tried")
    func validateNeverCookedRecipes() async throws {
        let criteria = try await service.parseSearchIntent(from: "recipes I haven't tried")

        print("\n========== RECIPES I HAVEN'T TRIED ==========")
        print("Query: \"recipes I haven't tried\"")
        print("\nParsed Criteria:")
        print("  - onlyNeverCooked: \(criteria.onlyNeverCooked)")
        print("  - favoritesOnly: \(criteria.favoritesOnly)")
        print("  - cuisine: \(criteria.cuisine ?? "nil")")
        print("  - titleKeywords: \(criteria.titleKeywords)")
        print("==========================================\n")
    }

    @Test("Parse search intent - favorites I haven't made in awhile")
    func validateFavoritesCookedLongAgo() async throws {
        let criteria = try await service.parseSearchIntent(from: "favorites I haven't made in awhile")

        print("\n========== FAVORITES HAVEN'T MADE IN AWHILE ==========")
        print("Query: \"favorites I haven't made in awhile\"")
        print("\nParsed Criteria:")
        print("  - favoritesOnly: \(criteria.favoritesOnly)")
        print("  - onlyCookedLongAgo: \(criteria.onlyCookedLongAgo)")
        print("  - onlyNeverCooked: \(criteria.onlyNeverCooked)")
        print("  - cuisine: \(criteria.cuisine ?? "nil")")
        print("==========================================\n")
    }

    @Test("Parse search intent - chicken pasta recipes")
    func validateIngredientKeywords() async throws {
        let criteria = try await service.parseSearchIntent(from: "chicken pasta recipes")

        print("\n========== CHICKEN PASTA RECIPES ==========")
        print("Query: \"chicken pasta recipes\"")
        print("\nParsed Criteria:")
        print("  - ingredientKeywords: \(criteria.ingredientKeywords)")
        print("  - titleKeywords: \(criteria.titleKeywords)")
        print("  - cuisine: \(criteria.cuisine ?? "nil")")
        print("  - combineMode: \(criteria.combineMode)")
        print("==========================================\n")
    }

    @Test("Full search - Italian recipes")
    func validateFullSearch() async throws {
        let recipes = [
            RecipeTestFixtures.createRecipe(
                title: "Pasta Carbonara",
                cuisine: "Italian",
                timesCooked: 3,
                cookTime: 20,
                ingredients: [("", nil, "pasta"), ("", nil, "eggs"), ("", nil, "bacon")]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Chicken Tikka Masala",
                cuisine: "Indian",
                timesCooked: 0,
                cookTime: 45,
                ingredients: [("", nil, "chicken"), ("", nil, "yogurt")]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Margherita Pizza",
                cuisine: "Italian",
                timesCooked: 5,
                cookTime: 15,
                ingredients: [("", nil, "dough"), ("", nil, "tomato"), ("", nil, "mozzarella")]
            )
        ]

        let results = try await service.search(query: "Italian recipes", recipes: recipes)

        print("\n========== FULL SEARCH: ITALIAN RECIPES ==========")
        print("Query: \"Italian recipes\"")
        print("Total recipes: \(recipes.count)")
        print("\nResults (\(results.count) found):")
        for (index, recipe) in results.enumerated() {
            print("  \(index + 1). \(recipe.title) - \(recipe.cuisine ?? "no cuisine")")
        }
        print("==========================================\n")
    }

    @Test("Screen user input - blocks off-topic query")
    func validateScreeningBlocks() async throws {
        do {
            _ = try await service.parseSearchIntent(from: "What is the meaning of life?")
            print("\n❌ ERROR: Should have thrown SearchError")
        } catch let error as SearchError {
            print("\n========== SCREENING BLOCKS OFF-TOPIC ==========")
            print("Query: \"What is the meaning of life?\"")
            print("Result: Correctly blocked")
            print("Error: \(error.localizedDescription)")
            print("==========================================\n")
        }
    }

    @Test("Full search - quick recipes with cookTime only")
    func validateQuickRecipesWithCookTimeOnly() async throws {
        let recipes = [
            RecipeTestFixtures.createRecipe(
                title: "Quick Pasta",
                cuisine: "Italian",
                prepTime: nil,
                cookTime: 25,
                ingredients: [("", nil, "pasta")]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Slow Roast",
                cuisine: "American",
                prepTime: nil,
                cookTime: 120,
                ingredients: [("", nil, "beef")]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Combined Time Recipe",
                cuisine: "French",
                prepTime: 10,
                cookTime: 15,
                ingredients: [("", nil, "chicken")]
            )
        ]

        let results = try await service.search(query: "quick recipes", recipes: recipes)

        print("\n========== QUICK RECIPES (cookTime only) ==========")
        print("Query: \"quick recipes\"")
        print("Total recipes: \(recipes.count)")
        print("\nRecipe times:")
        print("  1. Quick Pasta: prepTime=nil, cookTime=25, totalTime=\(recipes[0].totalTime?.description ?? "nil")")
        print("  2. Slow Roast: prepTime=nil, cookTime=120, totalTime=\(recipes[1].totalTime?.description ?? "nil")")
        print("  3. Combined: prepTime=10, cookTime=15, totalTime=\(recipes[2].totalTime?.description ?? "nil")")
        print("\nResults (\(results.count) found):")
        for (index, recipe) in results.enumerated() {
            print("  \(index + 1). \(recipe.title) - totalTime: \(recipe.totalTime?.description ?? "nil")")
        }
        print("==========================================\n")

        #expect(results.count == 2, "Should find 2 quick recipes (≤30 min)")
        #expect(results.contains(where: { $0.title == "Quick Pasta" }), "Should include Quick Pasta")
        #expect(results.contains(where: { $0.title == "Combined Time Recipe" }), "Should include Combined Time Recipe")
        #expect(!results.contains(where: { $0.title == "Slow Roast" }), "Should NOT include Slow Roast")
    }
}
