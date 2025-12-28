import Foundation

struct RecipeSearchCriteria: Codable {
    let cuisine: String?
    let maxTotalTime: Int?
    let favoritesOnly: Bool
    let onlyNeverCooked: Bool
    let onlyCookedLongAgo: Bool
    let onlyCookedRecently: Bool
    
    let titleKeywords: [String]
    let ingredientKeywords: [String]
    let notesKeywords: [String]
    
    let combineMode: String  // "and" or "or"
}

struct RecipeSuggestion: Codable, Identifiable {
    let id: UUID
    let recipeID: UUID
    let aiGeneratedReason: String
    let generatedAt: Date
    
    init(recipeID: UUID, aiGeneratedReason: String) {
        self.id = UUID()
        self.recipeID = recipeID
        self.aiGeneratedReason = aiGeneratedReason
        self.generatedAt = Date()
    }
}

struct SuggestionCache: Codable {
    let suggestions: [RecipeSuggestion]
    let generatedAt: Date

    // Check if cache is stale (> 7 days old)
    var isStale: Bool {
        let daysSinceGeneration = Date().daysSince(generatedAt)
        return daysSinceGeneration >= 7
    }
}

// MARK: - Recipe Generation

struct GeneratedNutrition: Codable, Equatable {
    let calories: Int?
    let carbohydrates: Double?
    let protein: Double?
    let fat: Double?
    let fiber: Double?
    let sodium: Double?
    let sugar: Double?
}

struct GeneratedRecipe: Codable, Identifiable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let ingredients: [String]
    let instructions: [String]
    let prepTime: Int?
    let cookTime: Int?
    let servings: Int?
    let cuisine: String?
    let tags: [String]
    let nutrition: GeneratedNutrition?

    var totalTime: Int? {
        guard let prep = prepTime, let cook = cookTime else {
            return prepTime ?? cookTime
        }
        return prep + cook
    }

    private enum CodingKeys: String, CodingKey {
        case title, description, ingredients, instructions
        case prepTime, cookTime, servings, cuisine, tags, nutrition
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.ingredients = try container.decode([String].self, forKey: .ingredients)
        self.instructions = try container.decode([String].self, forKey: .instructions)
        self.prepTime = try container.decodeIfPresent(Int.self, forKey: .prepTime)
        self.cookTime = try container.decodeIfPresent(Int.self, forKey: .cookTime)
        self.servings = try container.decodeIfPresent(Int.self, forKey: .servings)
        self.cuisine = try container.decodeIfPresent(String.self, forKey: .cuisine)
        self.tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        self.nutrition = try container.decodeIfPresent(GeneratedNutrition.self, forKey: .nutrition)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(ingredients, forKey: .ingredients)
        try container.encode(instructions, forKey: .instructions)
        try container.encodeIfPresent(prepTime, forKey: .prepTime)
        try container.encodeIfPresent(cookTime, forKey: .cookTime)
        try container.encodeIfPresent(servings, forKey: .servings)
        try container.encodeIfPresent(cuisine, forKey: .cuisine)
        try container.encode(tags, forKey: .tags)
        try container.encodeIfPresent(nutrition, forKey: .nutrition)
    }
}

struct GeneratedRecipeCache: Codable {
    let recipes: [GeneratedRecipe]
    let generatedAt: Date

    var isStale: Bool {
        let daysSinceGeneration = Date().daysSince(generatedAt)
        return daysSinceGeneration >= 7
    }
}
