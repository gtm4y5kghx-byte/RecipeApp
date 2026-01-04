import Testing
import Foundation
import SwiftData
@testable import RecipeApp

@Suite("ShoppingListService Integration")
@MainActor
struct ShoppingListServiceIntegration {

    @Test("Print shopping list with grouped items")
    func printShoppingListGrouped() throws {
        let context = RecipeTestFixtures.createInMemoryModelContext()
        let service = ShoppingListService(modelContext: context)

        let cookies = Recipe(title: "Chocolate Chip Cookies", sourceType: .manual)
        cookies.ingredients = [
            Ingredient(quantity: "2", unit: "cups", item: "flour", preparation: "sifted", section: nil),
            Ingredient(quantity: "1", unit: "cup", item: "brown sugar", preparation: "packed", section: nil),
            Ingredient(quantity: "2", unit: "cups", item: "chocolate chips", preparation: nil, section: nil),
            Ingredient(quantity: "1", unit: "tsp", item: "vanilla extract", preparation: nil, section: nil),
        ]
        context.insert(cookies)

        let cake = Recipe(title: "Birthday Cake", sourceType: .manual)
        cake.ingredients = [
            Ingredient(quantity: "3", unit: "cups", item: "flour", preparation: nil, section: nil),
            Ingredient(quantity: "2", unit: "cups", item: "sugar", preparation: nil, section: nil),
            Ingredient(quantity: "1", unit: "cup", item: "brown sugar", preparation: nil, section: nil),
            Ingredient(quantity: "4", unit: "large", item: "eggs", preparation: nil, section: nil),
        ]
        context.insert(cake)

        let salad = Recipe(title: "Caesar Salad", sourceType: .manual)
        salad.ingredients = [
            Ingredient(quantity: "1", unit: "head", item: "romaine lettuce", preparation: "chopped", section: nil),
            Ingredient(quantity: "1/2", unit: "cup", item: "parmesan cheese", preparation: "shaved", section: nil),
            Ingredient(quantity: "1", unit: "cup", item: "croutons", preparation: nil, section: nil),
        ]
        context.insert(salad)

        try service.addIngredientsFromRecipe(cookies)
        try service.addIngredientsFromRecipe(cake)
        try service.addIngredientsFromRecipe(salad)

        try service.addManualItem(item: "paper towels", quantity: "2", unit: "rolls")
        try service.addManualItem(item: "dish soap")

        let list = try service.getOrCreateList()

        print("\n" + String(repeating: "=", count: 50))
        print("SHOPPING LIST")
        print(String(repeating: "=", count: 50))

        let commonItems = list.items.filter { $0.isCommonIngredient }
        let recipeItems = list.items.filter { $0.sourceRecipeIDs.count == 1 }
        let manualItems = list.items.filter { $0.isManualItem }

        if !commonItems.isEmpty {
            print("\n--- Common Ingredients ---")
            for item in commonItems {
                let checkbox = item.isChecked ? "[x]" : "[ ]"
                print("\(checkbox) \(item.displayText) (from \(item.sourceRecipeIDs.count) recipes)")
            }
        }

        if !recipeItems.isEmpty {
            var recipeGroups: [UUID: [ShoppingListItem]] = [:]
            for item in recipeItems {
                if let recipeID = item.sourceRecipeIDs.first {
                    recipeGroups[recipeID, default: []].append(item)
                }
            }

            let recipes = [cookies, cake, salad]
            let recipeNames = Dictionary(uniqueKeysWithValues: recipes.map { ($0.id, $0.title) })

            for (recipeID, items) in recipeGroups {
                let recipeName = recipeNames[recipeID] ?? "Unknown Recipe"
                print("\n--- \(recipeName) ---")
                for item in items {
                    let checkbox = item.isChecked ? "[x]" : "[ ]"
                    print("\(checkbox) \(item.displayText)")
                }
            }
        }

        if !manualItems.isEmpty {
            print("\n--- Other ---")
            for item in manualItems {
                let checkbox = item.isChecked ? "[x]" : "[ ]"
                print("\(checkbox) \(item.displayText)")
            }
        }

        print("\n" + String(repeating: "=", count: 50))
        print("Total items: \(list.items.count)")
        print(String(repeating: "=", count: 50) + "\n")

        #expect(list.items.count == 13)
    }
}
