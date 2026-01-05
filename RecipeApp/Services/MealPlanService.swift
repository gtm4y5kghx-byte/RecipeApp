import Foundation
import SwiftData

@MainActor
class MealPlanService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    @discardableResult
    func addEntry(date: Date, mealType: MealType, recipe: Recipe) throws -> MealPlanEntry {
        let entry = MealPlanEntry(date: date, mealType: mealType, recipe: recipe)
        modelContext.insert(entry)
        try modelContext.save()
        return entry
    }

    func removeEntry(_ entry: MealPlanEntry) throws {
        modelContext.delete(entry)
        try modelContext.save()
    }

    func entries(for dateRange: ClosedRange<Date>) throws -> [MealPlanEntry] {
        let startOfRange = Calendar.current.startOfDay(for: dateRange.lowerBound)
        let endOfRange = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: dateRange.upperBound))!

        let descriptor = FetchDescriptor<MealPlanEntry>(
            predicate: #Predicate { entry in
                entry.date >= startOfRange && entry.date < endOfRange
            },
            sortBy: [SortDescriptor(\.date)]
        )
        return try modelContext.fetch(descriptor)
    }

    func allEntries() throws -> [MealPlanEntry] {
        let descriptor = FetchDescriptor<MealPlanEntry>(sortBy: [SortDescriptor(\.date)])
        return try modelContext.fetch(descriptor)
    }

    func clearDay(_ date: Date) throws {
        let dayStart = Calendar.current.startOfDay(for: date)
        let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!

        let descriptor = FetchDescriptor<MealPlanEntry>(
            predicate: #Predicate { entry in
                entry.date >= dayStart && entry.date < dayEnd
            }
        )
        let entries = try modelContext.fetch(descriptor)

        for entry in entries {
            modelContext.delete(entry)
        }
        try modelContext.save()
    }

    func clearDateRange(_ dateRange: ClosedRange<Date>) throws {
        let entries = try entries(for: dateRange)

        for entry in entries {
            modelContext.delete(entry)
        }
        try modelContext.save()
    }
}
