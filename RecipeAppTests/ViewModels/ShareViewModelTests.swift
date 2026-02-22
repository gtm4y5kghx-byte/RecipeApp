import Testing
import SwiftData
@testable import RecipeApp

@MainActor
struct ShareViewModelTests {

    // MARK: - Add Recipe Tests

    @Test("Add recipe from import with all data")
    func testAddRecipeWithAllData() throws {
        let container = try ModelContainer(
            for: Schema([
                Recipe.self, Ingredient.self, Step.self, NutritionInfo.self,
                ShoppingList.self, ShoppingListItem.self, MealPlanEntry.self
            ]),
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let tracker = CompletionTracker()
        let vm = ShareViewModel(
            dismiss: {},
            complete: { tracker.called = true },
            modelContainer: container
        )

        let nutritionData = NutritionImportData(
            calories: 500,
            carbohydrates: 60.0,
            protein: 25.0,
            fat: 15.0,
            fiber: 5.0,
            sodium: 800.0,
            sugar: 10.0
        )

        let importData = RecipeTestFixtures.createImportData(
            title: "Imported Pasta",
            description: "Delicious pasta dish",
            sourceURL: "https://example.com/pasta",
            prepTime: 10,
            cookTime: 20,
            servings: 4,
            cuisine: "Italian",
            ingredients: ["200g pasta", "2 tbsp olive oil"],
            instructions: ["Boil water", "Cook pasta"],
            nutrition: nutritionData
        )

        vm.state = .preview(recipe: importData, alreadyImported: false)
        vm.addRecipe()

        let recipes = try container.mainContext.fetch(FetchDescriptor<Recipe>())

        #expect(recipes.count == 1)
        let recipe = recipes[0]

        #expect(recipe.title == "Imported Pasta")
        #expect(recipe.sourceType == .web_imported)
        #expect(recipe.sourceURL == "https://example.com/pasta")
        #expect(recipe.notes == "Delicious pasta dish")
        #expect(recipe.prepTime == 10)
        #expect(recipe.cookTime == 20)
        #expect(recipe.servings == 4)
        #expect(recipe.cuisine == "Italian")

        let sortedIngredients = recipe.sortedIngredients
        #expect(sortedIngredients.count == 2)
        #expect(sortedIngredients[0].item == "200g pasta")
        #expect(sortedIngredients[0].order == 0)
        #expect(sortedIngredients[1].item == "2 tbsp olive oil")
        #expect(sortedIngredients[1].order == 1)

        let sortedInstructions = recipe.sortedInstructions
        #expect(sortedInstructions.count == 2)
        #expect(sortedInstructions[0].instruction == "Boil water")
        #expect(sortedInstructions[0].order == 0)
        #expect(sortedInstructions[1].instruction == "Cook pasta")
        #expect(sortedInstructions[1].order == 1)

        #expect(recipe.nutrition != nil)
        #expect(recipe.nutrition?.calories == 500)
        #expect(recipe.nutrition?.carbohydrates == 60.0)
        #expect(recipe.nutrition?.protein == 25.0)
        #expect(recipe.nutrition?.fat == 15.0)
        #expect(recipe.nutrition?.fiber == 5.0)
        #expect(recipe.nutrition?.sodium == 800.0)
        #expect(recipe.nutrition?.sugar == 10.0)

        #expect(tracker.called == true)
    }

    @Test("Add recipe from import with minimal data")
    func testAddRecipeWithMinimalData() throws {
        let container = try ModelContainer(
            for: Schema([
                Recipe.self, Ingredient.self, Step.self, NutritionInfo.self,
                ShoppingList.self, ShoppingListItem.self, MealPlanEntry.self
            ]),
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let tracker = CompletionTracker()
        let vm = ShareViewModel(
            dismiss: {},
            complete: { tracker.called = true },
            modelContainer: container
        )

        let importData = RecipeTestFixtures.createImportData(
            title: "Simple Recipe",
            ingredients: ["flour"],
            instructions: ["Mix"],
            nutrition: nil
        )

        vm.state = .preview(recipe: importData, alreadyImported: false)
        vm.addRecipe()

        let recipes = try container.mainContext.fetch(FetchDescriptor<Recipe>())

        #expect(recipes.count == 1)
        let recipe = recipes[0]
        #expect(recipe.title == "Simple Recipe")
        #expect(recipe.sourceType == .web_imported)
        #expect(recipe.sortedIngredients.count == 1)
        #expect(recipe.sortedInstructions.count == 1)
        #expect(recipe.nutrition == nil)
        #expect(recipe.sourceURL == nil)
        #expect(recipe.servings == nil)

        #expect(tracker.called == true)
    }

    @Test("Add recipe calls extensionComplete on success")
    func testAddRecipeCallsComplete() throws {
        let container = try ModelContainer(
            for: Schema([
                Recipe.self, Ingredient.self, Step.self, NutritionInfo.self,
                ShoppingList.self, ShoppingListItem.self, MealPlanEntry.self
            ]),
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let tracker = CompletionTracker()
        let vm = ShareViewModel(
            dismiss: {},
            complete: { tracker.called = true },
            modelContainer: container
        )

        let importData = RecipeTestFixtures.createImportData(
            title: "Test Recipe",
            ingredients: ["egg"],
            instructions: ["Cook"]
        )

        vm.state = .preview(recipe: importData, alreadyImported: false)
        vm.addRecipe()

        #expect(tracker.called == true)
    }

    @Test("Add recipe does nothing when state is not preview")
    func testAddRecipeIgnoresNonPreviewState() throws {
        let container = try ModelContainer(
            for: Schema([
                Recipe.self, Ingredient.self, Step.self, NutritionInfo.self,
                ShoppingList.self, ShoppingListItem.self, MealPlanEntry.self
            ]),
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let tracker = CompletionTracker()
        let vm = ShareViewModel(
            dismiss: {},
            complete: { tracker.called = true },
            modelContainer: container
        )

        vm.state = .loading(message: "Loading...")
        vm.addRecipe()

        let recipes = try container.mainContext.fetch(FetchDescriptor<Recipe>())
        #expect(recipes.isEmpty)
        #expect(tracker.called == false)
    }
}

// MARK: - Helpers

private class CompletionTracker {
    var called = false
}
