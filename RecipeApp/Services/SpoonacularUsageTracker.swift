import Foundation

class SpoonacularUsageTracker {
    private static let dailySearchLimit = 5
    private static let searchCountKey = "spoonacular_search_count"
    private static let lastResetDateKey = "spoonacular_last_reset_date"

    var searchesUsedToday: Int {
        resetIfNewDay()
        return UserDefaults.standard.integer(forKey: Self.searchCountKey)
    }

    var canSearch: Bool {
        searchesUsedToday < Self.dailySearchLimit
    }

    func recordSearch() {
        resetIfNewDay()
        let currentCount = UserDefaults.standard.integer(forKey: Self.searchCountKey)
        UserDefaults.standard.set(currentCount + 1, forKey: Self.searchCountKey)
    }

    func reset() {
        UserDefaults.standard.set(0, forKey: Self.searchCountKey)
        UserDefaults.standard.set(Date(), forKey: Self.lastResetDateKey)
    }

    private func resetIfNewDay() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastResetDate = UserDefaults.standard.object(forKey: Self.lastResetDateKey) as? Date {
            let lastResetDay = calendar.startOfDay(for: lastResetDate)

            if today > lastResetDay {
                reset()
            }
        } else {
            reset()
        }
    }
}
