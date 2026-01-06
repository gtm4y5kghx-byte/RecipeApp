import Foundation

struct RecipeCandidateSelector {

    static let defaultLimit = 60

    /// Selects a subset of recipes optimized for AI context.
    /// Prioritizes: favorites, tag matches (if mealType provided), stale recipes, then random fill.
    static func selectCandidates(
        from recipes: [Recipe],
        for mealType: MealType? = nil,
        limit: Int = defaultLimit
    ) -> [Recipe] {
        guard recipes.count > limit else {
            return recipes
        }

        var selectedIDs: Set<UUID> = []
        var candidates: [Recipe] = []

        func addIfNew(_ recipe: Recipe) {
            guard !selectedIDs.contains(recipe.id) else { return }
            selectedIDs.insert(recipe.id)
            candidates.append(recipe)
        }

        // 1. All favorites (up to 15)
        for recipe in recipes.filter({ $0.isFavorite }).prefix(15) {
            addIfNew(recipe)
        }

        // 2. Tag matches for meal type (up to 25) - only if mealType provided
        if let mealType = mealType {
            let mealTypeString = mealType.rawValue.lowercased()
            let tagMatches = recipes.filter { recipe in
                recipe.userTags.contains { $0.lowercased().contains(mealTypeString) }
            }
            for recipe in tagMatches.prefix(25) {
                addIfNew(recipe)
            }
        }

        // 3. Not made in 30+ days or never made (up to 20)
        let staleRecipes = recipes.filter { recipe in
            guard let lastMade = recipe.lastMade else { return true }
            return Date().daysSince(lastMade) > 30
        }
        for recipe in staleRecipes.prefix(20) {
            addIfNew(recipe)
        }

        // 4. Fill remainder randomly if under limit
        if candidates.count < limit {
            let remaining = recipes.filter { !selectedIDs.contains($0.id) }
            for recipe in remaining.shuffled().prefix(limit - candidates.count) {
                addIfNew(recipe)
            }
        }

        return Array(candidates.prefix(limit))
    }
}
