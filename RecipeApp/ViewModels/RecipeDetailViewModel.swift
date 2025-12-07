import Foundation
import SwiftUI

@MainActor
@Observable
class RecipeDetailViewModel {
    private let recipe: Recipe

    init(recipe: Recipe) {
        self.recipe = recipe
    }

    func toggleFavorite() {
        recipe.isFavorite.toggle()
    }

    func markAsCooked() {
        recipe.timesCooked += 1
        recipe.lastMade = Date()
    }

    func getVariations(from allRecipes: [Recipe]) -> [Recipe] {
        return allRecipes.filter { $0.parentRecipeID == recipe.id }
    }
}
