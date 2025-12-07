import Testing
@testable import RecipeApp

@Suite("Recipe Sorting Extensions Tests")
struct RecipeExtensionsTests {
    
    // MARK: - sortedIngredients Tests
    
    @Test("Recipe returns ingredients sorted by order")
    func testSortedIngredients() {
        let recipe = Recipe(title: "Test Recipe", sourceType: .manual)
        
        let ing1 = Ingredient(quantity: "1", unit: "cup", item: "flour", preparation: nil, section: nil)
        ing1.order = 2
        
        let ing2 = Ingredient(quantity: "2", unit: "cups", item: "sugar", preparation: nil, section: nil)
        ing2.order = 0
        
        let ing3 = Ingredient(quantity: "3", unit: nil, item: "eggs", preparation: nil, section: nil)
        ing3.order = 1
        
        recipe.ingredients = [ing1, ing2, ing3]
        
        let sorted = recipe.sortedIngredients
        
        #expect(sorted[0].item == "sugar")   // order: 0
        #expect(sorted[1].item == "eggs")    // order: 1
        #expect(sorted[2].item == "flour")   // order: 2
    }
    
    @Test("Empty ingredients array returns empty sorted array")
    func testSortedIngredientsEmpty() {
        let recipe = Recipe(title: "Test Recipe", sourceType: .manual)
        recipe.ingredients = []
        
        let sorted = recipe.sortedIngredients
        
        #expect(sorted.isEmpty)
    }
    
    // MARK: - sortedInstructions Tests
    
    @Test("Recipe returns instructions sorted by order")
    func testSortedInstructions() {
        let recipe = Recipe(title: "Test Recipe", sourceType: .manual)
        
        let step1 = Step(instruction: "Preheat oven")
        step1.order = 2
        
        let step2 = Step(instruction: "Mix ingredients")
        step2.order = 0
        
        let step3 = Step(instruction: "Pour into pan")
        step3.order = 1
        
        recipe.instructions = [step1, step2, step3]
        
        let sorted = recipe.sortedInstructions
        
        #expect(sorted[0].instruction == "Mix ingredients")  // order: 0
        #expect(sorted[1].instruction == "Pour into pan")    // order: 1
        #expect(sorted[2].instruction == "Preheat oven")     // order: 2
    }
    
    @Test("Empty instructions array returns empty sorted array")
    func testSortedInstructionsEmpty() {
        let recipe = Recipe(title: "Test Recipe", sourceType: .manual)
        recipe.instructions = []
        
        let sorted = recipe.sortedInstructions
        
        #expect(sorted.isEmpty)
    }
    
    @Test("Sorted ingredients maintains original array immutability")
    func testSortedIngredientsImmutable() {
        let recipe = Recipe(title: "Test Recipe", sourceType: .manual)
        
        let ing1 = Ingredient(quantity: "1", unit: nil, item: "A", preparation: nil, section: nil)
        ing1.order = 1
        
        let ing2 = Ingredient(quantity: "2", unit: nil, item: "B", preparation: nil, section: nil)
        ing2.order = 0
        
        recipe.ingredients = [ing1, ing2]
        
        let sorted = recipe.sortedIngredients
        
        // Original array should still be in original order
        #expect(recipe.ingredients[0].item == "A")
        #expect(recipe.ingredients[1].item == "B")
        
        // Sorted array should be in sorted order
        #expect(sorted[0].item == "B")
        #expect(sorted[1].item == "A")
    }
}
