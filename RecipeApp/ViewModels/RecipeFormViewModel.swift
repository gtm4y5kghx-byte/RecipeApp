import Foundation
import SwiftUI

@MainActor
@Observable
class RecipeFormViewModel {
    private let recipe: Recipe?
    private let title: String
    private let ingredientFields: [String]
    private let instructionFields: [String]
    private let servings: String
    private let prepTime: String
    private let cookTime: String
    private let cuisine: String
    private let notes: String

    init(
        recipe: Recipe?,
        title: String,
        ingredientFields: [String],
        instructionFields: [String],
        servings: String,
        prepTime: String,
        cookTime: String,
        cuisine: String,
        notes: String
    ) {
        self.recipe = recipe
        self.title = title
        self.ingredientFields = ingredientFields
        self.instructionFields = instructionFields
        self.servings = servings
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.cuisine = cuisine
        self.notes = notes
    }

    var formHasChanges: Bool {
        if recipe == nil {
            return !title.isEmpty ||
            ingredientFields.contains(where: { !$0.isEmpty }) ||
            instructionFields.contains(where: { !$0.isEmpty }) ||
            !servings.isEmpty || !prepTime.isEmpty || !cookTime.isEmpty || !cuisine.isEmpty || !notes.isEmpty
        }

        guard let recipe = recipe else { return false }

        let ingredientsChanged = ingredientFields != recipe.sortedIngredients.map { $0.item }
        let instructionsChanged = instructionFields != recipe.sortedInstructions.map { $0.instruction }

        return title != recipe.title ||
        servings != (recipe.servings.map { String($0) } ?? "") ||
        prepTime != (recipe.prepTime.map { String($0) } ?? "") ||
        cookTime != (recipe.cookTime.map { String($0) } ?? "") ||
        cuisine != (recipe.cuisine ?? "") ||
        notes != (recipe.notes ?? "") ||
        ingredientsChanged ||
        instructionsChanged
    }

    func getTagSuggestions(tagInput: String, allRecipes: [Recipe]) -> [(String, Int)] {
        let currentTag = tagInput
            .split(separator: ",")
            .last?
            .trimmingCharacters(in: .whitespaces)
            .lowercased() ?? ""

        guard !currentTag.isEmpty else { return [] }

        let allTags = allRecipes.flatMap { $0.userTags }
        let tagCounts = Dictionary(grouping: allTags, by: { $0.lowercased() })
            .mapValues { $0.count }

        let filtered = tagCounts.filter { tag, _ in
            tag.contains(currentTag) && tag != currentTag
        }

        return filtered
            .map { ($0.key, $0.value) }
            .sorted { $0.1 > $1.1 }
    }
}
