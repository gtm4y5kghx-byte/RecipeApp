import Testing
import Foundation
@testable import RecipeApp

@Suite("Recipe Context Formatter Tests")
struct RecipeContextFormatterTests {
    
    @Test("Format catalog with multiple recipes")
    func testFormatCatalog() {
        let recipe1 = createTestRecipe()
        recipe1.cuisine = "Italian"
        recipe1.lastMade = Calendar.current.date(byAdding: .day, value: -5, to: Date())
        
        let recipe2 = Recipe(title: "Second Recipe", sourceType: .manual)
        recipe2.cuisine = "Mexican"
        recipe2.prepTime = 15
        recipe2.cookTime = 30
        recipe2.timesCooked = 0
        
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
        let recipe = Recipe(title: "Never Cooked", sourceType: .manual)
        recipe.timesCooked = 0
        
        let catalog = RecipeContextFormatter.formatCatalog([recipe])
        
        #expect(catalog.contains("Times Cooked: 0"))
        #expect(catalog.contains("Last Made: Never"))
    }
    
    @Test("Format catalog with favorite recipe")
    func testFormatCatalogFavorite() {
        let recipe = Recipe(title: "Favorite", sourceType: .manual)
        recipe.isFavorite = true
        
        let catalog = RecipeContextFormatter.formatCatalog([recipe])
        
        #expect(catalog.contains("Favorite: Yes"))
    }
    
    @Test("Format recipe context for transformation")
    func testTransformationFormat() {
        let recipe = createTestRecipe()
        
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
        let recipe = createTestRecipe()
        recipe.cuisine = "Italian"
        
        let context = RecipeContextFormatter.format(recipe)
        
        #expect(context.contains("Cuisine: Italian"))
    }
    
    @Test("Transformation format includes notes")
    func testTransformationWithNotes() {
        let recipe = createTestRecipe()
        recipe.notes = "Best served warm"
        
        let context = RecipeContextFormatter.format(recipe)
        
        #expect(context.contains("Notes: Best served warm"))
    }
    
    // MARK: - Edge Cases
    
    @Test("Handle recipe with no ingredients")
    func testNoIngredients() {
        let recipe = Recipe(title: "Empty Recipe", sourceType: .manual)
        
        let context = RecipeContextFormatter.format(recipe)
        
        #expect(context.contains("Title: Empty Recipe"))
        #expect(context.contains("Ingredients:"))
    }
    
    @Test("Handle recipe with no instructions")
    func testNoInstructions() {
        let recipe = Recipe(title: "No Steps", sourceType: .manual)
        
        let context = RecipeContextFormatter.format(recipe)
        
        #expect(context.contains("Title: No Steps"))
        #expect(context.contains("Instructions:"))
    }
    
    @Test("Handle recipe with minimal data")
    func testMinimalRecipe() {
        let recipe = Recipe(title: "Minimal", sourceType: .manual)
        
        let context = RecipeContextFormatter.format(recipe)
        
        #expect(context.contains("Title: Minimal"))
        #expect(!context.contains("Servings:"))
        #expect(!context.contains("Cuisine:"))
    }
    
    // MARK: - Helper
    
    private func createTestRecipe() -> Recipe {
        let recipe = Recipe(title: "Test Recipe", sourceType: .manual)
        recipe.servings = 4
        recipe.prepTime = 15
        recipe.cookTime = 30
        recipe.timesCooked = 2
        
        let ing1 = Ingredient(quantity: "2", unit: "cups", item: "flour", preparation: nil, section: nil)
        ing1.order = 0
        recipe.ingredients.append(ing1)
        
        let step1 = Step(instruction: "Mix ingredients")
        step1.order = 0
        recipe.instructions.append(step1)
        
        return recipe
    }
}
