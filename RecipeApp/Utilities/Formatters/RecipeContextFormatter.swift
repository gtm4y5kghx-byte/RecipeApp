import Foundation

struct RecipeContextFormatter {
    /// for single recipes (used by FoundationModelsService)
    static func format(_ recipe: Recipe) -> String {
        var context = "Title: \(recipe.title)\n"
        
        if let servings = recipe.servings {
            context += "Servings: \(servings)\n"
        }
        if let prepTime = recipe.prepTime {
            context += "Prep Time: \(prepTime) min\n"
        }
        if let cookTime = recipe.cookTime {
            context += "Cook Time: \(cookTime) min\n"
        }
        if let cuisine = recipe.cuisine {
            context += "Cuisine: \(cuisine)\n"
        }
        
        context += "\nIngredients:\n"
        for ingredient in recipe.sortedIngredients {
            context += "- \(IngredientFormatter.format(ingredient))\n"
        }
        
        context += "\nInstructions:\n"
        for (index, step) in recipe.sortedInstructions.enumerated() {
            context += "\(index + 1). \(step.instruction)\n"
        }
        
        if let notes = recipe.notes, !notes.isEmpty {
            context += "Notes: \(notes)\n"
        }
        
        return context
    }
    
    /// for recipe catalogs (used by AISuggestionEngine)
    static func formatCatalog(_ recipes: [Recipe]) -> String {
        var context = ""
        
        for (index, recipe) in recipes.enumerated() {
            context += "\n[\(index + 1)] \(recipe.title) (ID: \(recipe.id))\n"
            context += "   Cuisine: \(recipe.cuisine ?? "Unknown")\n"
            context += "   Total Time: \(recipe.totalTime ?? 0) min\n"
            context += "   Times Cooked: \(recipe.timesCooked)\n"
            
            if let lastMade = recipe.lastMade {
                let daysAgo = Date().daysSince(lastMade)
                context += "   Last Made: \(daysAgo) days ago\n"
            } else {
                context += "   Last Made: Never\n"
            }
            
            context += "   Favorite: \(recipe.isFavorite ? "Yes" : "No")\n"
        }
        
        return context
    }
}
