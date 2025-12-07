import Testing
import Foundation
@testable import RecipeApp

@Suite("Recipe Context Formatter Tests")
@MainActor
struct RecipeContextFormatterTests {

    @Test("Format catalog with multiple recipes")
    func testFormatCatalog() {
        let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: Date())

        let recipe1 = RecipeTestFixtures.createRecipe(
            title: "Test Recipe",
            cuisine: "Italian",
            timesCooked: 2,
            lastMade: fiveDaysAgo,
            prepTime: 15,
            cookTime: 30,
            servings: 4,
            ingredients: [("2", "cups", "flour")],
            instructions: ["Mix ingredients"]
        )

        let recipe2 = RecipeTestFixtures.createRecipe(
            title: "Second Recipe",
            cuisine: "Mexican",
            timesCooked: 0,
            prepTime: 15,
            cookTime: 30
        )

        let catalog = RecipeContextFormatter.formatCatalog([recipe1, recipe2])

        #expect(catalog.contains("[1] Test Recipe (ID: \(recipe1.id))"))
        #expect(catalog.contains("[2] Second Recipe (ID: \(recipe2.id))"))
        #expect(catalog.contains("Cuisine: Italian"))
        #expect(catalog.contains("Cuisine: Mexican"))
        #expect(catalog.contains("Times Cooked: 2"))
        #expect(catalog.contains("Times Cooked: 0"))
        #expect(catalog.contains("Last Made: 5 days ago"))
        #expect(catalog.contains("Last Made: Never"))
    }

    @Test("Format catalog with empty array")
    func testFormatCatalogEmpty() {
        let catalog = RecipeContextFormatter.formatCatalog([])
        #expect(catalog == "")
    }

    @Test("Format catalog with never-cooked recipe")
    func testFormatCatalogNeverCooked() {
        let recipe = RecipeTestFixtures.createRecipe(title: "Never Cooked", timesCooked: 0)

        let catalog = RecipeContextFormatter.formatCatalog([recipe])

        #expect(catalog.contains("Times Cooked: 0"))
        #expect(catalog.contains("Last Made: Never"))
    }

    @Test("Format catalog with favorite recipe")
    func testFormatCatalogFavorite() {
        let recipe = RecipeTestFixtures.createRecipe(title: "Favorite", isFavorite: true)

        let catalog = RecipeContextFormatter.formatCatalog([recipe])

        #expect(catalog.contains("Favorite: Yes"))
    }

    @Test("Format recipe context for transformation")
    func testTransformationFormat() {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Test Recipe",
            timesCooked: 2,
            prepTime: 15,
            cookTime: 30,
            servings: 4,
            ingredients: [("2", "cups", "flour")],
            instructions: ["Mix ingredients"]
        )

        let context = RecipeContextFormatter.format(recipe)

        #expect(context.contains("Title: Test Recipe"))
        #expect(context.contains("Servings: 4"))
        #expect(context.contains("Ingredients:"))
        #expect(context.contains("2 cups flour"))
        #expect(context.contains("Instructions:"))
        #expect(context.contains("Mix ingredients"))
    }

    @Test("Transformation format includes cuisine")
    func testTransformationWithCuisine() {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Test Recipe",
            cuisine: "Italian",
            timesCooked: 2,
            prepTime: 15,
            cookTime: 30,
            servings: 4,
            ingredients: [("2", "cups", "flour")],
            instructions: ["Mix ingredients"]
        )

        let context = RecipeContextFormatter.format(recipe)

        #expect(context.contains("Cuisine: Italian"))
    }

    @Test("Transformation format includes notes")
    func testTransformationWithNotes() {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Test Recipe",
            timesCooked: 2,
            prepTime: 15,
            cookTime: 30,
            servings: 4,
            ingredients: [("2", "cups", "flour")],
            instructions: ["Mix ingredients"]
        )
        recipe.notes = "Best served warm"

        let context = RecipeContextFormatter.format(recipe)

        #expect(context.contains("Notes: Best served warm"))
    }

    // MARK: - Edge Cases

    @Test("Handle recipe with no ingredients")
    func testNoIngredients() {
        let recipe = RecipeTestFixtures.createRecipe(title: "Empty Recipe")

        let context = RecipeContextFormatter.format(recipe)

        #expect(context.contains("Title: Empty Recipe"))
        #expect(context.contains("Ingredients:"))
    }

    @Test("Handle recipe with no instructions")
    func testNoInstructions() {
        let recipe = RecipeTestFixtures.createRecipe(title: "No Steps")

        let context = RecipeContextFormatter.format(recipe)

        #expect(context.contains("Title: No Steps"))
        #expect(context.contains("Instructions:"))
    }

    @Test("Handle recipe with minimal data")
    func testMinimalRecipe() {
        let recipe = RecipeTestFixtures.createRecipe(title: "Minimal")

        let context = RecipeContextFormatter.format(recipe)

        #expect(context.contains("Title: Minimal"))
        #expect(!context.contains("Servings:"))
        #expect(!context.contains("Cuisine:"))
    }
}
