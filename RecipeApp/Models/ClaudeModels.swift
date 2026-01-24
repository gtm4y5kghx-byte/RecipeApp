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

// MARK: - Unified Suggestion

/// Represents either a suggestion from the user's collection or an AI-generated recipe
enum UnifiedSuggestion: Identifiable {
    case fromCollection(RecipeSuggestion)
    case aiGenerated(GeneratedRecipe, reason: String)

    var id: UUID {
        switch self {
        case .fromCollection(let suggestion):
            return suggestion.id
        case .aiGenerated(let recipe, _):
            return recipe.id
        }
    }

    var reason: String {
        switch self {
        case .fromCollection(let suggestion):
            return suggestion.aiGeneratedReason
        case .aiGenerated(_, let reason):
            return reason
        }
    }

    /// Returns the recipe ID for collection suggestions, nil for AI-generated
    var recipeID: UUID? {
        switch self {
        case .fromCollection(let suggestion):
            return suggestion.recipeID
        case .aiGenerated:
            return nil
        }
    }

    /// Returns the generated recipe for AI-generated suggestions, nil for collection
    var generatedRecipe: GeneratedRecipe? {
        switch self {
        case .fromCollection:
            return nil
        case .aiGenerated(let recipe, _):
            return recipe
        }
    }

    var isAIGenerated: Bool {
        if case .aiGenerated = self { return true }
        return false
    }
}

// MARK: - Recipe Generation

struct GeneratedIngredient: Codable, Equatable {
    let quantity: String
    let unit: String?
    let item: String
    let preparation: String?
}

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
    let ingredients: [GeneratedIngredient]
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
        self.ingredients = try container.decode([GeneratedIngredient].self, forKey: .ingredients)
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

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        ingredients: [GeneratedIngredient] = [],
        instructions: [String] = [],
        prepTime: Int? = nil,
        cookTime: Int? = nil,
        servings: Int? = nil,
        cuisine: String? = nil,
        tags: [String] = [],
        nutrition: GeneratedNutrition? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.ingredients = ingredients
        self.instructions = instructions
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.servings = servings
        self.cuisine = cuisine
        self.tags = tags
        self.nutrition = nutrition
    }

    func toRecipe() -> Recipe {
          let recipe = Recipe(title: title, sourceType: .ai_generated)

          recipe.summary = description
          recipe.prepTime = prepTime
          recipe.cookTime = cookTime
          recipe.servings = servings
          recipe.cuisine = cuisine
          recipe.userTags = tags

          for (index, generatedIngredient) in ingredients.enumerated() {
              let ingredient = Ingredient(
                  quantity: generatedIngredient.quantity,
                  unit: generatedIngredient.unit,
                  item: generatedIngredient.item,
                  preparation: generatedIngredient.preparation,
                  section: nil
              )
              ingredient.order = index
              recipe.ingredients.append(ingredient)
          }

          for (index, instruction) in instructions.enumerated() {
              let step = Step(instruction: instruction)
              step.order = index
              recipe.instructions.append(step)
          }

          if let n = nutrition {
              recipe.nutrition = NutritionInfo(
                  calories: n.calories,
                  carbohydrates: n.carbohydrates,
                  protein: n.protein,
                  fat: n.fat,
                  fiber: n.fiber,
                  sodium: n.sodium,
                  sugar: n.sugar
              )
          }

          return recipe
      }
}

