import Foundation
import SwiftData

struct RecipeItemGroup: Identifiable {
    let id: UUID
    let recipeName: String
    let items: [ShoppingListItem]
}

@MainActor
@Observable
class ShoppingListViewModel {
    private let service: ShoppingListService
    private let shoppingList: ShoppingList
    private var recipes: [Recipe]

    var error: Error?

    init(modelContext: ModelContext, recipes: [Recipe] = []) throws {
        self.service = ShoppingListService(modelContext: modelContext)
        self.shoppingList = try service.getOrCreateList()
        self.recipes = recipes
    }

    // MARK: - Computed Properties

    var items: [ShoppingListItem] {
        shoppingList.items
    }

    var hasItems: Bool {
        !items.isEmpty
    }

    var hasCheckedItems: Bool {
        items.contains { $0.isChecked }
    }

    var commonIngredientGroups: [String: [ShoppingListItem]] {
        let recipeItems = items.filter { !$0.sourceRecipeIDs.isEmpty }
        let grouped = Dictionary(grouping: recipeItems) { $0.item.lowercased() }
        return grouped.filter { $0.value.count > 1 }
    }

    var recipeGroups: [RecipeItemGroup] {
        let commonNames = Set(commonIngredientGroups.keys)
        let uniqueItems = items.filter {
            !$0.sourceRecipeIDs.isEmpty && !commonNames.contains($0.item.lowercased())
        }

        let recipeNameMap = Dictionary(uniqueKeysWithValues: recipes.map { ($0.id, $0.title) })

        var groups: [UUID: [ShoppingListItem]] = [:]
        for item in uniqueItems {
            if let recipeID = item.sourceRecipeIDs.first {
                groups[recipeID, default: []].append(item)
            }
        }

        return groups.map { recipeID, items in
            RecipeItemGroup(
                id: recipeID,
                recipeName: recipeNameMap[recipeID] ?? "Unknown Recipe",
                items: items
            )
        }.sorted { $0.recipeName < $1.recipeName }
    }

    var manualItems: [ShoppingListItem] {
        items.filter { $0.sourceRecipeIDs.isEmpty }
    }

    // MARK: - Actions

    func toggleChecked(_ item: ShoppingListItem) {
        service.toggleChecked(item)
    }

    func removeItem(_ item: ShoppingListItem) {
        do {
            try service.removeItem(item)
        } catch {
            self.error = error
        }
    }

    func clearCheckedItems() {
        do {
            try service.clearCheckedItems()
        } catch {
            self.error = error
        }
    }

    func clearAllItems() {
        do {
            try service.clearAllItems()
        } catch {
            self.error = error
        }
    }

    func addIngredientsFromRecipe(_ recipe: Recipe) {
        do {
            try service.addIngredientsFromRecipe(recipe)
        } catch {
            self.error = error
        }
    }

    func addManualItem(item: String, quantity: String? = nil, unit: String? = nil) {
        do {
            try service.addManualItem(item: item, quantity: quantity, unit: unit)
        } catch {
            self.error = error
        }
    }

    func updateRecipes(_ recipes: [Recipe]) {
        self.recipes = recipes
    }
}
