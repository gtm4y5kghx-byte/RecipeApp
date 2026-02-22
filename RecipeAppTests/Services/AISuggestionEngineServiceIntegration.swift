import Testing
import Foundation
import SwiftData
@testable import RecipeApp

@Suite("AI Suggestion Engine Service Integration - Manual Validation")
@MainActor
struct AISuggestionEngineServiceIntegration {

    private let service = AISuggestionEngineService()

    @Test("Generate suggestions with sufficient recipes")
    func validateGenerateSuggestions() async throws {
        let today = Date()
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: today)!
        let sixtyDaysAgo = Calendar.current.date(byAdding: .day, value: -60, to: today)!

        let recipes = [
            RecipeTestFixtures.createRecipe(
                title: "Pasta Carbonara",
                cuisine: "Italian",
                timesCooked: 5,
                lastMade: sixtyDaysAgo,
                isFavorite: true
            ),
            RecipeTestFixtures.createRecipe(
                title: "Chicken Tikka Masala",
                cuisine: "Indian",
                timesCooked: 0
            ),
            RecipeTestFixtures.createRecipe(
                title: "Thai Green Curry",
                cuisine: "Thai",
                timesCooked: 3,
                lastMade: thirtyDaysAgo
            ),
            RecipeTestFixtures.createRecipe(
                title: "Margherita Pizza",
                cuisine: "Italian",
                timesCooked: 0
            ),
            RecipeTestFixtures.createRecipe(
                title: "Beef Tacos",
                cuisine: "Mexican",
                timesCooked: 8,
                lastMade: today,
                isFavorite: true
            ),
            RecipeTestFixtures.createRecipe(
                title: "Caesar Salad",
                cuisine: "American",
                timesCooked: 0,
                prepTime: 10,
                cookTime: 0
            ),
            RecipeTestFixtures.createRecipe(
                title: "Pad Thai",
                cuisine: "Thai",
                timesCooked: 2,
                lastMade: sixtyDaysAgo
            ),
            RecipeTestFixtures.createRecipe(
                title: "Spaghetti Bolognese",
                cuisine: "Italian",
                timesCooked: 0
            ),
            RecipeTestFixtures.createRecipe(
                title: "Chicken Alfredo",
                cuisine: "Italian",
                timesCooked: 4,
                lastMade: thirtyDaysAgo
            ),
            RecipeTestFixtures.createRecipe(
                title: "Vegetable Stir Fry",
                cuisine: "Chinese",
                timesCooked: 0
            ),
            RecipeTestFixtures.createRecipe(
                title: "Grilled Salmon",
                cuisine: "American",
                timesCooked: 3,
                lastMade: sixtyDaysAgo,
                isFavorite: true
            ),
            RecipeTestFixtures.createRecipe(
                title: "Chicken Parmesan",
                cuisine: "Italian",
                timesCooked: 0
            ),
            RecipeTestFixtures.createRecipe(
                title: "Beef Stroganoff",
                cuisine: "Russian",
                timesCooked: 1,
                lastMade: sixtyDaysAgo
            ),
            RecipeTestFixtures.createRecipe(
                title: "Greek Salad",
                cuisine: "Greek",
                timesCooked: 0
            ),
            RecipeTestFixtures.createRecipe(
                title: "Fish and Chips",
                cuisine: "British",
                timesCooked: 2,
                lastMade: thirtyDaysAgo
            ),
            RecipeTestFixtures.createRecipe(
                title: "Pulled Pork Sandwich",
                cuisine: "American",
                timesCooked: 0
            ),
            RecipeTestFixtures.createRecipe(
                title: "Mushroom Risotto",
                cuisine: "Italian",
                timesCooked: 0
            ),
            RecipeTestFixtures.createRecipe(
                title: "Chicken Fajitas",
                cuisine: "Mexican",
                timesCooked: 5,
                lastMade: thirtyDaysAgo
            ),
            RecipeTestFixtures.createRecipe(
                title: "Tom Yum Soup",
                cuisine: "Thai",
                timesCooked: 0
            ),
            RecipeTestFixtures.createRecipe(
                title: "BBQ Ribs",
                cuisine: "American",
                timesCooked: 1,
                lastMade: sixtyDaysAgo
            )
        ]

