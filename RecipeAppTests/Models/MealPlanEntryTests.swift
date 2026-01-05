import Testing
import Foundation
import SwiftData
@testable import RecipeApp

@Suite("MealPlanEntry Tests")
@MainActor
struct MealPlanEntryTests {

    // MARK: - Initialization

    @Test("Initializes with required properties")
    func initWithProperties() {
        let date = Date()
        let recipe = Recipe(title: "Test Recipe", sourceType: .manual)

        let entry = MealPlanEntry(date: date, mealType: .dinner, recipe: recipe)

        #expect(entry.date == date)
        #expect(entry.mealType == .dinner)
        #expect(entry.recipe === recipe)
        #expect(entry.dateAdded <= Date())
    }

    @Test("Each instance gets unique ID")
    func uniqueIDs() {
        let recipe = Recipe(title: "Test", sourceType: .manual)
        let entry1 = MealPlanEntry(date: Date(), mealType: .lunch, recipe: recipe)
        let entry2 = MealPlanEntry(date: Date(), mealType: .lunch, recipe: recipe)

        #expect(entry1.id != entry2.id)
    }

    // MARK: - MealType

    @Test("MealType has all expected cases")
    func mealTypeCases() {
        let cases = MealType.allCases

        #expect(cases.count == 3)
        #expect(cases.contains(.breakfast))
        #expect(cases.contains(.lunch))
        #expect(cases.contains(.dinner))
    }

    @Test("MealType raw values are correct")
    func mealTypeRawValues() {
        #expect(MealType.breakfast.rawValue == "breakfast")
        #expect(MealType.lunch.rawValue == "lunch")
        #expect(MealType.dinner.rawValue == "dinner")
    }
}
