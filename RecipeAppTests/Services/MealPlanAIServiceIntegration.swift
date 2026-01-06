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
        } catch let error as MealPlanAIError {
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
        } catch let error as MealPlanAIError {
            #expect(error.title == "Not Enough Recipes")
            print("\n========== INSUFFICIENT RECIPES ERROR ==========")
            print("Error: \(error.title)")
            print("Message: \(error.message)")
            print("==========================================\n")
        }
    }

    // MARK: - Review Plan Tests

    @Test("Review plan with partially filled week")
    func validateReviewPlan() async throws {
        let recipes = createDiverseRecipeCollection()
        let entries = createPartiallyFilledPlan(from: recipes)

        let insights = try await service.reviewPlan(entries: entries, recipes: recipes)

        print("\n========== REVIEW PLAN ==========")
        print("Entries in plan: \(entries.count)")
        print("Insights generated: \(insights.count)")
        print("\nCurrent Plan:")
        print(RecipeContextFormatter.formatCurrentPlan(entries))
        print("\nInsights:")
        for (index, insight) in insights.enumerated() {
            print("\n\(index + 1). [\(insight.suggestionType.rawValue)]")
            print("   Insight: \(insight.insight)")
            print("   Recommendation: \(insight.recommendation)")
            if let recipe = insight.suggestedRecipe {
                print("   Suggested: \(recipe.title)")
            }
            if let date = insight.targetDate {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE"
                print("   Target Day: \(formatter.string(from: date))")
            }
            if let mealType = insight.targetMealType {
                print("   Target Meal: \(mealType.rawValue)")
            }
        }
        print("==========================================\n")

        #expect(insights.count >= 1)
        #expect(insights.count <= 3)
    }

    @Test("Review plan with pattern issues - all insights have suggestions")
    func validateReviewPlanPatternDetection() async throws {
        let recipes = createDiverseRecipeCollection()
        let entries = createPlanWithPatternIssues(from: recipes)

        let insights = try await service.reviewPlan(entries: entries, recipes: recipes)

        print("\n========== REVIEW PLAN (PATTERN ISSUES) ==========")
        print("Plan has 4 Italian dishes - should detect variety issue")
        print("All insights should have actionable suggestions")
        print("\nCurrent Plan:")
        print(RecipeContextFormatter.formatCurrentPlan(entries))
        print("\nInsights:")
        for (index, insight) in insights.enumerated() {
            print("\n\(index + 1). [\(insight.suggestionType.rawValue)]")
            print("   Insight: \(insight.insight)")
            print("   Recommendation: \(insight.recommendation)")
            if let recipe = insight.suggestedRecipe {
                print("   Suggested: \(recipe.title)")
            } else {
                print("   Suggested: ⚠️ MISSING")
            }
            if let date = insight.targetDate {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE"
                print("   Target Day: \(formatter.string(from: date))")
            } else {
                print("   Target Day: ⚠️ MISSING")
            }
            if let mealType = insight.targetMealType {
                print("   Target Meal: \(mealType.rawValue)")
            } else {
                print("   Target Meal: ⚠️ MISSING")
            }
        }
        print("==========================================\n")

        #expect(insights.count >= 1)

        // Verify ALL insights have actionable suggestions
        for insight in insights {
            #expect(insight.suggestedRecipe != nil, "Insight '\(insight.insight)' missing suggested recipe")
            #expect(insight.targetDate != nil, "Insight '\(insight.insight)' missing target date")
            #expect(insight.targetMealType != nil, "Insight '\(insight.insight)' missing target meal type")
        }
    }

    @Test("Review plan returns empty for empty collection")
    func validateReviewPlanEmptyCollection() async throws {
        let entries: [MealPlanEntry] = []
        let recipes: [Recipe] = []

        let insights = try await service.reviewPlan(entries: entries, recipes: recipes)

        print("\n========== REVIEW EMPTY COLLECTION ==========")
        print("Insights returned: \(insights.count)")
        print("Expected: 0 (empty collection)")
        print("==========================================\n")

        #expect(insights.isEmpty)
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

    private func createPartiallyFilledPlan(from recipes: [Recipe]) -> [MealPlanEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var entries: [MealPlanEntry] = []

        // Day 0 (today) - dinner only
        if let recipe = recipes.first(where: { $0.title == "Pasta Carbonara" }) {
            entries.append(MealPlanEntry(date: today, mealType: .dinner, recipe: recipe))
        }

        // Day 1 - lunch and dinner
        if let day1 = calendar.date(byAdding: .day, value: 1, to: today) {
            if let recipe = recipes.first(where: { $0.title == "Caesar Salad" }) {
                entries.append(MealPlanEntry(date: day1, mealType: .lunch, recipe: recipe))
            }
            if let recipe = recipes.first(where: { $0.title == "Thai Green Curry" }) {
                entries.append(MealPlanEntry(date: day1, mealType: .dinner, recipe: recipe))
            }
        }

        // Day 3 - dinner only (skip day 2)
        if let day3 = calendar.date(byAdding: .day, value: 3, to: today) {
            if let recipe = recipes.first(where: { $0.title == "Beef Tacos" }) {
                entries.append(MealPlanEntry(date: day3, mealType: .dinner, recipe: recipe))
            }
        }

        // Day 5 - lunch only
        if let day5 = calendar.date(byAdding: .day, value: 5, to: today) {
            if let recipe = recipes.first(where: { $0.title == "Greek Salad" }) {
                entries.append(MealPlanEntry(date: day5, mealType: .lunch, recipe: recipe))
            }
        }

        return entries
    }

    private func createPlanWithPatternIssues(from recipes: [Recipe]) -> [MealPlanEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var entries: [MealPlanEntry] = []

        // Create a week heavy on Italian food
        let italianRecipes = recipes.filter { $0.cuisine == "Italian" }

        for (index, recipe) in italianRecipes.prefix(4).enumerated() {
            if let date = calendar.date(byAdding: .day, value: index, to: today) {
                entries.append(MealPlanEntry(date: date, mealType: .dinner, recipe: recipe))
            }
        }

        return entries
    }
}
