import Testing
import Foundation
import SwiftData
@testable import RecipeApp

@Suite("Meal Plan AI Service Integration - Manual Validation")
@MainActor
struct MealPlanAIServiceIntegration {

    private let service = MealPlanAIService()

    // MARK: - Generate Plan Tests

    @Test("Generate plan with diverse recipe collection")
    func validateGeneratePlan() async throws {
        let recipes = createDiverseRecipeCollection()

        let results = try await service.generatePlan(for: .dinner, recipes: recipes)

        print("\n========== GENERATE PLAN ==========")
        print("Meal type: Dinner")
        print("Total recipes: \(recipes.count)")
        print("Assignments generated: \(results.count)")
        print("\nPlan:")
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE (MMM d)"
        for result in results {
            print("  \(formatter.string(from: result.date)): \(result.recipe.title)")
        }
        print("==========================================\n")

        #expect(results.count >= 5)
        #expect(results.count <= 7)
    }

    @Test("Generate plan for breakfast")
    func validateGeneratePlanBreakfast() async throws {
        let recipes = createDiverseRecipeCollection()

        let results = try await service.generatePlan(for: .breakfast, recipes: recipes)

        print("\n========== GENERATE BREAKFAST PLAN ==========")
        print("Assignments generated: \(results.count)")
        print("\nPlan:")
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE (MMM d)"
        for result in results {
            print("  \(formatter.string(from: result.date)): \(result.recipe.title)")
        }
        print("==========================================\n")

        #expect(results.count >= 3)
    }

    @Test("Generate plan with custom day count")
    func validateGeneratePlanCustomDays() async throws {
        let recipes = createDiverseRecipeCollection()

        let results = try await service.generatePlan(for: .dinner, recipes: recipes, dayCount: 3)

        print("\n========== GENERATE 3-DAY PLAN ==========")
        print("Requested days: 3")
        print("Assignments generated: \(results.count)")
        print("\nPlan:")
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE (MMM d)"
        for result in results {
            print("  \(formatter.string(from: result.date)): \(result.recipe.title)")
        }
        print("==========================================\n")

        #expect(results.count >= 2 && results.count <= 3)
    }

    @Test("Generate plan throws error for empty collection")
    func validateEmptyCollectionError() async throws {
        do {
            _ = try await service.generatePlan(for: .dinner, recipes: [])
            Issue.record("Expected error to be thrown")
        } catch let error as AIError {
            #expect(error.title == "No Recipes")
            print("\n========== EMPTY COLLECTION ERROR ==========")
            print("Error: \(error.title)")
            print("Message: \(error.message)")
            print("==========================================\n")
        }
    }

    @Test("Generate plan throws error for insufficient recipes")
    func validateInsufficientRecipesError() async throws {
        let recipes = [
            RecipeTestFixtures.createRecipe(title: "Recipe 1"),
            RecipeTestFixtures.createRecipe(title: "Recipe 2")
        ]

        do {
            _ = try await service.generatePlan(for: .dinner, recipes: recipes)
            Issue.record("Expected error to be thrown")
        } catch let error as AIError {
            #expect(error.title == "Not Enough Recipes")
            print("\n========== INSUFFICIENT RECIPES ERROR ==========")
            print("Error: \(error.title)")
            print("Message: \(error.message)")
            print("==========================================\n")
        }
    }

    // MARK: - Test Fixtures

    private func createDiverseRecipeCollection() -> [Recipe] {
        let today = Date()
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: today)!
        let sixtyDaysAgo = Calendar.current.date(byAdding: .day, value: -60, to: today)!

        return [
            // Breakfast recipes
            RecipeTestFixtures.createRecipe(
                title: "Fluffy Pancakes",
                cuisine: "American",
                timesCooked: 4,
                lastMade: thirtyDaysAgo,
                isFavorite: true,
                tags: ["breakfast", "sweet"]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Avocado Toast",
                cuisine: "American",
                timesCooked: 2,
                lastMade: sixtyDaysAgo,
                tags: ["breakfast", "quick", "healthy"]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Veggie Omelette",
                cuisine: "French",
                timesCooked: 0,
                tags: ["breakfast", "eggs", "vegetarian"]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Breakfast Burrito",
                cuisine: "Mexican",
                timesCooked: 3,
                lastMade: thirtyDaysAgo,
                tags: ["breakfast", "filling"]
            ),
            RecipeTestFixtures.createRecipe(
                title: "French Toast",
                cuisine: "French",
                timesCooked: 0,
                tags: ["breakfast", "sweet", "weekend"]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Shakshuka",
                cuisine: "Middle Eastern",
                timesCooked: 1,
                lastMade: sixtyDaysAgo,
                tags: ["breakfast", "eggs", "savory"]
            ),
            // Lunch/Dinner recipes
            RecipeTestFixtures.createRecipe(
                title: "Pasta Carbonara",
                cuisine: "Italian",
                timesCooked: 5,
                lastMade: sixtyDaysAgo,
                isFavorite: true,
                tags: ["dinner", "pasta", "comfort food"]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Chicken Tikka Masala",
                cuisine: "Indian",
                timesCooked: 0,
                tags: ["dinner", "spicy", "curry"]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Thai Green Curry",
                cuisine: "Thai",
                timesCooked: 3,
                lastMade: thirtyDaysAgo,
                tags: ["dinner", "spicy", "curry"]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Margherita Pizza",
                cuisine: "Italian",
                timesCooked: 0,
                tags: ["dinner", "vegetarian", "weekend"]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Spaghetti Bolognese",
                cuisine: "Italian",
                timesCooked: 0,
                tags: ["dinner", "pasta", "weeknight"]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Chicken Alfredo",
                cuisine: "Italian",
                timesCooked: 4,
                lastMade: thirtyDaysAgo,
                tags: ["dinner", "pasta", "creamy"]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Beef Tacos",
                cuisine: "Mexican",
                timesCooked: 8,
                lastMade: today,
                isFavorite: true,
                tags: ["dinner", "quick", "weeknight"]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Pad Thai",
                cuisine: "Thai",
                timesCooked: 2,
                lastMade: sixtyDaysAgo,
                tags: ["dinner", "noodles", "quick"]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Grilled Salmon",
                cuisine: "American",
                timesCooked: 3,
                lastMade: sixtyDaysAgo,
                isFavorite: true,
                tags: ["dinner", "healthy", "seafood"]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Beef Stroganoff",
                cuisine: "Russian",
                timesCooked: 1,
                lastMade: sixtyDaysAgo,
                tags: ["dinner", "comfort food", "creamy"]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Vegetable Stir Fry",
                cuisine: "Chinese",
                timesCooked: 0,
                tags: ["dinner", "quick", "vegetarian", "healthy"]
            )
        ]
    }
}
