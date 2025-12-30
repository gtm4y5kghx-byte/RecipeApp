import Testing
import Foundation
@testable import RecipeApp

@Suite("GeneratedRecipe Tests")
@MainActor
struct GeneratedRecipeTests {

    // MARK: - JSON Decoding Tests

    @Test("Decodes valid JSON with all fields")
    func decodeFullJSON() throws {
        let json = """
        {
            "title": "Pasta Carbonara",
            "description": "A creamy Italian pasta dish",
            "ingredients": [
                {"quantity": "1 lb", "unit": "pounds", "item": "spaghetti", "preparation": null},
                {"quantity": "4", "unit": null, "item": "eggs", "preparation": "beaten"}
            ],
            "instructions": ["Boil pasta", "Mix eggs", "Combine"],
            "prepTime": 15,
            "cookTime": 20,
            "servings": 4,
            "cuisine": "Italian",
            "tags": ["quick", "comfort food"],
            "nutrition": {
                "calories": 650,
                "carbohydrates": 75.0,
                "protein": 25.0,
                "fat": 28.0,
                "fiber": 3.0,
                "sodium": 800.0,
                "sugar": 2.0
            }
        }
        """

        let data = json.data(using: .utf8)!
        let recipe = try JSONDecoder().decode(GeneratedRecipe.self, from: data)

        #expect(recipe.title == "Pasta Carbonara")
        #expect(recipe.description == "A creamy Italian pasta dish")
        #expect(recipe.ingredients.count == 2)
        #expect(recipe.instructions.count == 3)
        #expect(recipe.prepTime == 15)
        #expect(recipe.cookTime == 20)
        #expect(recipe.servings == 4)
        #expect(recipe.cuisine == "Italian")
        #expect(recipe.tags == ["quick", "comfort food"])
        #expect(recipe.nutrition?.calories == 650)
        #expect(recipe.nutrition?.protein == 25.0)
    }

    @Test("Decodes JSON with optional fields missing")
    func decodeMinimalJSON() throws {
        let json = """
        {
            "title": "Simple Salad",
            "description": "A quick salad",
            "ingredients": [
                {"quantity": "1 head", "unit": null, "item": "lettuce", "preparation": null}
            ],
            "instructions": ["Chop lettuce", "Serve"]
        }
        """

        let data = json.data(using: .utf8)!
        let recipe = try JSONDecoder().decode(GeneratedRecipe.self, from: data)

        #expect(recipe.title == "Simple Salad")
        #expect(recipe.prepTime == nil)
        #expect(recipe.cookTime == nil)
        #expect(recipe.servings == nil)
        #expect(recipe.cuisine == nil)
        #expect(recipe.tags.isEmpty)
        #expect(recipe.nutrition == nil)
    }

    @Test("Generates unique UUID on each decode")
    func uniqueUUIDOnDecode() throws {
        let json = """
        {
            "title": "Test Recipe",
            "description": "Test",
            "ingredients": [],
            "instructions": ["Step 1"]
        }
        """

        let data = json.data(using: .utf8)!
        let recipe1 = try JSONDecoder().decode(GeneratedRecipe.self, from: data)
        let recipe2 = try JSONDecoder().decode(GeneratedRecipe.self, from: data)

        #expect(recipe1.id != recipe2.id)
    }

    // MARK: - totalTime Tests

    @Test("totalTime returns sum when both prep and cook present")
    func totalTimeWithBoth() throws {
        let recipe = try decodeRecipe(prepTime: 15, cookTime: 30)
        #expect(recipe.totalTime == 45)
    }

    @Test("totalTime returns prepTime when only prep present")
    func totalTimeWithOnlyPrep() throws {
        let recipe = try decodeRecipe(prepTime: 15, cookTime: nil)
        #expect(recipe.totalTime == 15)
    }

    @Test("totalTime returns cookTime when only cook present")
    func totalTimeWithOnlyCook() throws {
        let recipe = try decodeRecipe(prepTime: nil, cookTime: 30)
        #expect(recipe.totalTime == 30)
    }

    @Test("totalTime returns nil when neither present")
    func totalTimeWithNeither() throws {
        let recipe = try decodeRecipe(prepTime: nil, cookTime: nil)
        #expect(recipe.totalTime == nil)
    }

    // MARK: - toRecipe() Conversion Tests

    @Test("toRecipe sets sourceType to ai_generated")
    func toRecipeSourceType() throws {
        let generatedRecipe = try decodeFullRecipe()
        let recipe = generatedRecipe.toRecipe()

        #expect(recipe.sourceType == .ai_generated)
    }

    @Test("toRecipe maps basic fields correctly")
    func toRecipeBasicFields() throws {
        let generatedRecipe = try decodeFullRecipe()
        let recipe = generatedRecipe.toRecipe()

        #expect(recipe.title == "Pasta Carbonara")
        #expect(recipe.summary == "A creamy Italian pasta dish")
        #expect(recipe.prepTime == 15)
        #expect(recipe.cookTime == 20)
        #expect(recipe.servings == 4)
        #expect(recipe.cuisine == "Italian")
        #expect(recipe.userTags == ["quick", "comfort food"])
    }

    @Test("toRecipe converts ingredients with correct order")
    func toRecipeIngredients() throws {
        let generatedRecipe = try decodeFullRecipe()
        let recipe = generatedRecipe.toRecipe()

        #expect(recipe.ingredients.count == 2)

        let first = recipe.ingredients.first { $0.order == 0 }
        #expect(first?.quantity == "1 lb")
        #expect(first?.unit == "pounds")
        #expect(first?.item == "spaghetti")
        #expect(first?.preparation == nil)

        let second = recipe.ingredients.first { $0.order == 1 }
        #expect(second?.quantity == "4")
        #expect(second?.unit == nil)
        #expect(second?.item == "eggs")
        #expect(second?.preparation == "beaten")
    }

