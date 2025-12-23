import Testing
import Foundation
import SwiftData
@testable import RecipeApp

@Suite("CookingModeViewModel Tests")
@MainActor
struct CookingModeViewModelTests {
    
    // MARK: - Initialization Tests
    
    @Test("ViewModel initializes with recipe and starts at step 0")
    func testInitialization() async {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Test Recipe",
            instructions: ["Step 1", "Step 2", "Step 3"]
        )
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        
        let viewModel = CookingModeViewModel(recipe: recipe, modelContext: modelContext)
        
        #expect(viewModel.currentStepIndex == 0)
        #expect(viewModel.sortedSteps.count == 3)
        #expect(viewModel.currentStep.instruction == "Step 1")
    }
    
    @Test("ViewModel loads sorted steps correctly")
    func testSortedStepsLoaded() async {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Test Recipe",
            instructions: ["First", "Second", "Third", "Fourth"]
        )
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        
        let viewModel = CookingModeViewModel(recipe: recipe, modelContext: modelContext)
        
        #expect(viewModel.sortedSteps.count == 4)
        #expect(viewModel.sortedSteps[0].instruction == "First")
        #expect(viewModel.sortedSteps[3].instruction == "Fourth")
    }
    
    // MARK: - Jump To Step Tests
    
    @Test("jumpToStep navigates to valid index")
    func testJumpToStep() {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Test Recipe",
            instructions: ["Step 1", "Step 2", "Step 3"]
        )
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = CookingModeViewModel(recipe: recipe, modelContext: modelContext)
        
        viewModel.jumpToStep(2)
        
        #expect(viewModel.currentStepIndex == 2)
        #expect(viewModel.currentStep.instruction == "Step 3")
    }
    
    @Test("jumpToStep clamps to valid range")
    func testJumpToStepClampsRange() {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Test Recipe",
            instructions: ["Step 1", "Step 2", "Step 3"]
        )
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = CookingModeViewModel(recipe: recipe, modelContext: modelContext)
        
        viewModel.jumpToStep(-1)
        #expect(viewModel.currentStepIndex == 0)
        
        viewModel.jumpToStep(99)
        #expect(viewModel.currentStepIndex == 2)
    }
    
    // MARK: - State Tests
    
    @Test("isOnFinalStep returns true for last step")
    func testIsOnFinalStep() async {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Test Recipe",
            instructions: ["Step 1", "Step 2", "Step 3"]
        )
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = CookingModeViewModel(recipe: recipe, modelContext: modelContext)
        
        viewModel.currentStepIndex = 2
        
        #expect(viewModel.isOnFinalStep == true)
    }
    
    @Test("isOnFinalStep returns false for middle steps")
    func testIsOnFinalStepMiddle() async {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Test Recipe",
            instructions: ["Step 1", "Step 2", "Step 3"]
        )
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = CookingModeViewModel(recipe: recipe, modelContext: modelContext)
        
        viewModel.currentStepIndex = 1
        
        #expect(viewModel.isOnFinalStep == false)
    }
    
    @Test("progressText formats correctly")
    func testProgressText() async {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Test Recipe",
            instructions: ["Step 1", "Step 2", "Step 3", "Step 4", "Step 5"]
        )
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = CookingModeViewModel(recipe: recipe, modelContext: modelContext)
        
        #expect(viewModel.progressText == "Step 1 of 5")
        
        viewModel.currentStepIndex = 2
        
        #expect(viewModel.progressText == "Step 3 of 5")
    }
    
    // MARK: - Recipe Data Accessors
    
    @Test("ingredients returns sorted ingredients")
    func testIngredients() {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Test Recipe",
            ingredients: [("1 cup", nil, "flour"), ("2", nil, "eggs"), ("1 tsp", nil, "salt")],
            instructions: ["Mix"]
        )
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = CookingModeViewModel(recipe: recipe, modelContext: modelContext)
        
        #expect(viewModel.ingredients.count == 3)
        #expect(viewModel.ingredients[0].item == "flour")
    }
    
    @Test("recipeTitle returns recipe title")
    func testRecipeTitle() {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Chocolate Cake",
            instructions: ["Mix", "Bake"]
        )
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = CookingModeViewModel(recipe: recipe, modelContext: modelContext)
        
        #expect(viewModel.recipeTitle == "Chocolate Cake")
    }
    
    // MARK: - Mark as Cooked Tests
    
    @Test("markAsCooked increments timesCooked")
    func testMarkAsCookedIncrementsTimesCooked() async {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Test Recipe",
            timesCooked: 3,
            instructions: ["Step 1", "Step 2"]
        )
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        modelContext.insert(recipe)
        
        let viewModel = CookingModeViewModel(recipe: recipe, modelContext: modelContext)
        
        #expect(recipe.timesCooked == 3)
        
        let success = viewModel.markAsCooked()
        
        #expect(success == true)
        #expect(recipe.timesCooked == 4)
    }
    
    @Test("markAsCooked sets lastMade date")
    func testMarkAsCookedSetsLastMade() async {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Test Recipe",
            instructions: ["Step 1", "Step 2"]
        )
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        modelContext.insert(recipe)
        
        let viewModel = CookingModeViewModel(recipe: recipe, modelContext: modelContext)
        
        #expect(recipe.lastMade == nil)
        
        let beforeDate = Date()
        let success = viewModel.markAsCooked()
        let afterDate = Date()
        
        #expect(success == true)
        #expect(recipe.lastMade != nil)
        
        // Verify lastMade is between before and after (within reasonable time)
        if let lastMade = recipe.lastMade {
            #expect(lastMade >= beforeDate)
            #expect(lastMade <= afterDate)
        }
    }
    
    @Test("markAsCooked saves to context")
    func testMarkAsCookedSavesToContext() async {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Test Recipe",
            timesCooked: 0,
            instructions: ["Step 1", "Step 2"]
        )
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        modelContext.insert(recipe)
        
        let viewModel = CookingModeViewModel(recipe: recipe, modelContext: modelContext)
        
        let success = viewModel.markAsCooked()
        
        #expect(success == true)
        #expect(recipe.timesCooked == 1)
        #expect(recipe.lastMade != nil)
        
        // Verify changes are in the model context
        let descriptor = FetchDescriptor<Recipe>()
        let recipes = try! modelContext.fetch(descriptor)
        
        #expect(recipes.count == 1)
        #expect(recipes[0].timesCooked == 1)
        #expect(recipes[0].lastMade != nil)
    }
}
