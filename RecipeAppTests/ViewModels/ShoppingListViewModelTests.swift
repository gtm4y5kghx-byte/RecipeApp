import Testing
import Foundation
import SwiftData
@testable import RecipeApp

@Suite("ShoppingListViewModel Tests")
@MainActor
struct ShoppingListViewModelTests {

    // MARK: - Initial State

    @Test("Initial state has empty items")
    func initialStateEmpty() throws {
        let viewModel = try createViewModel()
        #expect(viewModel.items.isEmpty)
    }

    @Test("Initial state has no error")
    func initialStateNoError() throws {
        let viewModel = try createViewModel()
        #expect(viewModel.error == nil)
    }

    // MARK: - Grouped Items

    @Test("commonIngredientGroups groups items by name")
    func commonIngredientGroups() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = ShoppingListService(modelContext: context)

        let recipe1 = Recipe(title: "Cookies", sourceType: .manual)
        recipe1.ingredients = [Ingredient(quantity: "2", unit: "cups", item: "flour", preparation: nil, section: nil)]
        context.insert(recipe1)

        let recipe2 = Recipe(title: "Cake", sourceType: .manual)
        recipe2.ingredients = [Ingredient(quantity: "3", unit: "cups", item: "flour", preparation: nil, section: nil)]
        context.insert(recipe2)

        try service.addIngredientsFromRecipe(recipe1)
        try service.addIngredientsFromRecipe(recipe2)

        let viewModel = try createViewModel(context: context)

