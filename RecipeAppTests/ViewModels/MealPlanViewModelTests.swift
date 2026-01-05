import Testing
import Foundation
import SwiftData
@testable import RecipeApp

@Suite("MealPlanViewModel Tests")
@MainActor
struct MealPlanViewModelTests {

    // MARK: - Initial State

    @Test("Initial state has empty entries")
    func initialStateEmpty() throws {
        let viewModel = try createViewModel()
        #expect(viewModel.entries.isEmpty)
    }

    @Test("Initial state has no error")
    func initialStateNoError() throws {
        let viewModel = try createViewModel()
        let error: MealPlanError? = viewModel.error
        #expect(error == nil)
    }

    // MARK: - Load Entries

    @Test("loadEntries fetches entries from service")
    func loadEntries() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = MealPlanService(modelContext: context)

        let recipe = Recipe(title: "Pasta", sourceType: .manual)
        context.insert(recipe)
        try service.addEntry(date: Date(), mealType: .dinner, recipe: recipe)

        let viewModel = try createViewModel(context: context)
        viewModel.loadEntries()

        #expect(viewModel.entries.count == 1)
    }

    // MARK: - Entries for Date

    @Test("entries(for:) returns entries matching date")
    func entriesForDate() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = MealPlanService(modelContext: context)

        let recipe = Recipe(title: "Pasta", sourceType: .manual)
        context.insert(recipe)

        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        try service.addEntry(date: today, mealType: .breakfast, recipe: recipe)
        try service.addEntry(date: today, mealType: .dinner, recipe: recipe)
        try service.addEntry(date: tomorrow, mealType: .lunch, recipe: recipe)

        let viewModel = try createViewModel(context: context)
        viewModel.loadEntries()

        let todayEntries = viewModel.entries(for: today)
        #expect(todayEntries.count == 2)

        let tomorrowEntries = viewModel.entries(for: tomorrow)
        #expect(tomorrowEntries.count == 1)
    }

    @Test("entries(for:) returns empty array when no entries for date")
    func entriesForDateEmpty() throws {
        let viewModel = try createViewModel()
        viewModel.loadEntries()

        let entries = viewModel.entries(for: Date())
        #expect(entries.isEmpty)
    }

    // MARK: - Add Entry

    @Test("addEntry creates new entry")
    func addEntry() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let recipe = Recipe(title: "Pasta", sourceType: .manual)
        context.insert(recipe)

        let viewModel = try createViewModel(context: context)
        viewModel.addEntry(date: Date(), mealType: .dinner, recipe: recipe)

        #expect(viewModel.entries.count == 1)
        #expect(viewModel.entries.first?.mealType == .dinner)
    }

    @Test("addEntry allows multiple entries for same meal")
    func addEntryMultiple() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let recipe1 = Recipe(title: "Salad", sourceType: .manual)
        let recipe2 = Recipe(title: "Steak", sourceType: .manual)
        context.insert(recipe1)
        context.insert(recipe2)

        let viewModel = try createViewModel(context: context)
        let today = Date()

        viewModel.addEntry(date: today, mealType: .dinner, recipe: recipe1)
        viewModel.addEntry(date: today, mealType: .dinner, recipe: recipe2)

        #expect(viewModel.entries.count == 2)
    }

    // MARK: - Remove Entry

    @Test("removeEntry deletes entry")
    func removeEntry() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let recipe = Recipe(title: "Pasta", sourceType: .manual)
        context.insert(recipe)

        let viewModel = try createViewModel(context: context)
        viewModel.addEntry(date: Date(), mealType: .dinner, recipe: recipe)

        let entry = viewModel.entries.first!
        viewModel.removeEntry(entry)

        #expect(viewModel.entries.isEmpty)
    }

    // MARK: - Helpers

    private func createViewModel(context: ModelContext? = nil) throws -> MealPlanViewModel {
        let ctx = context ?? RecipeTestFixtures.createInMemoryModelContext()
        return MealPlanViewModel(modelContext: ctx)
    }
}
