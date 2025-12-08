import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
class RecipeTransformationViewModel {
    var transformationPrompt: String = ""
    var isProcessing: Bool = false
    var error: Error?

    private let recipe: Recipe
    private let modelContext: ModelContext
    private let service: ClaudeRecipeTransformationService

    init(recipe: Recipe, modelContext: ModelContext, service: ClaudeRecipeTransformationService? = nil) {
        self.recipe = recipe
        self.modelContext = modelContext
        self.service = service ?? ClaudeRecipeTransformationService()
    }

    func transformRecipe() async -> Bool {
        isProcessing = true

        do {
            let transformation = try await service.transformRecipe(recipe: recipe, transformation: transformationPrompt)
            try createVariation(from: transformation)
            isProcessing = false
            return true
        } catch {
            self.error = error
            isProcessing = false
            return false
        }
    }

    private func createVariation(from transformation: RecipeTransformation) throws {
        let variation = Recipe(title: transformation.title, sourceType: recipe.sourceType)

        variation.parentRecipeID = recipe.id
        variation.variationNote = transformation.variationNote

        variation.servings = transformation.servings
        variation.prepTime = transformation.prepTime
        variation.cookTime = transformation.cookTime
        variation.cuisine = transformation.cuisine
        variation.notes = transformation.notes

        variation.ingredients = transformation.ingredients.enumerated().map { index, transformedIngredient in
            let ingredient = Ingredient(
                quantity: "",
                unit: nil,
                item: transformedIngredient.text,
                preparation: nil,
                section: nil
            )
            ingredient.order = index
            return ingredient
        }

        variation.instructions = transformation.instructions.enumerated().map { index, transformedInstruction in
            let step = Step(instruction: transformedInstruction.text)
            step.order = index
            return step
        }

        modelContext.insert(variation)

        try modelContext.save()
    }
}