        let suggestions = try await service.generateSuggestions(recipes: recipes)

        print("\n========== GENERATE SUGGESTIONS ==========")
        print("Total recipes: \(recipes.count)")
        print("Suggestions generated: \(suggestions.count)")
        print("\nSuggestions:")
        for (index, suggestion) in suggestions.enumerated() {
            let recipe = recipes.first { $0.id == suggestion.recipeID }
            print("\n\(index + 1). \(recipe?.title ?? "Unknown Recipe")")
            print("   Reason: \(suggestion.aiGeneratedReason)")
        }
        print("==========================================\n")
    }

    @Test("Generate suggestions avoids recently suggested recipes when history is seeded")
    func validateSuggestionsAvoidHistory() async throws {
        let today = Date()
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: today)!
        let sixtyDaysAgo = Calendar.current.date(byAdding: .day, value: -60, to: today)!

        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Pasta Carbonara", cuisine: "Italian", timesCooked: 5, lastMade: sixtyDaysAgo, isFavorite: true),
            RecipeTestFixtures.createRecipe(title: "Chicken Tikka Masala", cuisine: "Indian", timesCooked: 0),
            RecipeTestFixtures.createRecipe(title: "Thai Green Curry", cuisine: "Thai", timesCooked: 3, lastMade: thirtyDaysAgo),
            RecipeTestFixtures.createRecipe(title: "Margherita Pizza", cuisine: "Italian", timesCooked: 0),
            RecipeTestFixtures.createRecipe(title: "Beef Tacos", cuisine: "Mexican", timesCooked: 8, lastMade: today, isFavorite: true),
            RecipeTestFixtures.createRecipe(title: "Caesar Salad", cuisine: "American", timesCooked: 0, prepTime: 10, cookTime: 0),
            RecipeTestFixtures.createRecipe(title: "Pad Thai", cuisine: "Thai", timesCooked: 2, lastMade: sixtyDaysAgo),
            RecipeTestFixtures.createRecipe(title: "Spaghetti Bolognese", cuisine: "Italian", timesCooked: 0),
            RecipeTestFixtures.createRecipe(title: "Chicken Alfredo", cuisine: "Italian", timesCooked: 4, lastMade: thirtyDaysAgo),
            RecipeTestFixtures.createRecipe(title: "Vegetable Stir Fry", cuisine: "Chinese", timesCooked: 0),
            RecipeTestFixtures.createRecipe(title: "Grilled Salmon", cuisine: "American", timesCooked: 3, lastMade: sixtyDaysAgo, isFavorite: true),
            RecipeTestFixtures.createRecipe(title: "Chicken Parmesan", cuisine: "Italian", timesCooked: 0),
            RecipeTestFixtures.createRecipe(title: "Beef Stroganoff", cuisine: "Russian", timesCooked: 1, lastMade: sixtyDaysAgo),
            RecipeTestFixtures.createRecipe(title: "Greek Salad", cuisine: "Greek", timesCooked: 0),
            RecipeTestFixtures.createRecipe(title: "Fish and Chips", cuisine: "British", timesCooked: 2, lastMade: thirtyDaysAgo),
            RecipeTestFixtures.createRecipe(title: "Pulled Pork Sandwich", cuisine: "American", timesCooked: 0),
            RecipeTestFixtures.createRecipe(title: "Mushroom Risotto", cuisine: "Italian", timesCooked: 0),
            RecipeTestFixtures.createRecipe(title: "Chicken Fajitas", cuisine: "Mexican", timesCooked: 5, lastMade: thirtyDaysAgo),
            RecipeTestFixtures.createRecipe(title: "Tom Yum Soup", cuisine: "Thai", timesCooked: 0),
            RecipeTestFixtures.createRecipe(title: "BBQ Ribs", cuisine: "American", timesCooked: 1, lastMade: sixtyDaysAgo)
        ]

        // Seed history with half the recipes
        let seededRecipes = Array(recipes.prefix(10))
        let seededIDs = seededRecipes.map { $0.id.uuidString }
        AIRecommendationHistoryStore.append(seededIDs, for: .suggestions)

        let suggestions = try await service.generateSuggestions(recipes: recipes)

        let seededIDSet = Set(seededIDs)

        print("\n========== SUGGESTION HISTORY AVOIDANCE TEST ==========")
        print("Seeded history with \(seededIDs.count) recipes:")
        for recipe in seededRecipes {
            print("  - \(recipe.title)")
        }
        print("\nSuggestions generated (\(suggestions.count)):")
        for suggestion in suggestions {
            let recipe = recipes.first { $0.id == suggestion.recipeID }
            let wasSeeded = seededIDSet.contains(suggestion.recipeID.uuidString)
            print("  \(recipe?.title ?? "Unknown"): \(suggestion.aiGeneratedReason)\(wasSeeded ? " ⚠️ REPEATED" : " ✓")")
        }
        let overlapping = suggestions.filter { seededIDSet.contains($0.recipeID.uuidString) }
        print("\nOverlap: \(overlapping.count) of \(suggestions.count) were in history")
        print("==========================================\n")

        // Clean up
        AIRecommendationHistoryStore.clear(.suggestions)

        #expect(suggestions.count >= 3)
        #expect(suggestions.count <= 5)
    }

    @Test("Get suggestions returns empty when below minimum recipe count")
    func validateMinimumRecipeCount() async throws {
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Recipe 1"),
            RecipeTestFixtures.createRecipe(title: "Recipe 2"),
            RecipeTestFixtures.createRecipe(title: "Recipe 3")
        ]

        let suggestions = try await service.getSuggestions(recipes: recipes, forceRefresh: false)

        print("\n========== MINIMUM RECIPE COUNT ==========")
        print("Total recipes: \(recipes.count)")
        print("Suggestions returned: \(suggestions.count)")
        print("Expected: 0 (below minimum threshold of 20)")
        print("==========================================\n")

        #expect(suggestions.isEmpty)
    }

    @Test("Get suggestions with cache behavior")
    func validateCacheBehavior() async throws {
        let recipes = createTwentyRecipes()

        print("\n========== CACHE BEHAVIOR TEST ==========")

        let firstCall = try await service.getSuggestions(recipes: recipes, forceRefresh: false)
        print("First call (no cache): \(firstCall.count) suggestions")

        let secondCall = try await service.getSuggestions(recipes: recipes, forceRefresh: false)
        print("Second call (cached): \(secondCall.count) suggestions")

        let thirdCall = try await service.getSuggestions(recipes: recipes, forceRefresh: true)
        print("Third call (force refresh): \(thirdCall.count) suggestions")

        print("==========================================\n")

        #expect(firstCall.count >= 3)
        #expect(firstCall.count <= 5)
        #expect(secondCall.count == firstCall.count)
        #expect(thirdCall.count >= 3)
        #expect(thirdCall.count <= 5)
    }

    private func createTwentyRecipes() -> [Recipe] {
        let today = Date()
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: today)!

        return (1...20).map { index in
            RecipeTestFixtures.createRecipe(
                title: "Recipe \(index)",
                cuisine: ["Italian", "Mexican", "Thai", "American"][index % 4],
                timesCooked: index % 3,
                lastMade: index % 2 == 0 ? thirtyDaysAgo : nil,
                isFavorite: index % 5 == 0
            )
        }
    }
}
