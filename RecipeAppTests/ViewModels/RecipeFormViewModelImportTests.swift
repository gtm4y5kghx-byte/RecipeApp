import Testing
import Foundation
@testable import RecipeApp

@Suite("RecipeFormViewModel Import Data Tests")
@MainActor
struct RecipeFormViewModelImportTests {

    @Test("Import data populates all fields correctly")
    func testImportDataPopulatesFields() {
        let importData = RecipeImportData(
            title: "Imported Recipe",
            description: "A delicious imported recipe",
            sourceURL: "https://example.com/recipe",
            imageURL: nil,
            prepTime: 10,
            cookTime: 25,
            totalTime: 35,
            servings: 6,
            cuisine: "Mexican",
            category: "Dinner",
            ingredients: ["2 cups flour", "1 tsp salt"],
            instructions: ["Mix ingredients", "Bake at 350F"],
            nutrition: nil,
            author: "Chef Name"
        )

        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: nil, importData: importData, modelContext: modelContext)

        #expect(viewModel.title == "Imported Recipe")
        #expect(viewModel.notes == "A delicious imported recipe")
        #expect(viewModel.prepTime == "10")
        #expect(viewModel.cookTime == "25")
        #expect(viewModel.servings == "6")
        #expect(viewModel.cuisine == "Mexican")
        #expect(viewModel.ingredientFields == ["2 cups flour", "1 tsp salt"])
        #expect(viewModel.instructionFields == ["Mix ingredients", "Bake at 350F"])
    }

    @Test("Import data with empty ingredients creates single empty field")
    func testImportDataEmptyIngredients() {
        let importData = RecipeImportData(
            title: "Minimal Recipe",
            description: nil,
            sourceURL: nil,
            imageURL: nil,
            prepTime: nil,
            cookTime: nil,
            totalTime: nil,
            servings: nil,
            cuisine: nil,
            category: nil,
            ingredients: [],
            instructions: ["Just do it"],
            nutrition: nil,
            author: nil
        )

        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: nil, importData: importData, modelContext: modelContext)

        #expect(viewModel.ingredientFields == [""])
    }

    @Test("Import data with empty instructions creates single empty field")
    func testImportDataEmptyInstructions() {
        let importData = RecipeImportData(
            title: "Minimal Recipe",
            description: nil,
            sourceURL: nil,
            imageURL: nil,
            prepTime: nil,
            cookTime: nil,
            totalTime: nil,
            servings: nil,
            cuisine: nil,
            category: nil,
            ingredients: ["flour"],
            instructions: [],
            nutrition: nil,
            author: nil
        )

        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: nil, importData: importData, modelContext: modelContext)

        #expect(viewModel.instructionFields == [""])
    }

    @Test("Import data with nil optional fields uses empty strings")
    func testImportDataNilOptionalFields() {
        let importData = RecipeImportData(
            title: "Simple Recipe",
            description: nil,
            sourceURL: nil,
            imageURL: nil,
            prepTime: nil,
            cookTime: nil,
            totalTime: nil,
            servings: nil,
            cuisine: nil,
            category: nil,
            ingredients: ["ingredient"],
            instructions: ["instruction"],
            nutrition: nil,
            author: nil
        )

        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: nil, importData: importData, modelContext: modelContext)

        #expect(viewModel.notes == "")
        #expect(viewModel.prepTime == "")
        #expect(viewModel.cookTime == "")
        #expect(viewModel.servings == "")
        #expect(viewModel.cuisine == "")
    }

    @Test("Form has changes returns true for imported recipe with data")
    func testFormHasChangesImportedRecipeWithData() {
        let importData = RecipeImportData(
            title: "Imported Recipe",
            description: "Description",
            sourceURL: nil,
            imageURL: nil,
            prepTime: 10,
            cookTime: 20,
            totalTime: 30,
            servings: 4,
            cuisine: "Italian",
            category: nil,
            ingredients: ["flour", "water"],
            instructions: ["Mix", "Bake"],
            nutrition: nil,
            author: nil
        )

        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: nil, importData: importData, modelContext: modelContext)

        #expect(viewModel.formHasChanges == true)
    }

    @Test("Form has changes returns true when editing imported recipe")
    func testFormHasChangesImportedRecipeWithEdits() {
        let importData = RecipeImportData(
            title: "Imported Recipe",
            description: nil,
            sourceURL: nil,
            imageURL: nil,
            prepTime: nil,
            cookTime: nil,
            totalTime: nil,
            servings: nil,
            cuisine: nil,
            category: nil,
            ingredients: ["flour"],
            instructions: ["Mix"],
            nutrition: nil,
            author: nil
        )

        let modelContext = RecipeTestFixtures.createInMemoryModelContext()
        let viewModel = RecipeFormViewModel(recipe: nil, importData: importData, modelContext: modelContext)

        viewModel.title = "Modified Title"

        #expect(viewModel.formHasChanges == true)
    }
}
