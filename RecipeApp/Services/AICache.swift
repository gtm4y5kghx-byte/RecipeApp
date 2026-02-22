import Foundation

enum AICacheKey: String {
    case suggestions = "suggestion_cache"
    case generatedRecipes = "generated_recipe_cache"

    static var allKeys: [AICacheKey] { [.suggestions, .generatedRecipes] }
}

struct CacheEntry<T: Codable>: Codable {
    let payload: T
    let generatedAt: Date

    var isStale: Bool {
        Date().daysSince(generatedAt) >= TimeConstants.aiCacheStaleDays
    }
}

enum AICache {
    static func load<T: Codable>(_ key: AICacheKey) -> CacheEntry<T>? {
        guard let data = UserDefaults.standard.data(forKey: key.rawValue) else {
            return nil
        }
        return try? JSONDecoder().decode(CacheEntry<T>.self, from: data)
    }

    static func save<T: Codable>(_ payload: T, for key: AICacheKey) {
        let entry = CacheEntry(payload: payload, generatedAt: Date())
        if let data = try? JSONEncoder().encode(entry) {
            UserDefaults.standard.set(data, forKey: key.rawValue)
        }
    }

    static func invalidate(_ key: AICacheKey) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }

    static func invalidateAll() {
        AICacheKey.allKeys.forEach { invalidate($0) }
        AIRecommendationHistoryStore.clearAll()
    }
}
