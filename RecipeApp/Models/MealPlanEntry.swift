import Foundation
import SwiftData

enum MealType: String, Codable, CaseIterable {
    case breakfast
    case lunch
    case dinner
}

@Model
class MealPlanEntry {
    var id: UUID
    var date: Date
    var mealType: MealType
    @Relationship(deleteRule: .nullify)
    var recipe: Recipe?
    var dateAdded: Date

    init(date: Date, mealType: MealType, recipe: Recipe) {
        self.id = UUID()
        self.date = date
        self.mealType = mealType
        self.recipe = recipe
        self.dateAdded = Date()
    }
}
