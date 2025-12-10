import Foundation
import EventKit

class ShoppingListService {
    private let eventStore: EKEventStore
    private let userDefaults: UserDefaults

    var targetListName: String {
        userDefaults.string(forKey: "shoppingListTargetName") ?? "RecipeApp Shopping List"
    }

    init(userDefaults: UserDefaults = .standard, eventStore: EKEventStore = EKEventStore()) {
        self.userDefaults = userDefaults
        self.eventStore = eventStore
    }

    func requestAccess() async -> Bool {
        do {
            if #available(iOS 17.0, *) {
                return try await eventStore.requestFullAccessToReminders()
            } else {
                return try await eventStore.requestAccess(to: .reminder)
            }
        } catch {
            return false
        }
    }

    func addIngredientsToList(from recipe: Recipe) async throws {
        guard await requestAccess() else {
            throw ShoppingListError.permissionDenied
        }

        let list = try getOrCreateList()

        for ingredient in recipe.sortedIngredients {
            let reminder = EKReminder(eventStore: eventStore)
            reminder.title = formatIngredient(ingredient)
            reminder.notes = "From: \(recipe.title)"
            reminder.calendar = list

            try eventStore.save(reminder, commit: false)
        }

        try eventStore.commit()
    }

    func getOrCreateList() throws -> EKCalendar {
        let calendars = eventStore.calendars(for: .reminder)

        if let existing = calendars.first(where: { $0.title == targetListName }) {
            return existing
        }

        let newList = EKCalendar(for: .reminder, eventStore: eventStore)
        newList.title = targetListName
        newList.source = eventStore.defaultCalendarForNewReminders()?.source
        try eventStore.saveCalendar(newList, commit: true)
        return newList
    }

    func getAvailableLists() -> [EKCalendar] {
        eventStore.calendars(for: .reminder)
    }

    private func formatIngredient(_ ingredient: Ingredient) -> String {
        var parts: [String] = []

        let quantity = ingredient.quantity.trimmingCharacters(in: .whitespaces)
        if !quantity.isEmpty {
            parts.append(quantity)
        }

        if let unit = ingredient.unit?.trimmingCharacters(in: .whitespaces), !unit.isEmpty {
            parts.append(unit)
        }

        parts.append(ingredient.item)

        return parts.joined(separator: " ")
    }
}
