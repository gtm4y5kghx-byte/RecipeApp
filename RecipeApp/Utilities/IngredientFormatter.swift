import Foundation

/// Formats an ingredient into a human-readable string
/// Example: "2 cups flour, sifted"
struct IngredientFormatter {
    static func format(_ ingredient: Ingredient) -> String {
        var parts: [String] = []
        
        if !ingredient.quantity.isEmpty {
            parts.append(ingredient.quantity)
        }
        
        if let unit = ingredient.unit {
            parts.append(unit)
        }
        
        parts.append(ingredient.item)
        
        var result = parts.joined(separator: " ")
        
        if let preparation = ingredient.preparation {
            result += ", \(preparation)"
        }
        
        return result
    }
}
