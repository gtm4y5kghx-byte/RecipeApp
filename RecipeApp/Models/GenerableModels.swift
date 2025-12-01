import Foundation
import FoundationModels

@Generable()
struct VoiceRecipe {
    @Guide(description: "The recipe title")
    let title: String
    
    @Guide(description: "Recipe description or notes about the dish")
    let notes: String?
    
    @Guide(description: "Prep time in minutes", .range(0...180))
    let prepTime: Int?
    
    @Guide(description: "Cook time in minutes", .range(0...300))
    let cookTime: Int?
    
    @Guide(description: "Number of servings", .range(1...20))
    let servings: Int?
    
    @Guide(description: "Cuisine type (e.g., Italian, Mexican, Thai)")
    let cuisine: String?
    
    let ingredients: [VoiceIngredient]
    let instructions: [VoiceInstruction]
}

@Generable()
struct RecipeSearchCriteria {
    @Guide(description: "Cuisine type ONLY if explicitly mentioned (Italian, Thai, Mexican, etc.). OMIT this field entirely if no cuisine is mentioned in the query.")
    let cuisine: String?

    @Guide(description: "Maximum total time in minutes ONLY if time is explicitly mentioned. Use 30 for 'quick'/'fast', exact number for '20 minutes', etc. OMIT this field entirely if no time constraint is mentioned.", .range(0...300))
    let maxTotalTime: Int?
    
    @Guide(description: "Keywords or dish types mentioned (e.g., ['pasta', 'dinner', 'vegetarian']). Extract relevant search terms.")
    let keywords: [String]
    
    @Guide(description: "True if user wants only favorites (e.g., 'my favorites', 'recipes I love'). False otherwise.")
    let favoritesOnly: Bool
    
    @Guide(description: "True if user wants recipes they haven't cooked recently (e.g., 'haven't made in a while', 'haven't tried recently'). False otherwise.")
    let excludeRecentlyCooked: Bool
    
    @Guide(description: "True if user wants only recipes never cooked (e.g., 'haven't tried', 'never made', 'new recipes'). False otherwise.")
    let neverCooked: Bool
}

@Generable()
struct VoiceIngredient {
    @Guide(description: "Complete ingredient text including quantity, unit, and item (e.g., '2 cups all-purpose flour')")
    let text: String
}

@Generable()
struct VoiceInstruction {
    @Guide(description: "Instruction step text describing what to do")
    let text: String
}

@Generable
struct TransformedIngredient {
    @Guide(description: "Complete ingredient text including quantity, unit, and item")
    let text: String
    
    @Guide(description: "Brief explanation if this ingredient was changed or substituted (e.g., 'Replaced butter with coconut oil'). Leave empty if unchanged.")
    let changeNote: String?
}

@Generable()
struct TransformedInstruction {
    @Guide(description: "Instruction step text describing what to do")
    let text: String
    
    @Guide(description: "Brief explanation if this step was modified (e.g., 'Reduced temperature for air fryer'). Leave empty if unchanged.")
    let changeNote: String?
}

@Generable()
struct RecipeTransformation {
    @Guide(description: "The transformed recipe title")
    let title: String
    
    @Guide(description: "Brief description of what was changed (e.g., 'Made vegan by replacing eggs and dairy')")
    let variationNote: String
    
    @Guide(description: "Recipe description or notes about the dish")
    let notes: String?
    
    @Guide(description: "Prep time in minutes", .range(0...180))
    let prepTime: Int?
    
    @Guide(description: "Cook time in minutes", .range(0...300))
    let cookTime: Int?
    
    @Guide(description: "Number of servings", .range(1...20))
    let servings: Int?
    
    @Guide(description: "Cuisine type (e.g., Italian, Mexican, Thai)")
    let cuisine: String?
    
    let ingredients: [TransformedIngredient]
    let instructions: [TransformedInstruction]
}
