import Foundation

@Observable
class RecipePickerViewModel {
    private var recipes: [Recipe]
    var searchText = ""
    var searchScope: SearchScope = .all

    init(recipes: [Recipe]) {
        self.recipes = recipes
    }

    var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return recipes
        }
        return recipes.filter { matchesScope(recipe: $0) }
    }

    func updateRecipes(_ recipes: [Recipe]) {
        self.recipes = recipes
    }

    private func matchesScope(recipe: Recipe) -> Bool {
        switch searchScope {
        case .all:
            return matchesAnyField(recipe: recipe)
        case .title:
            return substringMatch(in: recipe.title)
        case .cuisine:
            return matchesCuisine(recipe: recipe)
        case .ingredients:
            return matchesIngredients(recipe: recipe)
        case .instructions:
            return matchesInstructions(recipe: recipe)
        case .notes:
            return matchesNotes(recipe: recipe)
        }
    }

    private func matchesAnyField(recipe: Recipe) -> Bool {
        substringMatch(in: recipe.title) ||
        matchesCuisine(recipe: recipe) ||
        matchesIngredients(recipe: recipe) ||
        matchesInstructions(recipe: recipe) ||
        matchesNotes(recipe: recipe)
    }

    private func matchesCuisine(recipe: Recipe) -> Bool {
        guard let cuisine = recipe.cuisine else { return false }
        return substringMatch(in: cuisine)
    }

    private func matchesIngredients(recipe: Recipe) -> Bool {
        recipe.ingredients.contains { substringMatch(in: $0.item) }
    }

    private func matchesInstructions(recipe: Recipe) -> Bool {
        recipe.instructions.contains { substringMatch(in: $0.instruction) }
    }

    private func matchesNotes(recipe: Recipe) -> Bool {
        guard let notes = recipe.notes else { return false }
        return substringMatch(in: notes)
    }

    private func substringMatch(in text: String) -> Bool {
        let query = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return false }
        return text.lowercased().contains(query)
    }
}
