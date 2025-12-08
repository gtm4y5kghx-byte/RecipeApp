import Foundation
@testable import RecipeApp

@MainActor
class MockRecipeTransformationService: ClaudeRecipeTransformationService {
    var shouldThrowError = false
    var thrownError: Error = NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock transformation error"])
    var mockTransformation: RecipeTransformation?

    var capturedRecipe: Recipe?
    var capturedTransformationPrompt: String?
    var transformRecipeCallCount = 0

    override func transformRecipe(recipe: Recipe, transformation: String) async throws -> RecipeTransformation {
        transformRecipeCallCount += 1
        capturedRecipe = recipe
        capturedTransformationPrompt = transformation

        if shouldThrowError {
            throw thrownError
        }

        guard let mockTransformation = mockTransformation else {
            return createDefaultMockTransformation()
        }

        return mockTransformation
    }

    private func createDefaultMockTransformation() -> RecipeTransformation {
        return RecipeTransformation(
            title: "Transformed Recipe",
            variationNote: "Made vegan",
            notes: "Test notes",
            prepTime: 15,
            cookTime: 30,
            servings: 4,
            cuisine: "Italian",
            ingredients: [
                TransformedIngredient(text: "2 cups flour", changeNote: nil),
                TransformedIngredient(text: "1 cup plant milk", changeNote: "Replaced dairy milk")
            ],
            instructions: [
                TransformedInstruction(text: "Mix ingredients", changeNote: nil),
                TransformedInstruction(text: "Bake at 350F", changeNote: "Reduced temp for plant-based version")
            ]
        )
    }
}
