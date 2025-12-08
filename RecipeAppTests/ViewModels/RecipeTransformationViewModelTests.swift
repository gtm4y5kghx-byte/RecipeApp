import Testing
import Foundation
import SwiftData
@testable import RecipeApp

@Suite("RecipeTransformationViewModel Tests")
@MainActor
struct RecipeTransformationViewModelTests {

    // MARK: - Initial State Tests

    @Test("Initial state has empty transformation prompt")
    func testInitialPromptEmpty() {
        let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe")
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let mockService = MockRecipeTransformationService()
        let viewModel = RecipeTransformationViewModel(recipe: recipe, modelContext: modelContext, service: mockService)

        #expect(viewModel.transformationPrompt == "")
    }

    @Test("Initial state is not processing")
    func testInitialIsProcessingFalse() {
        let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe")
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let mockService = MockRecipeTransformationService()
        let viewModel = RecipeTransformationViewModel(recipe: recipe, modelContext: modelContext, service: mockService)

        #expect(viewModel.isProcessing == false)
    }

    @Test("Initial state has no error")
    func testInitialErrorNil() {
        let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe")
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let mockService = MockRecipeTransformationService()
        let viewModel = RecipeTransformationViewModel(recipe: recipe, modelContext: modelContext, service: mockService)

        #expect(viewModel.error == nil)
    }

    // MARK: - Transform Recipe Tests

    @Test("Transform recipe calls service with correct parameters")
    func testTransformRecipeCallsService() async {
        let recipe = RecipeTestFixtures.createRecipe(title: "Original Recipe")
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let mockService = MockRecipeTransformationService()
        let viewModel = RecipeTransformationViewModel(recipe: recipe, modelContext: modelContext, service: mockService)

        viewModel.transformationPrompt = "Make it vegan"

        _ = await viewModel.transformRecipe()

        #expect(mockService.transformRecipeCallCount == 1)
        #expect(mockService.capturedRecipe?.id == recipe.id)
        #expect(mockService.capturedTransformationPrompt == "Make it vegan")
    }

    @Test("Transform recipe returns true on success")
    func testTransformRecipeReturnsTrue() async {
        let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe")
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let mockService = MockRecipeTransformationService()
        let viewModel = RecipeTransformationViewModel(recipe: recipe, modelContext: modelContext, service: mockService)

        viewModel.transformationPrompt = "Make it vegan"

        let result = await viewModel.transformRecipe()

        #expect(result == true)
    }

    @Test("Transform recipe returns false on service error")
    func testTransformRecipeReturnsFalseOnError() async {
        let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe")
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let mockService = MockRecipeTransformationService()
        mockService.shouldThrowError = true

        let viewModel = RecipeTransformationViewModel(recipe: recipe, modelContext: modelContext, service: mockService)
        viewModel.transformationPrompt = "Make it vegan"

        let result = await viewModel.transformRecipe()

        #expect(result == false)
    }

    @Test("Transform recipe sets isProcessing false after completion")
    func testTransformRecipeSetsIsProcessingFalseAfterCompletion() async {
        let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe")
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let mockService = MockRecipeTransformationService()
        let viewModel = RecipeTransformationViewModel(recipe: recipe, modelContext: modelContext, service: mockService)

        viewModel.transformationPrompt = "Make it vegan"

        _ = await viewModel.transformRecipe()

        #expect(viewModel.isProcessing == false)
    }

    @Test("Transform recipe sets isProcessing false after error")
    func testTransformRecipeSetsIsProcessingFalseAfterError() async {
        let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe")
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let mockService = MockRecipeTransformationService()
        mockService.shouldThrowError = true

        let viewModel = RecipeTransformationViewModel(recipe: recipe, modelContext: modelContext, service: mockService)
        viewModel.transformationPrompt = "Make it vegan"

        _ = await viewModel.transformRecipe()

        #expect(viewModel.isProcessing == false)
    }

