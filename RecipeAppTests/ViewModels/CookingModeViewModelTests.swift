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

    // MARK: - Navigation Tests

    @Test("Go to next step advances index")
    func testGoToNextStep() async {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Test Recipe",
            instructions: ["Step 1", "Step 2", "Step 3"]
        )
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = CookingModeViewModel(recipe: recipe, modelContext: modelContext)

        #expect(viewModel.currentStepIndex == 0)

        viewModel.goToNextStep()

        #expect(viewModel.currentStepIndex == 1)
        #expect(viewModel.currentStep.instruction == "Step 2")
    }

    @Test("Go to previous step decrements index")
    func testGoToPreviousStep() async {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Test Recipe",
            instructions: ["Step 1", "Step 2", "Step 3"]
        )
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = CookingModeViewModel(recipe: recipe, modelContext: modelContext)

        viewModel.currentStepIndex = 2

        viewModel.goToPreviousStep()

        #expect(viewModel.currentStepIndex == 1)
        #expect(viewModel.currentStep.instruction == "Step 2")
    }

    @Test("Cannot go before first step")
    func testCannotGoBeforeFirstStep() async {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Test Recipe",
            instructions: ["Step 1", "Step 2", "Step 3"]
        )
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = CookingModeViewModel(recipe: recipe, modelContext: modelContext)

        #expect(viewModel.currentStepIndex == 0)
        #expect(viewModel.canGoToPrevious == false)

        viewModel.goToPreviousStep()

        #expect(viewModel.currentStepIndex == 0) // Should stay at 0
    }

    @Test("Cannot go after last step")
    func testCannotGoAfterLastStep() async {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Test Recipe",
            instructions: ["Step 1", "Step 2", "Step 3"]
        )
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = CookingModeViewModel(recipe: recipe, modelContext: modelContext)

        viewModel.currentStepIndex = 2 // Last step (index 2)

        #expect(viewModel.canGoToNext == false)

        viewModel.goToNextStep()

        #expect(viewModel.currentStepIndex == 2) // Should stay at 2
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

    @Test("canGoToPrevious returns correct values")
    func testCanGoToPrevious() async {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Test Recipe",
            instructions: ["Step 1", "Step 2", "Step 3"]
        )
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = CookingModeViewModel(recipe: recipe, modelContext: modelContext)

        // At first step
        #expect(viewModel.canGoToPrevious == false)

        // At second step
        viewModel.currentStepIndex = 1
        #expect(viewModel.canGoToPrevious == true)

        // At last step
        viewModel.currentStepIndex = 2
        #expect(viewModel.canGoToPrevious == true)
    }

    @Test("canGoToNext returns correct values")
    func testCanGoToNext() async {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Test Recipe",
            instructions: ["Step 1", "Step 2", "Step 3"]
        )
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = CookingModeViewModel(recipe: recipe, modelContext: modelContext)

        // At first step
        #expect(viewModel.canGoToNext == true)

        // At second step
        viewModel.currentStepIndex = 1
        #expect(viewModel.canGoToNext == true)

        // At last step
        viewModel.currentStepIndex = 2
        #expect(viewModel.canGoToNext == false)
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
