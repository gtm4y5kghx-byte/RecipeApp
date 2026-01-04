import Testing
import Foundation
@testable import RecipeApp

@Suite("Recipe Generation Service Integration - Manual Validation")
@MainActor
struct RecipeGenerationServiceIntegration {
    
    private let service = RecipeGenerationService()
    
    @Test("Generate recipes with real Claude API")
    func validateGenerateRecipes() async throws {
        let recipes = createTestRecipeCollection()
        
        print("\n========== RECIPE GENERATION TEST ==========")
        print("Collection size: \(recipes.count) recipes")
        printCollectionSummary(recipes)
        
        let startTime = Date()
        let generatedRecipes = try await service.generateRecipes(recipes: recipes, count: 3)
        let duration = Date().timeIntervalSince(startTime)
        
        print("\nGeneration completed in \(String(format: "%.2f", duration))s")
        print("Generated \(generatedRecipes.count) recipes")
        
        for (index, recipe) in generatedRecipes.enumerated() {
            printGeneratedRecipe(recipe, index: index + 1)
        }
        print("=============================================\n")
        
        #expect(generatedRecipes.count == 3)
        #expect(generatedRecipes.allSatisfy { !$0.title.isEmpty })
        #expect(generatedRecipes.allSatisfy { !$0.ingredients.isEmpty })
        #expect(generatedRecipes.allSatisfy { !$0.instructions.isEmpty })
    }
    
    @Test("Generate recipes with empty catalog")
    func validateGenerateRecipesWithEmptyCatalog() async throws {
        print("\n========== EMPTY CATALOG GENERATION TEST ==========")
        print("Testing new user experience with variety-focused generation")

        let startTime = Date()
        let generatedRecipes = try await service.generateRecipes(recipes: [], count: 5)
        let duration = Date().timeIntervalSince(startTime)

        print("Generation completed in \(String(format: "%.2f", duration))s")
        print("Generated \(generatedRecipes.count) recipes")

        for (index, recipe) in generatedRecipes.enumerated() {
            printGeneratedRecipe(recipe, index: index + 1)
        }
        print("================================================\n")

        #expect(generatedRecipes.count == 5)
        #expect(generatedRecipes.allSatisfy { !$0.title.isEmpty })
        #expect(generatedRecipes.allSatisfy { !$0.ingredients.isEmpty })
        #expect(generatedRecipes.allSatisfy { !$0.instructions.isEmpty })
    }
    
    // MARK: - Test Helpers
    
    private func createTestRecipeCollection() -> [Recipe] {
        let today = Date()
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: today)!
        let sixtyDaysAgo = Calendar.current.date(byAdding: .day, value: -60, to: today)!
        
