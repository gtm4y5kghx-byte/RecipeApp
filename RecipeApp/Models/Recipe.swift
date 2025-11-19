import Foundation
import SwiftData

@Model
class Recipe {
    var id: UUID
    var title: String
    var sourceType: SourceType
    var originalAudio: Data?
    var servings: Int?
    var prepTime: Int?
    var cookTime: Int?
    var totalTime: Int?
    var cuisine: String?
    var timesCooked: Int = 0
    var userTags: [String] = []
    var notes: String?
    var dateAdded: Date
    var lastModified: Date
    var lastMade: Date?
    var rating: Int?
    var isFavorite: Bool = false
    
    @Relationship(deleteRule: .cascade)
    var ingredients: [Ingredient]
    
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

enum SourceType: String, Codable {
    case manual
    case voice_created
}
