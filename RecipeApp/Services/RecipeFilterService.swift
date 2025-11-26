import Foundation
import SwiftData


struct RecipeFilterService {
    static func filterRecipes(_ recipes: [Recipe], using criteria: RecipeSearchCriteria) -> [Recipe] {
        return recipes.filter { recipe in
            if let cuisine = criteria.cuisine {
                guard recipe.cuisine?.localizedCaseInsensitiveContains(cuisine) == true else {
                    return false
                }
            }
            
            if let maxTime = criteria.maxTotalTime {
                let totalTime = (recipe.prepTime ?? 0) + (recipe.cookTime ?? 0)
                // Only filter out if recipe has time data AND exceeds max
                // If no time data, include it (better to show than hide)
                if totalTime > 0 && totalTime > maxTime {
                    return false
                }
            }
            
            if criteria.favoritesOnly {
                guard recipe.isFavorite else {
                    return false
                }
            }
            
            if criteria.neverCooked {
                guard recipe.timesCooked == 0 else {
                    return false
                }
            }
            
            if criteria.excludeRecentlyCooked {
                if let lastMade = recipe.lastMade {
                    let daysSinceCooked = Calendar.current.dateComponents([.day], from: lastMade, to: Date()).day ?? 0
                    guard daysSinceCooked > 30 else {
                        return false
                    }
                }
            }
            
            if !criteria.keywords.isEmpty {
                let hasOtherCriteria = criteria.cuisine != nil ||
                criteria.maxTotalTime != nil ||
                criteria.favoritesOnly ||
                criteria.neverCooked ||
                criteria.excludeRecentlyCooked
                
                if !hasOtherCriteria {
                    let matchesKeyword = criteria.keywords.contains { keyword in
                        if recipe.title.localizedCaseInsensitiveContains(keyword) {
                            return true
                        }
                        
                        for ingredient in recipe.ingredients {
                            if ingredient.item.localizedCaseInsensitiveContains(keyword) {
                                return true
                            }
                        }
                        
                        if let notes = recipe.notes, notes.localizedCaseInsensitiveContains(keyword) {
                            return true
                        }
                        
                        return false
                    }
                    
                    guard matchesKeyword else {
                        return false
                    }
                }
            }
            
            return true
        }
    }
}
