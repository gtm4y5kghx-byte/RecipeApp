import Foundation

enum RecipeListItem: Identifiable {
    case recipe(Recipe, suggestionReason: String?)
    case generatedRecipe(GeneratedRecipe, reason: String)

    var id: UUID {
        switch self {
        case .recipe(let recipe, _):
            return recipe.id
        case .generatedRecipe(let generated, _):
            return generated.id
        }
    }

    var recipe: Recipe? {
        switch self {
        case .recipe(let recipe, _):
            return recipe
        case .generatedRecipe:
            return nil
        }
    }

    var generatedRecipe: GeneratedRecipe? {
        switch self {
        case .recipe:
            return nil
        case .generatedRecipe(let generated, _):
            return generated
        }
    }

    var suggestionReason: String? {
        switch self {
        case .recipe(_, let reason):
            return reason
        case .generatedRecipe(_, let reason):
            return reason
        }
    }

    var isGenerated: Bool {
        switch self {
        case .recipe:
            return false
        case .generatedRecipe:
            return true
        }
    }
}
