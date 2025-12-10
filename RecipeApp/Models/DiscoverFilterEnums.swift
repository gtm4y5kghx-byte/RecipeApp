import Foundation

// MARK: - Dietary Restriction

enum DietaryRestriction: String, Codable, CaseIterable {
    case glutenFree = "Gluten Free"
    case ketogenic = "Ketogenic"
    case lactoVegetarian = "Lacto-vegetarian"
    case lowFODMAP = "Low FODMAP"
    case ovoVegetarian = "Ovo-vegetarian"
    case paleo = "Paleo"
    case pescetarian = "Pescetarian"
    case primal = "Primal"
    case vegan = "Vegan"
    case vegetarian = "Vegetarian"
    case whole30 = "Whole30"

    var displayName: String {
        switch self {
        case .glutenFree: return "Gluten-Free"
        case .ketogenic: return "Keto"
        case .lactoVegetarian: return "Lacto-Vegetarian"
        case .lowFODMAP: return "Low FODMAP"
        case .ovoVegetarian: return "Ovo-Vegetarian"
        case .paleo: return "Paleo"
        case .pescetarian: return "Pescatarian"
        case .primal: return "Primal"
        case .vegan: return "Vegan"
        case .vegetarian: return "Vegetarian"
        case .whole30: return "Whole30"
        }
    }

    var spoonacularValue: String {
        rawValue
    }
}

// MARK: - Food Intolerance

enum FoodIntolerance: String, Codable, CaseIterable {
    case dairy = "Dairy"
    case egg = "Egg"
    case gluten = "Gluten"
    case grain = "Grain"
    case peanut = "Peanut"
    case seafood = "Seafood"
    case sesame = "Sesame"
    case shellfish = "Shellfish"
    case soy = "Soy"
    case sulfite = "Sulfite"
    case treeNut = "Tree Nut"
    case wheat = "Wheat"

    var displayName: String {
        rawValue
    }

    var spoonacularValue: String {
        rawValue
    }
}
