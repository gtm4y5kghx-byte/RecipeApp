import Foundation

struct RecipeContextFormatter {
    /// for single recipes (used by ClaudeRecipeTransformationService)
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
    
    /// for recipe catalogs (used by AISuggestionEngineService)
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

    /// for meal plan review (formats current week's entries by day/meal)
    static func formatCurrentPlan(_ entries: [MealPlanEntry], startingFrom startDate: Date = Date()) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: startDate)
        var context = ""

        for dayOffset in 0..<7 {
            guard let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }

            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE (MMM d)"
            context += "\n\(formatter.string(from: targetDate)):\n"

            let dayEntries = entries.filter { entry in
                calendar.isDate(entry.date, inSameDayAs: targetDate)
            }

            for mealType in MealType.allCases {
                let mealEntries = dayEntries.filter { $0.mealType == mealType }
                if mealEntries.isEmpty {
                    context += "  - \(mealType.rawValue.capitalized): [EMPTY]\n"
                } else {
                    for entry in mealEntries {
                        let recipeName = entry.recipe?.title ?? "Unknown"
                        context += "  - \(mealType.rawValue.capitalized): \(recipeName)\n"
                    }
                }
            }
        }

        return context
    }
}
