import Foundation

enum AIHistoryKey: String {
    case suggestions = "ai_history_suggestions"
    case generatedRecipes = "ai_history_generated"
    case mealPlanRecipes = "ai_history_meal_plan"

    static var allKeys: [AIHistoryKey] { [.suggestions, .generatedRecipes, .mealPlanRecipes] }
}

struct RecommendationRecord: Codable {
    let identifier: String
    let recommendedAt: Date
}

enum AIRecommendationHistoryStore {

    static func load(_ key: AIHistoryKey, userDefaults: UserDefaults = .standard) -> [RecommendationRecord] {
        guard let data = userDefaults.data(forKey: key.rawValue) else {
            return []
        }

        guard let records = try? JSONDecoder().decode([RecommendationRecord].self, from: data) else {
            return []
        }

        return prune(records)
    }

    static func append(_ identifiers: [String], for key: AIHistoryKey, userDefaults: UserDefaults = .standard) {
        var existing = loadRaw(key, userDefaults: userDefaults)
        let newRecords = identifiers.map { RecommendationRecord(identifier: $0, recommendedAt: Date()) }
        existing.append(contentsOf: newRecords)
        let pruned = prune(existing)
        save(pruned, for: key, userDefaults: userDefaults)
    }

    static func clear(_ key: AIHistoryKey, userDefaults: UserDefaults = .standard) {
        userDefaults.removeObject(forKey: key.rawValue)
    }

    static func clearAll(userDefaults: UserDefaults = .standard) {
        AIHistoryKey.allKeys.forEach { clear($0, userDefaults: userDefaults) }
    }

    // MARK: - Private

    private static func loadRaw(_ key: AIHistoryKey, userDefaults: UserDefaults) -> [RecommendationRecord] {
        guard let data = userDefaults.data(forKey: key.rawValue) else {
            return []
        }
        return (try? JSONDecoder().decode([RecommendationRecord].self, from: data)) ?? []
    }

    private static func prune(_ records: [RecommendationRecord]) -> [RecommendationRecord] {
        records.filter { Date().daysSince($0.recommendedAt) < TimeConstants.aiRecommendationHistoryDays }
    }

    private static func save(_ records: [RecommendationRecord], for key: AIHistoryKey, userDefaults: UserDefaults) {
        if let data = try? JSONEncoder().encode(records) {
            userDefaults.set(data, forKey: key.rawValue)
        }
    }
}
