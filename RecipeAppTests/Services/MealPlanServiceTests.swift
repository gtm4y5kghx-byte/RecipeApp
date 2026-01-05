import Testing
import Foundation
import SwiftData
@testable import RecipeApp

@Suite("MealPlanService Tests")
@MainActor
struct MealPlanServiceTests {

    // MARK: - Add Entry

    @Test("addEntry creates new entry")
    func addEntry() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = MealPlanService(modelContext: context)
        let recipe = Recipe(title: "Pasta", sourceType: .manual)
        context.insert(recipe)

        let date = Date()
        let entry = try service.addEntry(date: date, mealType: .dinner, recipe: recipe)

        #expect(entry.date == date)
        #expect(entry.mealType == .dinner)
        #expect(entry.recipe === recipe)
    }

    @Test("addEntry allows multiple entries for same date and meal")
    func addEntryMultipleSameMeal() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = MealPlanService(modelContext: context)

        let recipe1 = Recipe(title: "Salad", sourceType: .manual)
        let recipe2 = Recipe(title: "Steak", sourceType: .manual)
        context.insert(recipe1)
        context.insert(recipe2)

        let date = Date()
        try service.addEntry(date: date, mealType: .dinner, recipe: recipe1)
        try service.addEntry(date: date, mealType: .dinner, recipe: recipe2)

        let entries = try service.entries(for: date...date)
        let dinnerEntries = entries.filter { $0.mealType == .dinner }

        #expect(dinnerEntries.count == 2)
    }

    // MARK: - Remove Entry

    @Test("removeEntry deletes entry")
    func removeEntry() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = MealPlanService(modelContext: context)
        let recipe = Recipe(title: "Pasta", sourceType: .manual)
        context.insert(recipe)

        let entry = try service.addEntry(date: Date(), mealType: .dinner, recipe: recipe)
        try service.removeEntry(entry)

        let entries = try service.allEntries()
        #expect(entries.isEmpty)
    }

    // MARK: - Query by Date Range

    @Test("entries(for:) returns entries in date range")
    func entriesForDateRange() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = MealPlanService(modelContext: context)
        let recipe = Recipe(title: "Pasta", sourceType: .manual)
        context.insert(recipe)

        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let dayAfter = Calendar.current.date(byAdding: .day, value: 2, to: today)!

        try service.addEntry(date: today, mealType: .breakfast, recipe: recipe)
        try service.addEntry(date: tomorrow, mealType: .lunch, recipe: recipe)
        try service.addEntry(date: dayAfter, mealType: .dinner, recipe: recipe)

        let entries = try service.entries(for: today...tomorrow)

        #expect(entries.count == 2)
    }

    @Test("entries(for:) excludes entries outside range")
    func entriesExcludesOutsideRange() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = MealPlanService(modelContext: context)
        let recipe = Recipe(title: "Pasta", sourceType: .manual)
        context.insert(recipe)

        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        try service.addEntry(date: yesterday, mealType: .breakfast, recipe: recipe)
        try service.addEntry(date: today, mealType: .lunch, recipe: recipe)
        try service.addEntry(date: tomorrow, mealType: .dinner, recipe: recipe)

        let entries = try service.entries(for: today...today)

        #expect(entries.count == 1)
        #expect(entries.first?.mealType == .lunch)
    }

    // MARK: - Clear Day

    @Test("clearDay removes all entries for date")
    func clearDay() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = MealPlanService(modelContext: context)
        let recipe = Recipe(title: "Pasta", sourceType: .manual)
        context.insert(recipe)

        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        try service.addEntry(date: today, mealType: .breakfast, recipe: recipe)
        try service.addEntry(date: today, mealType: .dinner, recipe: recipe)
        try service.addEntry(date: tomorrow, mealType: .lunch, recipe: recipe)

        try service.clearDay(today)

        let allEntries = try service.allEntries()
        #expect(allEntries.count == 1)
        #expect(allEntries.first?.mealType == .lunch)
    }

    // MARK: - Clear Date Range

    @Test("clearDateRange removes entries in range")
    func clearDateRange() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = MealPlanService(modelContext: context)
        let recipe = Recipe(title: "Pasta", sourceType: .manual)
        context.insert(recipe)

        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let dayAfter = Calendar.current.date(byAdding: .day, value: 2, to: today)!

        try service.addEntry(date: today, mealType: .breakfast, recipe: recipe)
        try service.addEntry(date: tomorrow, mealType: .lunch, recipe: recipe)
        try service.addEntry(date: dayAfter, mealType: .dinner, recipe: recipe)

        try service.clearDateRange(today...tomorrow)

        let allEntries = try service.allEntries()
        #expect(allEntries.count == 1)
        #expect(allEntries.first?.mealType == .dinner)
    }
}