    @Test("Transform recipe sets error on service failure")
    func testTransformRecipeSetsErrorOnFailure() async {
        let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe")
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let mockService = MockRecipeTransformationService()
        mockService.shouldThrowError = true

        let viewModel = RecipeTransformationViewModel(recipe: recipe, modelContext: modelContext, service: mockService)
        viewModel.transformationPrompt = "Make it vegan"

        _ = await viewModel.transformRecipe()

        #expect(viewModel.error != nil)
    }

    // MARK: - Create Variation Tests

    @Test("Create variation sets parent recipe ID")
    func testCreateVariationSetsParentRecipeID() async {
        let recipe = RecipeTestFixtures.createRecipe(title: "Original Recipe")
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let mockService = MockRecipeTransformationService()
        let viewModel = RecipeTransformationViewModel(recipe: recipe, modelContext: modelContext, service: mockService)

        viewModel.transformationPrompt = "Make it vegan"
        _ = await viewModel.transformRecipe()

        let fetchDescriptor = FetchDescriptor<Recipe>()
        let recipes = try? modelContext.fetch(fetchDescriptor)
        let variation = recipes?.first { $0.parentRecipeID != nil }

        #expect(variation?.parentRecipeID == recipe.id)
    }

    @Test("Create variation maps title correctly")
    func testCreateVariationMapsTitle() async {
        let recipe = RecipeTestFixtures.createRecipe(title: "Original Recipe")
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let mockService = MockRecipeTransformationService()
        mockService.mockTransformation = RecipeTransformation(
            title: "Vegan Original Recipe",
            variationNote: "Made vegan",
            notes: nil,
            prepTime: nil,
            cookTime: nil,
            servings: nil,
            cuisine: nil,
            ingredients: [],
            instructions: []
        )

        let viewModel = RecipeTransformationViewModel(recipe: recipe, modelContext: modelContext, service: mockService)
        viewModel.transformationPrompt = "Make it vegan"
        _ = await viewModel.transformRecipe()

        let fetchDescriptor = FetchDescriptor<Recipe>()
        let recipes = try? modelContext.fetch(fetchDescriptor)
        let variation = recipes?.first { $0.parentRecipeID != nil }

        #expect(variation?.title == "Vegan Original Recipe")
    }

    @Test("Create variation maps variation note")
    func testCreateVariationMapsVariationNote() async {
        let recipe = RecipeTestFixtures.createRecipe(title: "Original Recipe")
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let mockService = MockRecipeTransformationService()
        mockService.mockTransformation = RecipeTransformation(
            title: "Transformed",
            variationNote: "Made gluten-free and dairy-free",
            notes: nil,
            prepTime: nil,
            cookTime: nil,
            servings: nil,
            cuisine: nil,
            ingredients: [],
            instructions: []
        )

        let viewModel = RecipeTransformationViewModel(recipe: recipe, modelContext: modelContext, service: mockService)
        viewModel.transformationPrompt = "Make it gluten-free"
        _ = await viewModel.transformRecipe()

        let fetchDescriptor = FetchDescriptor<Recipe>()
        let recipes = try? modelContext.fetch(fetchDescriptor)
        let variation = recipes?.first { $0.parentRecipeID != nil }

        #expect(variation?.variationNote == "Made gluten-free and dairy-free")
    }

    @Test("Create variation maps ingredients with correct order")
    func testCreateVariationMapsIngredientsWithOrder() async {
        let recipe = RecipeTestFixtures.createRecipe(title: "Original Recipe")
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let mockService = MockRecipeTransformationService()
        mockService.mockTransformation = RecipeTransformation(
            title: "Transformed",
            variationNote: "Changed",
            notes: nil,
            prepTime: nil,
            cookTime: nil,
            servings: nil,
            cuisine: nil,
            ingredients: [
                TransformedIngredient(text: "2 cups flour", changeNote: nil),
                TransformedIngredient(text: "1 cup sugar", changeNote: nil),
                TransformedIngredient(text: "3 eggs", changeNote: nil)
            ],
            instructions: []
        )

        let viewModel = RecipeTransformationViewModel(recipe: recipe, modelContext: modelContext, service: mockService)
        viewModel.transformationPrompt = "Transform"
        _ = await viewModel.transformRecipe()

        let fetchDescriptor = FetchDescriptor<Recipe>()
        let recipes = try? modelContext.fetch(fetchDescriptor)
        let variation = recipes?.first { $0.parentRecipeID != nil }

        let sortedIngredients = variation?.sortedIngredients ?? []
        #expect(sortedIngredients.count == 3)
        #expect(sortedIngredients[0].item == "2 cups flour")
        #expect(sortedIngredients[0].order == 0)
        #expect(sortedIngredients[1].item == "1 cup sugar")
        #expect(sortedIngredients[1].order == 1)
        #expect(sortedIngredients[2].item == "3 eggs")
        #expect(sortedIngredients[2].order == 2)
    }

