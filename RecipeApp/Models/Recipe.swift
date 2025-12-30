import Foundation
import SwiftData

@Model
class Recipe {
    var id: UUID
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
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
    var imageURL: String?
    var dateAdded: Date
    var lastModified: Date
    var lastMade: Date?
    var isFavorite: Bool = false
    var summary: String?
    
    @Relationship(deleteRule: .cascade)
    var ingredients: [Ingredient]
    
    @Relationship(deleteRule: .cascade)
    var nutrition: NutritionInfo?
    
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
        // Fall back to either field if only one is set
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
    var unit: String? // cloves, cup, etc.
    var item: String // the ingredient
    var preparation: String? // minced, grated, etc
    var section: String? // group ingredients, e.g. for the sauce, etc.
    var order: Int = 0
    
    init(quantity: String, unit: String?, item: String, preparation: String?, section: String?) {
        self.id = UUID()
        self.quantity = quantity
        self.unit = unit
        self.item = item
        self.preparation = preparation
        self.section = section
    }
    
    var displayText: String {
        var parts: [String] = []
        
        if !quantity.isEmpty {
            parts.append(quantity)
        }
        
        if let unit = unit {
            parts.append(unit)
        }
        
        parts.append(item)
        
        if let preparation = preparation {
            parts.append("(\(preparation))")
        }
        
        return parts.joined(separator: " ")
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

    var displayItems: [(label: String, value: String)] {
        var items: [(String, String)] = []

        if let calories = calories {
            items.append(("Calories", "\(calories)"))
        }
        if let protein = protein {
            items.append(("Protein", formatGrams(protein)))
        }
        if let carbohydrates = carbohydrates {
            items.append(("Carbs", formatGrams(carbohydrates)))
        }
        if let fat = fat {
            items.append(("Fat", formatGrams(fat)))
        }
        if let fiber = fiber {
            items.append(("Fiber", formatGrams(fiber)))
        }
        if let sugar = sugar {
            items.append(("Sugar", formatGrams(sugar)))
        }
        if let sodium = sodium {
            items.append(("Sodium", formatMilligrams(sodium)))
        }

        return items
    }

    private func formatGrams(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? "\(Int(value))g"
            : String(format: "%.1fg", value)
    }

    private func formatMilligrams(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? "\(Int(value))mg"
            : String(format: "%.1fmg", value)
    }
}

enum SourceType: String, Codable {
    case manual
    case web_imported
    case ai_generated
}
