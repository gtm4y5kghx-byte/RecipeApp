import Testing
import Foundation
@testable import RecipeApp

@Suite("AI Recommendation History Tests")
struct AIRecommendationHistoryTests {

    private func createCleanUserDefaults() -> UserDefaults {
        let suiteName = "AIRecommendationHistoryTests.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
        return userDefaults
    }

    // MARK: - Load Tests

    @Test("Load returns empty array when no data exists")
    func loadReturnsEmptyWhenNoData() {
        let defaults = createCleanUserDefaults()
        let records = AIRecommendationHistoryStore.load(.suggestions, userDefaults: defaults)
        #expect(records.isEmpty)
    }

    // MARK: - Append + Load Tests

    @Test("Append stores records and load retrieves them")
    func appendAndLoad() {
        let defaults = createCleanUserDefaults()
        let ids = ["id-1", "id-2", "id-3"]

        AIRecommendationHistoryStore.append(ids, for: .suggestions, userDefaults: defaults)

        let records = AIRecommendationHistoryStore.load(.suggestions, userDefaults: defaults)
        let loadedIDs = records.map { $0.identifier }

        #expect(loadedIDs.count == 3)
        #expect(loadedIDs.contains("id-1"))
        #expect(loadedIDs.contains("id-2"))
        #expect(loadedIDs.contains("id-3"))
    }

    @Test("Append accumulates and does not overwrite previous entries")
    func appendAccumulates() {
        let defaults = createCleanUserDefaults()

        AIRecommendationHistoryStore.append(["id-1", "id-2"], for: .suggestions, userDefaults: defaults)
        AIRecommendationHistoryStore.append(["id-3"], for: .suggestions, userDefaults: defaults)

        let records = AIRecommendationHistoryStore.load(.suggestions, userDefaults: defaults)
        #expect(records.count == 3)

        let ids = records.map { $0.identifier }
        #expect(ids.contains("id-1"))
        #expect(ids.contains("id-2"))
        #expect(ids.contains("id-3"))
    }

    // MARK: - Pruning Tests

    @Test("Records older than 30 days are pruned on load")
    func prunesStaleRecordsOnLoad() {
        let defaults = createCleanUserDefaults()
        let staleDate = Calendar.current.date(byAdding: .day, value: -31, to: Date())!
        let freshDate = Date()

        let records = [
            RecommendationRecord(identifier: "stale", recommendedAt: staleDate),
            RecommendationRecord(identifier: "fresh", recommendedAt: freshDate)
        ]

        saveDirectly(records, for: .suggestions, userDefaults: defaults)

        let loaded = AIRecommendationHistoryStore.load(.suggestions, userDefaults: defaults)
        #expect(loaded.count == 1)
        #expect(loaded.first?.identifier == "fresh")
    }

    @Test("Records older than 30 days are pruned on append")
    func prunesStaleRecordsOnAppend() {
        let defaults = createCleanUserDefaults()
        let staleDate = Calendar.current.date(byAdding: .day, value: -31, to: Date())!

        let staleRecords = [
            RecommendationRecord(identifier: "stale", recommendedAt: staleDate)
        ]

        saveDirectly(staleRecords, for: .suggestions, userDefaults: defaults)

        AIRecommendationHistoryStore.append(["new"], for: .suggestions, userDefaults: defaults)

        let loaded = AIRecommendationHistoryStore.load(.suggestions, userDefaults: defaults)
        #expect(loaded.count == 1)
        #expect(loaded.first?.identifier == "new")
    }

    // MARK: - Clear Tests

    @Test("Clear removes history for a specific key")
    func clearRemovesSpecificKey() {
        let defaults = createCleanUserDefaults()

        AIRecommendationHistoryStore.append(["id-1"], for: .suggestions, userDefaults: defaults)
        AIRecommendationHistoryStore.append(["id-2"], for: .generatedRecipes, userDefaults: defaults)

        AIRecommendationHistoryStore.clear(.suggestions, userDefaults: defaults)

        let suggestions = AIRecommendationHistoryStore.load(.suggestions, userDefaults: defaults)
        let generated = AIRecommendationHistoryStore.load(.generatedRecipes, userDefaults: defaults)

        #expect(suggestions.isEmpty)
        #expect(generated.count == 1)
    }

    @Test("ClearAll removes all history keys")
    func clearAllRemovesAllKeys() {
        let defaults = createCleanUserDefaults()

        AIRecommendationHistoryStore.append(["id-1"], for: .suggestions, userDefaults: defaults)
        AIRecommendationHistoryStore.append(["id-2"], for: .generatedRecipes, userDefaults: defaults)
        AIRecommendationHistoryStore.append(["id-3"], for: .mealPlanRecipes, userDefaults: defaults)

        AIRecommendationHistoryStore.clearAll(userDefaults: defaults)

        #expect(AIRecommendationHistoryStore.load(.suggestions, userDefaults: defaults).isEmpty)
        #expect(AIRecommendationHistoryStore.load(.generatedRecipes, userDefaults: defaults).isEmpty)
        #expect(AIRecommendationHistoryStore.load(.mealPlanRecipes, userDefaults: defaults).isEmpty)
    }

    // MARK: - Key Independence Tests

    @Test("Different keys store independently")
    func keysAreIndependent() {
        let defaults = createCleanUserDefaults()

        AIRecommendationHistoryStore.append(["suggestion-1"], for: .suggestions, userDefaults: defaults)
        AIRecommendationHistoryStore.append(["generated-1"], for: .generatedRecipes, userDefaults: defaults)
        AIRecommendationHistoryStore.append(["meal-1"], for: .mealPlanRecipes, userDefaults: defaults)

        let suggestions = AIRecommendationHistoryStore.load(.suggestions, userDefaults: defaults)
        let generated = AIRecommendationHistoryStore.load(.generatedRecipes, userDefaults: defaults)
        let mealPlan = AIRecommendationHistoryStore.load(.mealPlanRecipes, userDefaults: defaults)

        #expect(suggestions.count == 1)
        #expect(suggestions.first?.identifier == "suggestion-1")
        #expect(generated.count == 1)
        #expect(generated.first?.identifier == "generated-1")
        #expect(mealPlan.count == 1)
        #expect(mealPlan.first?.identifier == "meal-1")
    }

    // MARK: - Test Helpers

    private func saveDirectly(_ records: [RecommendationRecord], for key: AIHistoryKey, userDefaults: UserDefaults) {
        if let data = try? JSONEncoder().encode(records) {
            userDefaults.set(data, forKey: key.rawValue)
        }
    }
}
