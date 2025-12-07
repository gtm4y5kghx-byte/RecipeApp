import Foundation

extension Recipe {
    /// Returns ingredients sorted by their order property
    var sortedIngredients: [Ingredient] {
        ingredients.sorted(by: { $0.order < $1.order })
    }

    /// Returns instructions sorted by their order property
    var sortedInstructions: [Step] {
        instructions.sorted(by: { $0.order < $1.order })
    }
}
