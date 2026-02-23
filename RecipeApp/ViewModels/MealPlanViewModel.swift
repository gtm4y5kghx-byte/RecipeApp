import Foundation
import SwiftData

@MainActor
@Observable
class MealPlanViewModel {
    private let service: MealPlanService

    var entries: [MealPlanEntry] = []
    var error: MealPlanError?

    let dateRange: [Date]
    let today: Date

    init(modelContext: ModelContext) {
        self.service = MealPlanService(modelContext: modelContext)

        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let end = calendar.date(from: DateComponents(year: year, month: 12, day: 31))!

        var dates: [Date] = []
        var current = start
        while current <= end {
            dates.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        self.dateRange = dates
        self.today = calendar.startOfDay(for: Date())
    }

    // MARK: - Update Entries

    func updateEntries(_ newEntries: [MealPlanEntry]) {
        entries = newEntries
    }

    // MARK: - Query

    func entries(for date: Date) -> [MealPlanEntry] {
        let dayStart = Calendar.current.startOfDay(for: date)
        let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!

        return entries.filter { entry in
            entry.date >= dayStart && entry.date < dayEnd && entry.recipe != nil
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
