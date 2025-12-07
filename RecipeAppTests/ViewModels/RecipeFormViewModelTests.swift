import Testing
import Foundation
@testable import RecipeApp

@Suite("RecipeFormViewModel Tests")
@MainActor
struct RecipeFormViewModelTests {

    @Test("Form has changes returns false for new recipe with no input")
    func testFormHasChangesNewRecipeEmpty() {
        let viewModel = RecipeFormViewModel(
            recipe: nil,
            title: "",
            ingredientFields: [""],
            instructionFields: [""],
            servings: "",
            prepTime: "",
            cookTime: "",
            cuisine: "",
            notes: ""
        )

        #expect(viewModel.formHasChanges == false)
    }

    @Test("Form has changes returns true for new recipe with title")
    func testFormHasChangesNewRecipeWithTitle() {
        let viewModel = RecipeFormViewModel(
            recipe: nil,
            title: "New Recipe",
            ingredientFields: [""],
            instructionFields: [""],
            servings: "",
            prepTime: "",
            cookTime: "",
            cuisine: "",
            notes: ""
        )

        #expect(viewModel.formHasChanges == true)
    }

    @Test("Form has changes returns true for new recipe with ingredients")
    func testFormHasChangesNewRecipeWithIngredients() {
        let viewModel = RecipeFormViewModel(
            recipe: nil,
            title: "",
            ingredientFields: ["flour"],
            instructionFields: [""],
            servings: "",
            prepTime: "",
            cookTime: "",
            cuisine: "",
            notes: ""
        )

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
            notes: "Test notes",
        )

        let viewModel = RecipeFormViewModel(
            recipe: recipe,
            title: "Original Recipe",
            ingredientFields: ["flour"],
            instructionFields: ["Mix ingredients"],
            servings: "4",
            prepTime: "15",
            cookTime: "30",
            cuisine: "Italian",
            notes: "Test notes"
        )

        #expect(viewModel.formHasChanges == false)
    }

    @Test("Form has changes returns true for edit recipe with title changed")
    func testFormHasChangesEditRecipeTitleChanged() {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Original Recipe",
            ingredients: [("", nil, "flour")],
            instructions: ["Mix ingredients"]
        )

        let viewModel = RecipeFormViewModel(
            recipe: recipe,
            title: "Modified Recipe",
            ingredientFields: ["flour"],
            instructionFields: ["Mix ingredients"],
            servings: "",
            prepTime: "",
            cookTime: "",
            cuisine: "",
            notes: ""
        )

        #expect(viewModel.formHasChanges == true)
    }

    @Test("Form has changes returns true for edit recipe with ingredients changed")
    func testFormHasChangesEditRecipeIngredientsChanged() {
        let recipe = RecipeTestFixtures.createRecipe(
            title: "Recipe",
            ingredients: [("", nil, "flour")],
            instructions: ["Mix"]
        )

        let viewModel = RecipeFormViewModel(
            recipe: recipe,
            title: "Recipe",
            ingredientFields: ["flour", "sugar"],
            instructionFields: ["Mix"],
            servings: "",
            prepTime: "",
            cookTime: "",
            cuisine: "",
            notes: ""
        )

        #expect(viewModel.formHasChanges == true)
    }

    @Test("Tag suggestions returns empty when no input")
    func testTagSuggestionsEmpty() {
        let allRecipes = [
            RecipeTestFixtures.createRecipe(title: "R1", tags: ["italian", "pasta"])
        ]

        let viewModel = RecipeFormViewModel(
            recipe: nil,
            title: "",
            ingredientFields: [""],
            instructionFields: [""],
            servings: "",
            prepTime: "",
            cookTime: "",
            cuisine: "",
            notes: ""
        )

        let suggestions = viewModel.getTagSuggestions(tagInput: "", allRecipes: allRecipes)

        #expect(suggestions.isEmpty)
    }

    @Test("Tag suggestions returns matching tags")
    func testTagSuggestionsMatching() {
        let allRecipes = [
            RecipeTestFixtures.createRecipe(title: "R1", tags: ["italian", "pasta"]),
            RecipeTestFixtures.createRecipe(title: "R2", tags: ["italian", "pizza"]),
            RecipeTestFixtures.createRecipe(title: "R3", tags: ["indian"])
        ]

        let viewModel = RecipeFormViewModel(
            recipe: nil,
            title: "",
            ingredientFields: [""],
            instructionFields: [""],
            servings: "",
            prepTime: "",
            cookTime: "",
            cuisine: "",
            notes: ""
        )

        let suggestions = viewModel.getTagSuggestions(tagInput: "ita", allRecipes: allRecipes)

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

        let viewModel = RecipeFormViewModel(
            recipe: nil,
            title: "",
            ingredientFields: [""],
            instructionFields: [""],
            servings: "",
            prepTime: "",
            cookTime: "",
            cuisine: "",
            notes: ""
        )

        let suggestions = viewModel.getTagSuggestions(tagInput: "ind", allRecipes: allRecipes)

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

        let viewModel = RecipeFormViewModel(
            recipe: nil,
            title: "",
            ingredientFields: [""],
            instructionFields: [""],
            servings: "",
            prepTime: "",
            cookTime: "",
            cuisine: "",
            notes: ""
        )

        let suggestions = viewModel.getTagSuggestions(tagInput: "italian", allRecipes: allRecipes)

        #expect(suggestions.isEmpty)
    }

    @Test("Tag suggestions handles comma-separated input")
    func testTagSuggestionsCommaSeparated() {
        let allRecipes = [
            RecipeTestFixtures.createRecipe(title: "R1", tags: ["italian", "quick"])
        ]

        let viewModel = RecipeFormViewModel(
            recipe: nil,
            title: "",
            ingredientFields: [""],
            instructionFields: [""],
            servings: "",
            prepTime: "",
            cookTime: "",
            cuisine: "",
            notes: ""
        )

        let suggestions = viewModel.getTagSuggestions(tagInput: "quick, ita", allRecipes: allRecipes)

        #expect(suggestions.count == 1)
        #expect(suggestions[0].0 == "italian")
    }
}
