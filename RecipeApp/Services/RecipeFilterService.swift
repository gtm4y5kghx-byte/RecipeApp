import Foundation
import SwiftData


struct RecipeFilterService {
    static func filterRecipes(_ recipes: [Recipe], using criteria: RecipeSearchCriteria) -> [Recipe] {
        return recipes.filter { recipe in
            matchesCuisine(recipe, criteria) &&
            matchesTime(recipe, criteria) &&
            matchesFavorites(recipe, criteria) &&
            matchesCookingHistory(recipe, criteria)
        }
    }

    // MARK: - Filter Functions

    private static func matchesCuisine(_ recipe: Recipe, _ criteria: RecipeSearchCriteria) -> Bool {
        guard let cuisine = criteria.cuisine, !cuisine.isEmpty else { return true }
        return recipe.cuisine?.localizedCaseInsensitiveContains(cuisine) == true
    }

    private static func matchesTime(_ recipe: Recipe, _ criteria: RecipeSearchCriteria) -> Bool {
        guard let maxTime = criteria.maxTotalTime, maxTime > 0 else { return true }

        let totalTime = recipe.totalTime ?? 0

        // Only filter out if recipe has time data AND exceeds max
        // If no time data, include it (better to show than hide)
        if totalTime > 0 && totalTime > maxTime {
            return false
        }

        return true
    }

    private static func matchesFavorites(_ recipe: Recipe, _ criteria: RecipeSearchCriteria) -> Bool {
        if criteria.favoritesOnly {
            return recipe.isFavorite
        }
        return true
    }

    private static func matchesCookingHistory(_ recipe: Recipe, _ criteria: RecipeSearchCriteria) -> Bool {
        // If user wants recipes never cooked
        if criteria.onlyNeverCooked {
            return recipe.timesCooked == 0
        }

        // If user wants recipes cooked long ago (30+ days)
        if criteria.onlyCookedLongAgo {
            guard recipe.timesCooked > 0 else { return false }
            guard let lastMade = recipe.lastMade else { return false }

            let daysSinceCooked = Date().daysSince(lastMade)
            return daysSinceCooked > TimeConstants.cookedLongAgoThreshold
        }

        // If user wants recipes cooked recently (within 30 days)
        if criteria.onlyCookedRecently {
            guard let lastMade = recipe.lastMade else { return false }

            let daysSinceCooked = Date().daysSince(lastMade)
            return daysSinceCooked <= TimeConstants.recentlyCookedThreshold
        }

        // No cooking history filter - include all recipes
        return true
    }
}
