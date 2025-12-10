import Foundation
import SwiftData

@Model
class Recipe {
    var id: UUID
    var title: String
    var sourceType: SourceType
    var servings: Int?
    var prepTime: Int?
    var cookTime: Int?
    var cuisine: String?
    var timesCooked: Int = 0
    var userTags: [String] = []
    var notes: String?
    var sourceURL: String?
    var dateAdded: Date
    var lastModified: Date
    var lastMade: Date?
    var isFavorite: Bool = false
    var parentRecipeID: UUID?
    var variationNote: String?
    
    @Relationship(deleteRule: .cascade)
    var ingredients: [Ingredient]
    
    @Relationship(deleteRule: .cascade)
    var nutrition: NutritionInfo?
    
    var variations: [Recipe] {
        return []
    }
    
    @Relationship(deleteRule: .cascade)
    var instructions: [Step]
    
    init(title: String, sourceType: SourceType) {
        self.id = UUID()
        self.title = title
        self.sourceType = sourceType
        self.dateAdded = Date()
        self.lastModified = Date()
        self.ingredients = []
        self.instructions = []
    }
    
    var totalTime: Int? {
        // Try combined time first
        if let prep = prepTime, let cook = cookTime {
            return prep + cook
        }
        // Fall back to either field if only one is set (e.g., Spoonacular recipes)
        return prepTime ?? cookTime
    }

    var canStartCooking: Bool {
        !ingredients.isEmpty && !instructions.isEmpty
    }
}

@Model
class Ingredient {
    var id: UUID
    var quantity: String
    var unit: String?
    var item: String
    var preparation: String?
    var section: String?
    var order: Int = 0
    
    init(quantity: String, unit: String?, item: String, preparation: String?, section: String?) {
        self.id = UUID()
        self.quantity = quantity
        self.unit = unit
        self.item = item
        self.preparation = preparation
        self.section = section
    }
}

@Model
class Step {
    var id: UUID
    var order: Int = 0
    var instruction: String
    var timerDuration: Int?
    
    init(instruction: String, timerDuration: Int? = nil) {
        self.id = UUID()
        self.instruction = instruction
        self.timerDuration = timerDuration
    }
}

@Model
class NutritionInfo {
    var id: UUID
    var calories: Int?           // per serving
    var carbohydrates: Double?   // grams
    var protein: Double?         // grams
    var fat: Double?             // grams
    var fiber: Double?           // grams
    var sodium: Double?          // milligrams
    var sugar: Double?           // grams
    
    init(calories: Int? = nil, carbohydrates: Double? = nil,
         protein: Double? = nil, fat: Double? = nil,
         fiber: Double? = nil, sodium: Double? = nil,
         sugar: Double? = nil) {
        self.id = UUID()
        self.calories = calories
        self.carbohydrates = carbohydrates
        self.protein = protein
        self.fat = fat
        self.fiber = fiber
        self.sodium = sodium
        self.sugar = sugar
    }
}

enum SourceType: String, Codable {
    case manual
    case web_imported
}
