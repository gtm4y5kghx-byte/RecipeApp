import Foundation

enum SearchScope: String, CaseIterable {
    case all = "All"
    case title = "Title"
    case cuisine = "Cuisine"
    case ingredients = "Ingredients"
    case instructions = "Instructions"
    case notes = "Notes"

    var localizedName: String {
        String(localized: String.LocalizationValue(rawValue))
    }
}
