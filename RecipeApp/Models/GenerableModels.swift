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

struct RecipeSearchCriteria: Codable {
    // MARK: - Structured Filters (Path A)
    let cuisine: String?
    let maxTotalTime: Int?
    let favoritesOnly: Bool
    let onlyNeverCooked: Bool
    let onlyCookedLongAgo: Bool
    let onlyCookedRecently: Bool

    // MARK: - Text Search Keywords (Path B)
    let titleKeywords: [String]
    let ingredientKeywords: [String]
    let notesKeywords: [String]

    // MARK: - Combine Mode
    let combineMode: String  // "and" or "or"
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
