import Foundation

class SpoonacularCache {
    private static let expirationInterval: TimeInterval = 3600  // 1 hour per Spoonacular TOS

    private struct CachedSearch {
        let response: SpoonacularSearchResponse
        let timestamp: Date

        var isExpired: Bool {
            let timeSinceCache = Date().timeIntervalSince(timestamp)
            return timeSinceCache > SpoonacularCache.expirationInterval
        }
    }

    private struct CachedRecipe {
        let recipe: DiscoveredRecipe
        let timestamp: Date

        var isExpired: Bool {
            let timeSinceCache = Date().timeIntervalSince(timestamp)
            return timeSinceCache > SpoonacularCache.expirationInterval
        }
    }

    private var searches: [String: CachedSearch] = [:]
    private var recipes: [Int: CachedRecipe] = [:]

    func getSearch(key: String) -> SpoonacularSearchResponse? {
        guard let cached = searches[key], !cached.isExpired else {
            searches.removeValue(forKey: key)
            return nil
        }
        return cached.response
    }

    func setSearch(key: String, response: SpoonacularSearchResponse) {
        searches[key] = CachedSearch(response: response, timestamp: Date())
    }

    func getRecipe(id: Int) -> DiscoveredRecipe? {
        guard let cached = recipes[id], !cached.isExpired else {
            recipes.removeValue(forKey: id)
            return nil
        }
        return cached.recipe
    }

    func setRecipe(recipe: DiscoveredRecipe) {
        recipes[recipe.id] = CachedRecipe(recipe: recipe, timestamp: Date())
    }

    func clearExpired() {
        searches = searches.filter { !$0.value.isExpired }
        recipes = recipes.filter { !$0.value.isExpired }
    }

    func clearAll() {
        searches.removeAll()
        recipes.removeAll()
    }
}
