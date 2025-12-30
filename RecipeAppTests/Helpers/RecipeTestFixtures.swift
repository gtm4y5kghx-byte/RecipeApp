import Foundation
import SwiftData
@testable import RecipeApp

@MainActor
struct RecipeTestFixtures {
    
    static func createInMemoryModelContext() -> ModelContext {
        let schema = Schema([Recipe.self, Ingredient.self, Step.self, NutritionInfo.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: config)
        return ModelContext(container)
    }
    
    static func createRecipe(
        title: String,
        cuisine: String? = nil,
        timesCooked: Int = 0,
        lastMade: Date? = nil,
        isFavorite: Bool = false,
        tags: [String] = [],
        prepTime: Int? = nil,
        cookTime: Int? = nil,
        servings: Int? = nil,
        ingredients: [(quantity: String, unit: String?, item: String)] = [],
        instructions: [String] = [],
        notes: String? = nil,
        nutrition: NutritionInfo? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        imageURL: String? = nil
    ) -> Recipe {
        let recipe = Recipe(title: title, sourceType: .manual)
        recipe.cuisine = cuisine
        recipe.timesCooked = timesCooked
        recipe.lastMade = lastMade
        recipe.isFavorite = isFavorite
        recipe.userTags = tags
        recipe.prepTime = prepTime
        recipe.cookTime = cookTime
        recipe.servings = servings
        recipe.notes = notes
        recipe.nutrition = nutrition
        recipe.createdAt = createdAt
        recipe.updatedAt = updatedAt
        recipe.imageURL = imageURL
        
        for (index, ing) in ingredients.enumerated() {
            let ingredient = Ingredient(
                quantity: ing.quantity,
                unit: ing.unit,
                item: ing.item,
                preparation: nil,
                section: nil
            )
            ingredient.order = index
            recipe.ingredients.append(ingredient)
        }
        
        for (index, instructionText) in instructions.enumerated() {
            let step = Step(instruction: instructionText)
            step.order = index
            recipe.instructions.append(step)
        }
        
        return recipe
    }
    
    static func createImportData(
        title: String,
        description: String? = nil,
        sourceURL: String? = nil,
        prepTime: Int? = nil,
        cookTime: Int? = nil,
        servings: Int? = nil,
        cuisine: String? = nil,
        ingredients: [String] = [],
        instructions: [String] = [],
        nutrition: NutritionImportData? = nil
    ) -> RecipeImportData {
        return RecipeImportData(
            title: title,
            description: description,
            sourceURL: sourceURL,
            imageURL: nil,
            prepTime: prepTime,
            cookTime: cookTime,
            totalTime: nil,
            servings: servings,
            cuisine: cuisine,
            category: nil,
            ingredients: ingredients,
            instructions: instructions,
            nutrition: nutrition,
            author: nil
        )
    }
    
    static func createSampleRecipes() -> [Recipe] {
        let today = Date()
        let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: today)!
        let thirtyFiveDaysAgo = Calendar.current.date(byAdding: .day, value: -35, to: today)!
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: today)!
        let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: today)!
        
        return [
            createRecipe(
                title: "Pasta Carbonara",
                cuisine: "Italian",
                timesCooked: 5,
                lastMade: fiveDaysAgo,
                isFavorite: true,
                tags: ["dinner", "pasta"],
                createdAt: thirtyFiveDaysAgo,
                imageURL: "https://placehold.co/400x300"
            ),
            createRecipe(
                title: "Chicken Tikka Masala",
                cuisine: "Indian",
                timesCooked: 2,
                lastMade: thirtyFiveDaysAgo,
                tags: ["dinner", "spicy"],
                createdAt: twoWeeksAgo,
                imageURL: "https://placehold.co/400x300"
            ),
            createRecipe(
                title: "Caesar Salad",
                cuisine: "American",
                timesCooked: 0,
                tags: ["lunch", "salad"],
                createdAt: oneWeekAgo,
                imageURL: "https://placehold.co/400x300"
            ),
            createRecipe(
                title: "Thai Green Curry",
                cuisine: "Thai",
                timesCooked: 3,
                lastMade: fiveDaysAgo,
                isFavorite: true,
                tags: ["dinner"],
                createdAt: fiveDaysAgo,
                imageURL: "https://placehold.co/400x300"
            ),
            createRecipe(
                title: "Untagged Recipe",
                createdAt: today,
                imageURL: "https://placehold.co/400x300"
            ),
        ]
    }
    
    static func createRecipeSuggestion(
        recipeID: UUID,
        reason: String = "You haven't cooked this in a while"
    ) -> RecipeSuggestion {
        return RecipeSuggestion(recipeID: recipeID, aiGeneratedReason: reason)
    }

    static func createGeneratedRecipe(
        title: String = "Generated Recipe",
        description: String = "A test generated recipe",
        ingredients: [(quantity: String, unit: String?, item: String, preparation: String?)] = [
            ("1 cup", "cups", "flour", nil),
            ("2", nil, "eggs", "beaten")
        ],
        instructions: [String] = ["Step 1", "Step 2"],
        prepTime: Int? = 15,
        cookTime: Int? = 30,
        servings: Int? = 4,
        cuisine: String? = "Italian",
        tags: [String] = ["quick"],
        nutrition: (calories: Int, protein: Double)? = (450, 25.0)
    ) -> GeneratedRecipe {
        let ingredientsJSON = ingredients.map { ing in
            """
            {"quantity": "\(ing.0)", "unit": \(ing.1.map { "\"\($0)\"" } ?? "null"), "item": "\(ing.2)", "preparation": \(ing.3.map { "\"\($0)\"" } ?? "null")}
            """
        }.joined(separator: ", ")

        let instructionsJSON = instructions.map { "\"\($0)\"" }.joined(separator: ", ")
        let tagsJSON = tags.map { "\"\($0)\"" }.joined(separator: ", ")

        var json = """
        {
            "title": "\(title)",
            "description": "\(description)",
            "ingredients": [\(ingredientsJSON)],
            "instructions": [\(instructionsJSON)],
            "tags": [\(tagsJSON)]
        """

        if let prep = prepTime { json += ", \"prepTime\": \(prep)" }
        if let cook = cookTime { json += ", \"cookTime\": \(cook)" }
        if let serv = servings { json += ", \"servings\": \(serv)" }
        if let cuis = cuisine { json += ", \"cuisine\": \"\(cuis)\"" }
        if let nutr = nutrition {
            json += ", \"nutrition\": {\"calories\": \(nutr.calories), \"protein\": \(nutr.protein)}"
        }
        json += "}"

        let data = json.data(using: .utf8)!
        return try! JSONDecoder().decode(GeneratedRecipe.self, from: data)
    }
    
    static func createViewModelWithSuggestions(
        recipeCount: Int = 15,
        suggestionCount: Int = 3
    ) -> (RecipeListViewModel, [Recipe]) {
        let recipes = createSampleRecipes()
        let modelContext = createInMemoryModelContext()
        let viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)
        
        let suggestions = recipes.prefix(suggestionCount).map { recipe in
            createRecipeSuggestion(recipeID: recipe.id, reason: "Try this again!")
        }
        
        viewModel.suggestions = Array(suggestions)
        return (viewModel, recipes)
    }
}
