import Foundation
import SwiftData

@MainActor
@Observable
class MealPlanViewModel {
    private let service: MealPlanService

    var entries: [MealPlanEntry] = []
    var error: MealPlanError?

    init(modelContext: ModelContext) {
        self.service = MealPlanService(modelContext: modelContext)
    }

    // MARK: - Load Entries

    func loadEntries() {
        do {
            entries = try service.allEntries()
        } catch {
            self.error = .loadFailed
        }
    }

    // MARK: - Query

    func entries(for date: Date) -> [MealPlanEntry] {
        let dayStart = Calendar.current.startOfDay(for: date)
        let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!

        return entries.filter { entry in
            entry.date >= dayStart && entry.date < dayEnd
        }
    }

    // MARK: - Actions

    func addEntry(date: Date, mealType: MealType, recipe: Recipe) {
        do {
            let entry = try service.addEntry(date: date, mealType: mealType, recipe: recipe)
            entries.append(entry)
        } catch {
            self.error = .saveFailed
        }
    }

    func removeEntry(_ entry: MealPlanEntry) {
        do {
            try service.removeEntry(entry)
            entries.removeAll { $0.id == entry.id }
        } catch {
            self.error = .deleteFailed
        }
    }
}
