import Testing
import Foundation
@testable import RecipeApp

@Suite("Claude Recipe Transformation Tests")
@MainActor
struct RecipeTransformationServiceTests {

    private let service = ClaudeRecipeTransformationService()

    @Test("Transform recipe to vegan version")
    func testVeganTransformation() async throws {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Scrambled Eggs",
            ingredients: [("3", nil, "eggs"), ("1 tbsp", nil, "butter"), ("", nil, "salt")],
            instructions: ["Beat eggs", "Melt butter in pan", "Cook eggs until set"]
        )

        let result = try await service.transformRecipe(recipe: recipe, transformation: "Make this recipe vegan")

        print("\n========== VEGAN TRANSFORMATION ==========")
        print("Original: \(recipe.title)")
        print("Transformed: \(result.title)")
        print("\nVariation Note: \(result.variationNote)")
        print("\nIngredients:")
        for ingredient in result.ingredients {
            print("  - \(ingredient.text)")
            if let note = ingredient.changeNote {
                print("    Note: \(note)")
            }
        }
        print("\nInstructions:")
        for (index, instruction) in result.instructions.enumerated() {
            print("  \(index + 1). \(instruction.text)")
            if let note = instruction.changeNote {
                print("     Note: \(note)")
            }
        }
        print("==========================================\n")
    }

    @Test("Double recipe quantities")
    func testDoubleRecipe() async throws {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Chocolate Chip Cookies",
            servings: 12,
            ingredients: [
                ("2 cups", nil, "all-purpose flour"),
                ("1 cup", nil, "sugar")
            ],
            instructions: ["Mix ingredients", "Bake at 350F for 12 minutes"]
        )

        let result = try await service.transformRecipe(recipe: recipe, transformation: "Double the recipe")

        print("\n========== DOUBLE RECIPE ==========")
        print("Original: \(recipe.title) (Servings: \(recipe.servings ?? 0))")
        print("Transformed: \(result.title) (Servings: \(result.servings ?? 0))")
        print("\nVariation Note: \(result.variationNote)")
        print("\nIngredients:")
        for ingredient in result.ingredients {
            print("  - \(ingredient.text)")
        }
        print("==========================================\n")
    }

    @Test("Air fryer conversion")
    func testAirFryerConversion() async throws {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Fried Chicken",
            cookTime: 20,
            ingredients: [
                ("1 lb", nil, "chicken"),
                ("2 cups", nil, "oil for frying")
            ],
            instructions: ["Heat oil to 350F", "Fry chicken 15 minutes"]
        )

        let result = try await service.transformRecipe(recipe: recipe, transformation: "Convert to air fryer")

        print("\n========== AIR FRYER CONVERSION ==========")
        print("Original: \(recipe.title) (Cook Time: \(recipe.cookTime ?? 0) min)")
        print("Transformed: \(result.title) (Cook Time: \(result.cookTime ?? 0) min)")
        print("\nVariation Note: \(result.variationNote)")
        print("\nIngredients:")
        for ingredient in result.ingredients {
            print("  - \(ingredient.text)")
            if let note = ingredient.changeNote {
                print("    Note: \(note)")
            }
        }
        print("\nInstructions:")
        for (index, instruction) in result.instructions.enumerated() {
            print("  \(index + 1). \(instruction.text)")
            if let note = instruction.changeNote {
                print("     Note: \(note)")
            }
        }
        print("==========================================\n")
    }

    @Test("Gluten-free conversion")
    func testGlutenFreeConversion() async throws {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Chocolate Cake",
            ingredients: [
                ("2 cups", nil, "all-purpose flour"),
                ("1 cup", nil, "sugar"),
                ("1/2 cup", nil, "cocoa powder")
            ],
            instructions: ["Mix dry ingredients", "Add wet ingredients", "Bake at 350F for 30 minutes"]
        )

        let result = try await service.transformRecipe(recipe: recipe, transformation: "Make this gluten-free")

        print("\n========== GLUTEN-FREE CONVERSION ==========")
        print("Original: \(recipe.title)")
        print("Transformed: \(result.title)")
        print("\nVariation Note: \(result.variationNote)")
        print("\nIngredients:")
        for ingredient in result.ingredients {
            print("  - \(ingredient.text)")
            if let note = ingredient.changeNote {
                print("    Note: \(note)")
            }
        }
        print("==========================================\n")
    }
}
