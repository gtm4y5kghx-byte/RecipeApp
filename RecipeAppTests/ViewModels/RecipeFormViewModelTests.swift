import Testing
import Foundation
@testable import RecipeApp

@Suite("RecipeFormViewModel Tests")
@MainActor
struct RecipeFormViewModelTests {

    // MARK: - Form Has Changes (New Recipe)

    @Test("Form has changes returns false for new recipe with no input")
    func testFormHasChangesNewRecipeEmpty() {
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: nil, importData: nil, modelContext: modelContext)

        #expect(viewModel.formHasChanges == false)
    }

    @Test("Form has changes returns true for new recipe with title")
    func testFormHasChangesNewRecipeWithTitle() {
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: nil, importData: nil, modelContext: modelContext)

        viewModel.title = "New Recipe"

        #expect(viewModel.formHasChanges == true)
    }

    @Test("Form has changes returns true for new recipe with ingredients")
    func testFormHasChangesNewRecipeWithIngredients() {
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: nil, importData: nil, modelContext: modelContext)

        viewModel.ingredientFields = ["flour"]

        #expect(viewModel.formHasChanges == true)
    }

    // MARK: - Form Has Changes (Edit Recipe)

    @Test("Form has changes returns false for edit recipe with no changes")
    func testFormHasChangesEditRecipeNoChanges() {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Original Recipe",
            cuisine: "Italian",
            prepTime: 15,
            cookTime: 30,
            servings: 4,
            ingredients: [("", nil, "flour")],
            instructions: ["Mix ingredients"],
            notes: "Test notes"
        )

        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: recipe, importData: nil, modelContext: modelContext)

        #expect(viewModel.formHasChanges == false)
    }

    @Test("Form has changes returns true for edit recipe with title changed")
    func testFormHasChangesEditRecipeTitleChanged() {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Original Recipe",
            ingredients: [("", nil, "flour")],
            instructions: ["Mix ingredients"]
        )

        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: recipe, importData: nil, modelContext: modelContext)

        viewModel.title = "Modified Recipe"

        #expect(viewModel.formHasChanges == true)
    }

    @Test("Form has changes returns true for edit recipe with ingredients changed")
    func testFormHasChangesEditRecipeIngredientsChanged() {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Recipe",
            ingredients: [("", nil, "flour")],
            instructions: ["Mix"]
        )

        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: recipe, importData: nil, modelContext: modelContext)

        viewModel.ingredientFields = ["flour", "sugar"]

        #expect(viewModel.formHasChanges == true)
    }

    // MARK: - Ingredient Management

    @Test("Add ingredient appends empty string")
    func testAddIngredient() {
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: nil, importData: nil, modelContext: modelContext)

        let initialCount = viewModel.ingredientFields.count
        viewModel.addIngredient()

        #expect(viewModel.ingredientFields.count == initialCount + 1)
        #expect(viewModel.ingredientFields.last == "")
    }

    @Test("Remove ingredient removes at index")
    func testRemoveIngredient() {
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: nil, importData: nil, modelContext: modelContext)

        viewModel.ingredientFields = ["flour", "sugar", "salt"]
        viewModel.removeIngredient(at: 1)

        #expect(viewModel.ingredientFields == ["flour", "salt"])
    }

    // MARK: - Instruction Management

    @Test("Add instruction appends empty string")
    func testAddInstruction() {
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: nil, importData: nil, modelContext: modelContext)

        let initialCount = viewModel.instructionFields.count
        viewModel.addInstruction()

        #expect(viewModel.instructionFields.count == initialCount + 1)
        #expect(viewModel.instructionFields.last == "")
    }

    @Test("Remove instruction removes at index")
    func testRemoveInstruction() {
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: nil, importData: nil, modelContext: modelContext)

        viewModel.instructionFields = ["Step 1", "Step 2", "Step 3"]
        viewModel.removeInstruction(at: 0)

        #expect(viewModel.instructionFields == ["Step 2", "Step 3"])
    }

    // MARK: - Tag Suggestions

    @Test("Tag suggestions returns empty when no input")
    func testTagSuggestionsEmpty() {
        let allRecipes = [
            RecipeTestFixtures.createRecipe(title: "R1", tags: ["italian", "pasta"])
        ]

        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: nil, importData: nil, modelContext: modelContext)

        let suggestions = viewModel.getTagSuggestions(allRecipes: allRecipes)

        #expect(suggestions.isEmpty)
    }

    @Test("Tag suggestions returns matching tags")
    func testTagSuggestionsMatching() {
        let allRecipes = [
            RecipeTestFixtures.createRecipe(title: "R1", tags: ["italian", "pasta"]),
            RecipeTestFixtures.createRecipe(title: "R2", tags: ["italian", "pizza"]),
            RecipeTestFixtures.createRecipe(title: "R3", tags: ["indian"])
        ]

        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: nil, importData: nil, modelContext: modelContext)

        viewModel.tagInput = "ita"
        let suggestions = viewModel.getTagSuggestions(allRecipes: allRecipes)

        #expect(suggestions.count == 1)
        #expect(suggestions[0].0 == "italian")
        #expect(suggestions[0].1 == 2)
    }

    @Test("Tag suggestions returns sorted by count descending")
    func testTagSuggestionsSortedByCount() {
        let allRecipes = [
            RecipeTestFixtures.createRecipe(title: "R1", tags: ["italian"]),
            RecipeTestFixtures.createRecipe(title: "R2", tags: ["indian"]),
            RecipeTestFixtures.createRecipe(title: "R3", tags: ["indian"]),
            RecipeTestFixtures.createRecipe(title: "R4", tags: ["indonesian"])
        ]

        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: nil, importData: nil, modelContext: modelContext)

        viewModel.tagInput = "ind"
        let suggestions = viewModel.getTagSuggestions(allRecipes: allRecipes)

        #expect(suggestions.count == 2)
        #expect(suggestions[0].0 == "indian")
        #expect(suggestions[0].1 == 2)
        #expect(suggestions[1].0 == "indonesian")
        #expect(suggestions[1].1 == 1)
    }

    @Test("Tag suggestions excludes exact matches")
    func testTagSuggestionsExcludesExactMatch() {
        let allRecipes = [
            RecipeTestFixtures.createRecipe(title: "R1", tags: ["italian", "italy"])
        ]

        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: nil, importData: nil, modelContext: modelContext)

        viewModel.tagInput = "italian"
        let suggestions = viewModel.getTagSuggestions(allRecipes: allRecipes)

        #expect(suggestions.isEmpty)
    }

    @Test("Tag suggestions handles comma-separated input")
    func testTagSuggestionsCommaSeparated() {
        let allRecipes = [
            RecipeTestFixtures.createRecipe(title: "R1", tags: ["italian", "quick"])
        ]

        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: nil, importData: nil, modelContext: modelContext)

        viewModel.tagInput = "quick, ita"
        let suggestions = viewModel.getTagSuggestions(allRecipes: allRecipes)

        #expect(suggestions.count == 1)
        #expect(suggestions[0].0 == "italian")
    }

    // MARK: - Apply Tag Suggestion

    @Test("Apply tag suggestion replaces partial tag")
    func testApplyTagSuggestion() {
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: nil, importData: nil, modelContext: modelContext)

        viewModel.tagInput = "ita"
        viewModel.applyTagSuggestion("italian")

        #expect(viewModel.tagInput == "italian, ")
    }

    @Test("Apply tag suggestion with existing tags")
    func testApplyTagSuggestionWithExistingTags() {
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: nil, importData: nil, modelContext: modelContext)

        viewModel.tagInput = "quick, ita"
        viewModel.applyTagSuggestion("italian")

        #expect(viewModel.tagInput == "quick, italian, ")
    }

    // MARK: - Image Management

    @Test("Set image stores image data")
    func testSetImageStoresData() {
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: nil, importData: nil, modelContext: modelContext)
        let imageData = Data([0x00, 0x01, 0x02])

        viewModel.setImage(imageData)

        #expect(viewModel.selectedImageData == imageData)
    }

    @Test("Remove image clears image data")
    func testRemoveImageClearsData() {
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: nil, importData: nil, modelContext: modelContext)
        let imageData = Data([0x00, 0x01, 0x02])

        viewModel.setImage(imageData)
        viewModel.removeImage()

        #expect(viewModel.selectedImageData == nil)
    }

    @Test("Has image returns true when image is set")
    func testHasImageReturnsTrue() {
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: nil, importData: nil, modelContext: modelContext)

        viewModel.setImage(Data([0x00, 0x01, 0x02]))

        #expect(viewModel.hasImage == true)
    }

    @Test("Has image returns false when no image")
    func testHasImageReturnsFalse() {
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: nil, importData: nil, modelContext: modelContext)

        #expect(viewModel.hasImage == false)
    }

    @Test("Form has changes returns true for new recipe with image")
    func testFormHasChangesNewRecipeWithImage() {
        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: nil, importData: nil, modelContext: modelContext)

        viewModel.setImage(Data([0x00, 0x01, 0x02]))

        #expect(viewModel.formHasChanges == true)
    }

    @Test("Form has changes returns true when image removed from existing recipe")
    func testFormHasChangesEditRecipeImageRemoved() {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Recipe with Image",
            ingredients: [("", nil, "flour")],
            instructions: ["Mix"]
        )
        recipe.imageURL = "file:///existing/image.jpg"

        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: recipe, importData: nil, modelContext: modelContext)

        viewModel.removeImage()

        #expect(viewModel.formHasChanges == true)
    }
}