        #expect(viewModel.commonIngredientGroups.count == 1)
        #expect(viewModel.commonIngredientGroups["flour"]?.count == 2)
    }

    @Test("recipeGroups contains only unique recipe items")
    func recipeGroupsUniqueItems() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = ShoppingListService(modelContext: context)

        let recipe1 = Recipe(title: "Cookies", sourceType: .manual)
        recipe1.ingredients = [
            Ingredient(quantity: "2", unit: "cups", item: "flour", preparation: nil, section: nil),
            Ingredient(quantity: "1", unit: "cup", item: "chocolate chips", preparation: nil, section: nil),
        ]
        context.insert(recipe1)

        let recipe2 = Recipe(title: "Cake", sourceType: .manual)
        recipe2.ingredients = [
            Ingredient(quantity: "3", unit: "cups", item: "flour", preparation: nil, section: nil),
            Ingredient(quantity: "2", unit: "cups", item: "sugar", preparation: nil, section: nil),
        ]
        context.insert(recipe2)

        try service.addIngredientsFromRecipe(recipe1)
        try service.addIngredientsFromRecipe(recipe2)

        let viewModel = try createViewModel(context: context, recipes: [recipe1, recipe2])

        #expect(viewModel.recipeGroups.count == 2)

        let cookiesGroup = viewModel.recipeGroups.first { $0.recipeName == "Cookies" }
        #expect(cookiesGroup?.items.count == 1)
        #expect(cookiesGroup?.items.first?.item == "chocolate chips")

        let cakeGroup = viewModel.recipeGroups.first { $0.recipeName == "Cake" }
        #expect(cakeGroup?.items.count == 1)
        #expect(cakeGroup?.items.first?.item == "sugar")
    }

    @Test("manualItems contains only items with no source")
    func manualItemsNoSource() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = ShoppingListService(modelContext: context)

        let recipe = Recipe(title: "Test", sourceType: .manual)
        recipe.ingredients = [Ingredient(quantity: "1", unit: "cup", item: "milk", preparation: nil, section: nil)]
        context.insert(recipe)

        try service.addIngredientsFromRecipe(recipe)
        try service.addManualItem(item: "paper towels")
        try service.addManualItem(item: "soap")

        let viewModel = try createViewModel(context: context)

        #expect(viewModel.manualItems.count == 2)
        #expect(viewModel.manualItems.contains { $0.item == "paper towels" })
        #expect(viewModel.manualItems.contains { $0.item == "soap" })
    }

    // MARK: - Actions

    @Test("toggleChecked toggles item state")
    func toggleChecked() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = ShoppingListService(modelContext: context)
        try service.addManualItem(item: "milk")

        let viewModel = try createViewModel(context: context)
        let item = viewModel.items.first!

        #expect(item.isChecked == false)

        viewModel.toggleChecked(item)
        #expect(item.isChecked == true)
    }

    @Test("removeItem removes from list")
    func removeItem() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = ShoppingListService(modelContext: context)
        try service.addManualItem(item: "milk")
        try service.addManualItem(item: "eggs")

        let viewModel = try createViewModel(context: context)
        #expect(viewModel.items.count == 2)

        let milkItem = viewModel.items.first { $0.item == "milk" }!
        viewModel.removeItem(milkItem)

        #expect(viewModel.items.count == 1)
    }

    @Test("clearCheckedItems removes checked items")
    func clearCheckedItems() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = ShoppingListService(modelContext: context)
        try service.addManualItem(item: "milk")
        try service.addManualItem(item: "eggs")

        let viewModel = try createViewModel(context: context)
        let milkItem = viewModel.items.first { $0.item == "milk" }!
        milkItem.isChecked = true

        viewModel.clearCheckedItems()

        #expect(viewModel.items.count == 1)
        #expect(viewModel.items.first?.item == "eggs")
    }

    @Test("clearAllItems removes all items")
    func clearAllItems() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = ShoppingListService(modelContext: context)
        try service.addManualItem(item: "milk")
        try service.addManualItem(item: "eggs")

        let viewModel = try createViewModel(context: context)
        #expect(viewModel.items.count == 2)

        viewModel.clearAllItems()

        #expect(viewModel.items.isEmpty)
    }

    // MARK: - Add Items

    @Test("addIngredientsFromRecipe adds to list")
    func addIngredientsFromRecipe() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()

        let recipe = Recipe(title: "Test", sourceType: .manual)
        recipe.ingredients = [
            Ingredient(quantity: "1", unit: "cup", item: "flour", preparation: nil, section: nil),
            Ingredient(quantity: "2", unit: "tsp", item: "salt", preparation: nil, section: nil),
        ]
        context.insert(recipe)

        let viewModel = try createViewModel(context: context)
        #expect(viewModel.items.isEmpty)

        viewModel.addIngredientsFromRecipe(recipe)

        #expect(viewModel.items.count == 2)
    }

    @Test("addManualItem adds to list")
    func addManualItem() throws {
        let viewModel = try createViewModel()
        #expect(viewModel.items.isEmpty)

        viewModel.addManualItem(item: "bananas", quantity: "6", unit: nil)

        #expect(viewModel.items.count == 1)
        #expect(viewModel.items.first?.item == "bananas")
    }

    // MARK: - Computed Properties

    @Test("hasItems reflects list state")
    func hasItems() throws {
        let viewModel = try createViewModel()

        #expect(viewModel.hasItems == false)

        viewModel.addManualItem(item: "milk")

        #expect(viewModel.hasItems == true)
    }

    @Test("hasCheckedItems reflects checked state")
    func hasCheckedItems() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = ShoppingListService(modelContext: context)
        try service.addManualItem(item: "milk")

        let viewModel = try createViewModel(context: context)

        #expect(viewModel.hasCheckedItems == false)

        viewModel.items.first?.isChecked = true

        #expect(viewModel.hasCheckedItems == true)
    }

    // MARK: - Helpers

    private func createViewModel(
        context: ModelContext? = nil,
        recipes: [Recipe] = []
    ) throws -> ShoppingListViewModel {
        let ctx = context ?? RecipeTestFixtures.createInMemoryModelContext()
        return try ShoppingListViewModel(modelContext: ctx, recipes: recipes)
    }
}
