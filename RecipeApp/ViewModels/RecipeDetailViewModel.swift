import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
class RecipeDetailViewModel {
    var error: Error?
    
    var recipe: Recipe {
        _recipe
    }
    
    private let _recipe: Recipe
    private let modelContext: ModelContext
    
    init(recipe: Recipe, modelContext: ModelContext) {
        self._recipe = recipe
        self.modelContext = modelContext
    }
    
    
    func toggleFavorite() {
        recipe.isFavorite.toggle()
        do {
            try modelContext.save()
        } catch {
            self.error = error
        }
    }
    
    func markAsCooked() {
        recipe.timesCooked += 1
        recipe.lastMade = Date()
        do {
            try modelContext.save()
        } catch {
            self.error = error
        }
    }
    
    func deleteRecipe() -> Bool {
        do {
            modelContext.delete(recipe)
            try modelContext.save()
            return true
        } catch {
            self.error = error
            return false
        }
    }
    
    func getVariations(from allRecipes: [Recipe]) -> [Recipe] {
        return allRecipes.filter { $0.basedOnRecipeID == recipe.id }
    }
}
