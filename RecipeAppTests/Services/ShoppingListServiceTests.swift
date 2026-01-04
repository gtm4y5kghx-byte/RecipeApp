import Testing
import Foundation
import SwiftData
@testable import RecipeApp

@Suite("ShoppingListService Tests")
@MainActor
struct ShoppingListServiceTests {

    // MARK: - Get or Create List

    @Test("getOrCreateList creates new list when none exists")
    func testGetOrCreateListCreatesNew() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = ShoppingListService(modelContext: context)

        let list = try service.getOrCreateList()

        #expect(list.items.isEmpty)
    }

    @Test("getOrCreateList returns existing list")
    func testGetOrCreateListReturnsExisting() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = ShoppingListService(modelContext: context)

        let firstList = try service.getOrCreateList()
        let firstID = firstList.id

        let secondList = try service.getOrCreateList()

        #expect(secondList.id == firstID)
    }

    // MARK: - Add Ingredients from Recipe

    @Test("addIngredientsFromRecipe adds all ingredients")
    func testAddIngredientsFromRecipe() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = ShoppingListService(modelContext: context)

        let recipe = Recipe(title: "Test Recipe", sourceType: .manual)
        recipe.ingredients = [
            Ingredient(quantity: "2", unit: "cups", item: "flour", preparation: "sifted", section: nil),
            Ingredient(quantity: "1", unit: "tsp", item: "salt", preparation: nil, section: nil),
        ]
        context.insert(recipe)

        try service.addIngredientsFromRecipe(recipe)
        let list = try service.getOrCreateList()

        #expect(list.items.count == 2)
        #expect(list.items.contains { $0.item == "flour" })
        #expect(list.items.contains { $0.item == "salt" })
    }

    @Test("addIngredientsFromRecipe preserves ingredient details")
    func testAddIngredientsFromRecipePreservesDetails() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = ShoppingListService(modelContext: context)

        let recipe = Recipe(title: "Test Recipe", sourceType: .manual)
        recipe.ingredients = [
            Ingredient(quantity: "2", unit: "cups", item: "flour", preparation: "sifted", section: nil),
        ]
        context.insert(recipe)

        try service.addIngredientsFromRecipe(recipe)
        let list = try service.getOrCreateList()

        let flourItem = list.items.first { $0.item == "flour" }
        #expect(flourItem?.quantity == "2")
        #expect(flourItem?.unit == "cups")
        #expect(flourItem?.preparation == "sifted")
    }

    @Test("addIngredientsFromRecipe tracks source recipe ID")
    func testAddIngredientsFromRecipeTracksSource() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = ShoppingListService(modelContext: context)

        let recipe = Recipe(title: "Test Recipe", sourceType: .manual)
        recipe.ingredients = [
            Ingredient(quantity: "1", unit: "cup", item: "sugar", preparation: nil, section: nil),
        ]
        context.insert(recipe)

        try service.addIngredientsFromRecipe(recipe)
        let list = try service.getOrCreateList()

        let sugarItem = list.items.first { $0.item == "sugar" }
        #expect(sugarItem?.sourceRecipeIDs.contains(recipe.id) == true)
    }

    @Test("addIngredientsFromRecipe creates separate items from multiple recipes")
    func testAddIngredientsFromMultipleRecipes() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = ShoppingListService(modelContext: context)

        let recipe1 = Recipe(title: "Cookies", sourceType: .manual)
        recipe1.ingredients = [
            Ingredient(quantity: "2", unit: "cups", item: "flour", preparation: nil, section: nil),
        ]
        context.insert(recipe1)

        let recipe2 = Recipe(title: "Cake", sourceType: .manual)
        recipe2.ingredients = [
            Ingredient(quantity: "3", unit: "cups", item: "flour", preparation: nil, section: nil),
        ]
        context.insert(recipe2)

        try service.addIngredientsFromRecipe(recipe1)
        try service.addIngredientsFromRecipe(recipe2)

        let list = try service.getOrCreateList()

        // Should have 2 separate flour items (no aggregation)
        let flourItems = list.items.filter { $0.item == "flour" }
        #expect(flourItems.count == 2)
    }

    // MARK: - Add Manual Item

    @Test("addManualItem adds item with no source")
    func testAddManualItem() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = ShoppingListService(modelContext: context)

        try service.addManualItem(item: "paper towels", quantity: "2", unit: "rolls")
        let list = try service.getOrCreateList()

        #expect(list.items.count == 1)
        let item = list.items.first
        #expect(item?.item == "paper towels")
        #expect(item?.quantity == "2")
        #expect(item?.unit == "rolls")
        #expect(item?.sourceRecipeIDs.isEmpty == true)
        #expect(item?.isManualItem == true)
    }

    @Test("addManualItem with minimal info")
    func testAddManualItemMinimal() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = ShoppingListService(modelContext: context)

        try service.addManualItem(item: "bananas")
        let list = try service.getOrCreateList()

        #expect(list.items.count == 1)
        let item = list.items.first
        #expect(item?.item == "bananas")
        #expect(item?.quantity == nil)
        #expect(item?.unit == nil)
    }

    // MARK: - Toggle Checked

    @Test("toggleChecked toggles item state")
    func testToggleChecked() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = ShoppingListService(modelContext: context)

        try service.addManualItem(item: "milk")
        let list = try service.getOrCreateList()
        let item = list.items.first!

        #expect(item.isChecked == false)

        service.toggleChecked(item)
        #expect(item.isChecked == true)

        service.toggleChecked(item)
        #expect(item.isChecked == false)
    }

    // MARK: - Remove Item

    @Test("removeItem removes from list")
    func testRemoveItem() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = ShoppingListService(modelContext: context)

        try service.addManualItem(item: "milk")
        try service.addManualItem(item: "eggs")
        let list = try service.getOrCreateList()

        #expect(list.items.count == 2)

        let milkItem = list.items.first { $0.item == "milk" }!
        try service.removeItem(milkItem)

        #expect(list.items.count == 1)
        #expect(list.items.first?.item == "eggs")
    }

    // MARK: - Clear Checked Items

    @Test("clearCheckedItems removes only checked items")
    func testClearCheckedItems() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = ShoppingListService(modelContext: context)

        try service.addManualItem(item: "milk")
        try service.addManualItem(item: "eggs")
        try service.addManualItem(item: "bread")

        let list = try service.getOrCreateList()
        let milkItem = list.items.first { $0.item == "milk" }!
        let breadItem = list.items.first { $0.item == "bread" }!
        milkItem.isChecked = true
        breadItem.isChecked = true

        try service.clearCheckedItems()

        #expect(list.items.count == 1)
        #expect(list.items.first?.item == "eggs")
    }

    @Test("clearCheckedItems does nothing when no checked items")
    func testClearCheckedItemsNoneChecked() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = ShoppingListService(modelContext: context)

        try service.addManualItem(item: "milk")
        try service.addManualItem(item: "eggs")

        let list = try service.getOrCreateList()
        #expect(list.items.count == 2)

        try service.clearCheckedItems()

        #expect(list.items.count == 2)
    }

    // MARK: - Clear All Items

    @Test("clearAllItems removes all items")
    func testClearAllItems() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = ShoppingListService(modelContext: context)

        try service.addManualItem(item: "milk")
        try service.addManualItem(item: "eggs")
        try service.addManualItem(item: "bread")

        let list = try service.getOrCreateList()
        #expect(list.items.count == 3)

        try service.clearAllItems()

        #expect(list.items.isEmpty)
    }

    @Test("clearAllItems works on empty list")
    func testClearAllItemsEmptyList() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = ShoppingListService(modelContext: context)

        let list = try service.getOrCreateList()
        #expect(list.items.isEmpty)

        try service.clearAllItems()

        #expect(list.items.isEmpty)
    }
}