    @Test("toRecipe converts instructions with correct order")
    func toRecipeInstructions() throws {
        let generatedRecipe = try decodeFullRecipe()
        let recipe = generatedRecipe.toRecipe()

        #expect(recipe.instructions.count == 3)

        let steps = recipe.instructions.sorted { $0.order < $1.order }
        #expect(steps[0].instruction == "Boil pasta")
        #expect(steps[0].order == 0)
        #expect(steps[1].instruction == "Mix eggs")
        #expect(steps[1].order == 1)
        #expect(steps[2].instruction == "Combine")
        #expect(steps[2].order == 2)
    }

    @Test("toRecipe converts nutrition when present")
    func toRecipeWithNutrition() throws {
        let generatedRecipe = try decodeFullRecipe()
        let recipe = generatedRecipe.toRecipe()

        #expect(recipe.nutrition != nil)
        #expect(recipe.nutrition?.calories == 650)
        #expect(recipe.nutrition?.carbohydrates == 75.0)
        #expect(recipe.nutrition?.protein == 25.0)
        #expect(recipe.nutrition?.fat == 28.0)
        #expect(recipe.nutrition?.fiber == 3.0)
        #expect(recipe.nutrition?.sodium == 800.0)
        #expect(recipe.nutrition?.sugar == 2.0)
    }

    @Test("toRecipe returns nil nutrition when not present")
    func toRecipeWithoutNutrition() throws {
        let json = """
        {
            "title": "Simple Recipe",
            "description": "No nutrition info",
            "ingredients": [],
            "instructions": ["Step 1"]
        }
        """

        let data = json.data(using: .utf8)!
        let generatedRecipe = try JSONDecoder().decode(GeneratedRecipe.self, from: data)
        let recipe = generatedRecipe.toRecipe()

        #expect(recipe.nutrition == nil)
    }

    // MARK: - GeneratedIngredient Tests

    @Test("GeneratedIngredient decodes all fields")
    func ingredientDecoding() throws {
        let json = """
        {"quantity": "2 cups", "unit": "cups", "item": "flour", "preparation": "sifted"}
        """

        let data = json.data(using: .utf8)!
        let ingredient = try JSONDecoder().decode(GeneratedIngredient.self, from: data)

        #expect(ingredient.quantity == "2 cups")
        #expect(ingredient.unit == "cups")
        #expect(ingredient.item == "flour")
        #expect(ingredient.preparation == "sifted")
    }

    @Test("GeneratedIngredient equality")
    func ingredientEquality() {
        let ingredient1 = GeneratedIngredient(quantity: "1 cup", unit: "cups", item: "sugar", preparation: nil)
        let ingredient2 = GeneratedIngredient(quantity: "1 cup", unit: "cups", item: "sugar", preparation: nil)
        let ingredient3 = GeneratedIngredient(quantity: "2 cups", unit: "cups", item: "sugar", preparation: nil)

        #expect(ingredient1 == ingredient2)
        #expect(ingredient1 != ingredient3)
    }

    // MARK: - GeneratedNutrition Tests

    @Test("GeneratedNutrition decodes partial data")
    func nutritionPartialDecoding() throws {
        let json = """
        {"calories": 200, "protein": 10.0}
        """

        let data = json.data(using: .utf8)!
        let nutrition = try JSONDecoder().decode(GeneratedNutrition.self, from: data)

        #expect(nutrition.calories == 200)
        #expect(nutrition.protein == 10.0)
        #expect(nutrition.carbohydrates == nil)
        #expect(nutrition.fat == nil)
        #expect(nutrition.fiber == nil)
        #expect(nutrition.sodium == nil)
        #expect(nutrition.sugar == nil)
    }

    // MARK: - Test Helpers

    private func decodeRecipe(prepTime: Int?, cookTime: Int?) throws -> GeneratedRecipe {
        var json = """
        {
            "title": "Test",
            "description": "Test",
            "ingredients": [],
            "instructions": ["Step 1"]
        """

        if let prep = prepTime {
            json += ", \"prepTime\": \(prep)"
        }
        if let cook = cookTime {
            json += ", \"cookTime\": \(cook)"
        }
        json += "}"

        let data = json.data(using: .utf8)!
        return try JSONDecoder().decode(GeneratedRecipe.self, from: data)
    }

    private func decodeFullRecipe() throws -> GeneratedRecipe {
        let json = """
        {
            "title": "Pasta Carbonara",
            "description": "A creamy Italian pasta dish",
            "ingredients": [
                {"quantity": "1 lb", "unit": "pounds", "item": "spaghetti", "preparation": null},
                {"quantity": "4", "unit": null, "item": "eggs", "preparation": "beaten"}
            ],
            "instructions": ["Boil pasta", "Mix eggs", "Combine"],
            "prepTime": 15,
            "cookTime": 20,
            "servings": 4,
            "cuisine": "Italian",
            "tags": ["quick", "comfort food"],
            "nutrition": {
                "calories": 650,
                "carbohydrates": 75.0,
                "protein": 25.0,
                "fat": 28.0,
                "fiber": 3.0,
                "sodium": 800.0,
                "sugar": 2.0
            }
        }
        """

        let data = json.data(using: .utf8)!
        return try JSONDecoder().decode(GeneratedRecipe.self, from: data)
    }
}
