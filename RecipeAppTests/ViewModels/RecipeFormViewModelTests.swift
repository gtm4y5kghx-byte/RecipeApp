import Testing
import Foundation
@testable import RecipeApp

@Suite("RecipeFormViewModel Tests")
@MainActor
struct RecipeFormViewModelTests {

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
}