        return [
            RecipeTestFixtures.createRecipe(
                title: "Pasta Carbonara",
                cuisine: "Italian",
                timesCooked: 5,
                lastMade: sixtyDaysAgo,
                isFavorite: true,
                prepTime: 15,
                cookTime: 20,
                ingredients: [
                    (quantity: "1 lb", unit: "pounds", item: "spaghetti"),
                    (quantity: "4", unit: nil, item: "eggs"),
                    (quantity: "1 cup", unit: "cups", item: "parmesan cheese")
                ],
                instructions: ["Boil pasta", "Mix eggs and cheese", "Combine"]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Chicken Tikka Masala",
                cuisine: "Indian",
                timesCooked: 3,
                lastMade: thirtyDaysAgo,
                prepTime: 20,
                cookTime: 40,
                ingredients: [
                    (quantity: "2 lbs", unit: "pounds", item: "chicken thighs"),
                    (quantity: "1 cup", unit: "cups", item: "yogurt"),
                    (quantity: "2 cups", unit: "cups", item: "tomato sauce")
                ],
                instructions: ["Marinate chicken", "Grill chicken", "Make sauce", "Combine"]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Thai Green Curry",
                cuisine: "Thai",
                timesCooked: 2,
                isFavorite: true,
                prepTime: 15,
                cookTime: 25,
                ingredients: [
                    (quantity: "1 can", unit: nil, item: "coconut milk"),
                    (quantity: "2 tbsp", unit: "tablespoons", item: "green curry paste"),
                    (quantity: "1 lb", unit: "pounds", item: "chicken")
                ],
                instructions: ["Simmer curry paste", "Add coconut milk", "Cook chicken"]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Beef Tacos",
                cuisine: "Mexican",
                timesCooked: 8,
                lastMade: today,
                isFavorite: true,
                prepTime: 10,
                cookTime: 15,
                ingredients: [
                    (quantity: "1 lb", unit: "pounds", item: "ground beef"),
                    (quantity: "1 packet", unit: nil, item: "taco seasoning"),
                    (quantity: "8", unit: nil, item: "taco shells")
                ],
                instructions: ["Brown beef", "Add seasoning", "Serve in shells"]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Caesar Salad",
                cuisine: "American",
                timesCooked: 4,
                prepTime: 15,
                cookTime: 0,
                ingredients: [
                    (quantity: "1 head", unit: nil, item: "romaine lettuce"),
                    (quantity: "1/2 cup", unit: "cups", item: "caesar dressing"),
                    (quantity: "1/4 cup", unit: "cups", item: "parmesan")
                ],
                instructions: ["Chop lettuce", "Add dressing", "Top with parmesan"]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Pad Thai",
                cuisine: "Thai",
                timesCooked: 1,
                prepTime: 20,
                cookTime: 15,
                ingredients: [
                    (quantity: "8 oz", unit: "ounces", item: "rice noodles"),
                    (quantity: "2", unit: nil, item: "eggs"),
                    (quantity: "1/4 cup", unit: "cups", item: "fish sauce")
                ],
                instructions: ["Soak noodles", "Stir fry", "Add sauce"]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Margherita Pizza",
                cuisine: "Italian",
                timesCooked: 6,
                lastMade: thirtyDaysAgo,
                isFavorite: true,
                prepTime: 30,
                cookTime: 15,
                ingredients: [
                    (quantity: "1 lb", unit: "pounds", item: "pizza dough"),
                    (quantity: "1 cup", unit: "cups", item: "tomato sauce"),
                    (quantity: "8 oz", unit: "ounces", item: "fresh mozzarella")
                ],
                instructions: ["Roll dough", "Add toppings", "Bake at 450°F"]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Grilled Salmon",
                cuisine: "American",
                timesCooked: 3,
                lastMade: sixtyDaysAgo,
                prepTime: 10,
                cookTime: 12,
                ingredients: [
                    (quantity: "4", unit: nil, item: "salmon fillets"),
                    (quantity: "2 tbsp", unit: "tablespoons", item: "olive oil"),
                    (quantity: "1", unit: nil, item: "lemon")
                ],
                instructions: ["Season salmon", "Grill 6 min per side", "Squeeze lemon"]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Chicken Fajitas",
                cuisine: "Mexican",
                timesCooked: 5,
                isFavorite: true,
                prepTime: 15,
                cookTime: 20,
                ingredients: [
                    (quantity: "1 lb", unit: "pounds", item: "chicken breast"),
                    (quantity: "2", unit: nil, item: "bell peppers"),
                    (quantity: "1", unit: nil, item: "onion")
                ],
                instructions: ["Slice chicken and veggies", "Sauté", "Serve with tortillas"]
            ),
            RecipeTestFixtures.createRecipe(
                title: "Mushroom Risotto",
                cuisine: "Italian",
                timesCooked: 2,
                prepTime: 10,
                cookTime: 35,
                ingredients: [
                    (quantity: "1.5 cups", unit: "cups", item: "arborio rice"),
                    (quantity: "8 oz", unit: "ounces", item: "mushrooms"),
                    (quantity: "4 cups", unit: "cups", item: "chicken broth")
                ],
                instructions: ["Sauté mushrooms", "Toast rice", "Add broth gradually", "Stir constantly"]
            )
        ]
    }
    
    private func printCollectionSummary(_ recipes: [Recipe]) {
        let cuisines = Dictionary(grouping: recipes.compactMap { $0.cuisine }, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        let cookTimes = recipes.compactMap { $0.totalTime }
        let avgCookTime = cookTimes.isEmpty ? 0 : cookTimes.reduce(0, +) / cookTimes.count
        let favoriteCount = recipes.filter { $0.isFavorite }.count
        
        print("Cuisines: \(cuisines.map { "\($0.key)(\($0.value))" }.joined(separator: ", "))")
        print("Average cook time: \(avgCookTime) minutes")
        print("Favorites: \(favoriteCount)/\(recipes.count)")
    }
    
    private func printGeneratedRecipe(_ recipe: GeneratedRecipe, index: Int) {
        print("\n--- Recipe \(index): \(recipe.title) ---")
        print("Description: \(recipe.description)")
        print("Cuisine: \(recipe.cuisine ?? "Not specified")")
        print("Time: \(recipe.prepTime ?? 0)min prep + \(recipe.cookTime ?? 0)min cook")
        print("Servings: \(recipe.servings ?? 0)")
        
        print("Ingredients (\(recipe.ingredients.count)):")
        for ingredient in recipe.ingredients.prefix(5) {
            print("  • \(ingredient)")
        }
        if recipe.ingredients.count > 5 {
            print("  • ... and \(recipe.ingredients.count - 5) more")
        }
        
        print("Instructions (\(recipe.instructions.count) steps)")
        
        if let nutrition = recipe.nutrition {
            print("Nutrition: \(nutrition.calories ?? 0) cal, \(nutrition.protein ?? 0)g protein")
        }
    }
}