    @Test("Create variation maps instructions with correct order")
    func testCreateVariationMapsInstructionsWithOrder() async {
        let recipe = RecipeTestFixtures.createRecipe(title: "Original Recipe")
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let mockService = MockRecipeTransformationService()
        mockService.mockTransformation = RecipeTransformation(
            title: "Transformed",
            variationNote: "Changed",
            notes: nil,
            prepTime: nil,
            cookTime: nil,
            servings: nil,
            cuisine: nil,
            ingredients: [],
            instructions: [
                TransformedInstruction(text: "Preheat oven", changeNote: nil),
                TransformedInstruction(text: "Mix ingredients", changeNote: nil),
                TransformedInstruction(text: "Bake for 30 minutes", changeNote: nil)
            ]
        )

        let viewModel = RecipeTransformationViewModel(recipe: recipe, modelContext: modelContext, service: mockService)
        viewModel.transformationPrompt = "Transform"
        _ = await viewModel.transformRecipe()

        let fetchDescriptor = FetchDescriptor<Recipe>()
        let recipes = try? modelContext.fetch(fetchDescriptor)
        let variation = recipes?.first { $0.parentRecipeID != nil }

        let sortedInstructions = variation?.sortedInstructions ?? []
        #expect(sortedInstructions.count == 3)
        #expect(sortedInstructions[0].instruction == "Preheat oven")
        #expect(sortedInstructions[0].order == 0)
        #expect(sortedInstructions[1].instruction == "Mix ingredients")
        #expect(sortedInstructions[1].order == 1)
        #expect(sortedInstructions[2].instruction == "Bake for 30 minutes")
        #expect(sortedInstructions[2].order == 2)
    }

    @Test("Create variation maps optional fields")
    func testCreateVariationMapsOptionalFields() async {
        let recipe = RecipeTestFixtures.createRecipe(title: "Original Recipe")
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let mockService = MockRecipeTransformationService()
        mockService.mockTransformation = RecipeTransformation(
            title: "Transformed",
            variationNote: "Changed",
            notes: "Some notes about the transformation",
            prepTime: 15,
            cookTime: 45,
            servings: 8,
            cuisine: "French",
            ingredients: [],
            instructions: []
        )

        let viewModel = RecipeTransformationViewModel(recipe: recipe, modelContext: modelContext, service: mockService)
        viewModel.transformationPrompt = "Transform"
        _ = await viewModel.transformRecipe()

        let fetchDescriptor = FetchDescriptor<Recipe>()
        let recipes = try? modelContext.fetch(fetchDescriptor)
        let variation = recipes?.first { $0.parentRecipeID != nil }

        #expect(variation?.notes == "Some notes about the transformation")
        #expect(variation?.prepTime == 15)
        #expect(variation?.cookTime == 45)
        #expect(variation?.servings == 8)
        #expect(variation?.cuisine == "French")
    }

    @Test("Create variation inserts into model context")
    func testCreateVariationInsertsIntoContext() async {
        let recipe = RecipeTestFixtures.createRecipe(title: "Original Recipe")
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let mockService = MockRecipeTransformationService()

        let viewModel = RecipeTransformationViewModel(recipe: recipe, modelContext: modelContext, service: mockService)
        viewModel.transformationPrompt = "Transform"
        _ = await viewModel.transformRecipe()

        let fetchDescriptor = FetchDescriptor<Recipe>()
        let recipes = try? modelContext.fetch(fetchDescriptor)

        #expect(recipes?.count == 1)
        #expect(recipes?.first?.parentRecipeID != nil)
    }
}
