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

    var formattedTotalTime: String? {
        guard let totalTime = recipe.totalTime else { return nil }
        if totalTime < 60 {
            return "\(totalTime) min"
        }
        let hours = totalTime / 60
        let minutes = totalTime % 60
        if minutes == 0 {
            return "\(hours)h"
        }
        return "\(hours)h \(minutes)m"
    }
    
    var groupedIngredients: [(section: String?, ingredients: [Ingredient])] {
        let sorted = recipe.ingredients.sorted { $0.order < $1.order }
        return Dictionary(grouping: sorted, by: \.section)
            .map { (section: $0.key, ingredients: $0.value) }
            .sorted { ($0.section ?? "") < ($1.section ?? "") }
    }
}
