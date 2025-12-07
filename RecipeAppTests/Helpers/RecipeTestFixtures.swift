import Foundation
@testable import RecipeApp

@MainActor
struct RecipeTestFixtures {
    
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
        instructions: [String] = []
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
    
    static func createSampleRecipes() -> [Recipe] {
        let today = Date()
        let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: today)!
        let thirtyFiveDaysAgo = Calendar.current.date(byAdding: .day, value: -35, to: today)!
        
        return [
            createRecipe(title: "Pasta Carbonara", cuisine: "Italian", timesCooked: 5, lastMade: fiveDaysAgo, isFavorite: true, tags: ["dinner", "pasta"]),
            createRecipe(title: "Chicken Tikka Masala", cuisine: "Indian", timesCooked: 2, lastMade: thirtyFiveDaysAgo, tags: ["dinner", "spicy"]),
            createRecipe(title: "Caesar Salad", cuisine: "American", timesCooked: 0, tags: ["lunch", "salad"]),
            createRecipe(title: "Thai Green Curry", cuisine: "Thai", timesCooked: 3, lastMade: fiveDaysAgo, isFavorite: true, tags: ["dinner"]),
            createRecipe(title: "Untagged Recipe"),
        ]
    }
}
