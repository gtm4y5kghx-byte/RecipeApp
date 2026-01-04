import Foundation
import SwiftData

@MainActor
class ShoppingListService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func getOrCreateList() throws -> ShoppingList {
        let descriptor = FetchDescriptor<ShoppingList>()
        let existingLists = try modelContext.fetch(descriptor)

        if let existing = existingLists.first {
            return existing
        }

        let newList = ShoppingList()
        modelContext.insert(newList)
        try modelContext.save()
        return newList
    }

    func addIngredientsFromRecipe(_ recipe: Recipe) throws {
        let list = try getOrCreateList()

        for ingredient in recipe.ingredients {
            let item = ShoppingListItem(
                item: ingredient.item,
                quantity: ingredient.quantity.isEmpty ? nil : ingredient.quantity,
                unit: ingredient.unit,
                preparation: ingredient.preparation
            )
            item.sourceRecipeIDs = [recipe.id]
            item.order = list.items.count
            list.items.append(item)
        }

        list.dateModified = Date()
        try modelContext.save()
    }

    func addManualItem(item: String, quantity: String? = nil, unit: String? = nil) throws {
        let list = try getOrCreateList()

        let shoppingItem = ShoppingListItem(
            item: item,
            quantity: quantity,
            unit: unit
        )
        shoppingItem.order = list.items.count
        list.items.append(shoppingItem)

        list.dateModified = Date()
        try modelContext.save()
    }

    func toggleChecked(_ item: ShoppingListItem) {
        item.isChecked.toggle()
        try? modelContext.save()
    }

    func removeItem(_ item: ShoppingListItem) throws {
        let list = try getOrCreateList()
        list.items.removeAll { $0.id == item.id }
        modelContext.delete(item)
        list.dateModified = Date()
        try modelContext.save()
    }

    func clearCheckedItems() throws {
        let list = try getOrCreateList()
        let checkedItems = list.checkedItems

        for item in checkedItems {
            list.items.removeAll { $0.id == item.id }
            modelContext.delete(item)
        }

        if !checkedItems.isEmpty {
            list.dateModified = Date()
            try modelContext.save()
        }
    }

    func clearAllItems() throws {
        let list = try getOrCreateList()

        for item in list.items {
            modelContext.delete(item)
        }
        list.items.removeAll()

        list.dateModified = Date()
        try modelContext.save()
    }
}
