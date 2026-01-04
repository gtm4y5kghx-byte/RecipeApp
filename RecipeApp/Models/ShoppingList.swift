import Foundation
import SwiftData

@Model
class ShoppingList {
    var id: UUID
    var dateCreated: Date
    var dateModified: Date
    @Relationship(deleteRule: .cascade) var items: [ShoppingListItem]

    init() {
        self.id = UUID()
        self.dateCreated = Date()
        self.dateModified = Date()
        self.items = []
    }

    var uncheckedItems: [ShoppingListItem] {
        items.filter { !$0.isChecked }
    }

    var checkedItems: [ShoppingListItem] {
        items.filter { $0.isChecked }
    }

    var hasItems: Bool {
        !items.isEmpty
    }

    var hasCheckedItems: Bool {
        items.contains { $0.isChecked }
    }
}

@Model
class ShoppingListItem {
    var id: UUID
    var item: String
    var quantity: String?
    var unit: String?
    var preparation: String?
    var isChecked: Bool
    var order: Int
    var dateAdded: Date
    var sourceRecipeIDs: [UUID]

    init(
        item: String,
        quantity: String? = nil,
        unit: String? = nil,
        preparation: String? = nil
    ) {
        self.id = UUID()
        self.item = item
        self.quantity = quantity
        self.unit = unit
        self.preparation = preparation
        self.isChecked = false
        self.order = 0
        self.dateAdded = Date()
        self.sourceRecipeIDs = []
    }

    var isCommonIngredient: Bool {
        sourceRecipeIDs.count >= 2
    }

    var isManualItem: Bool {
        sourceRecipeIDs.isEmpty
    }

    var displayText: String {
        var components: [String] = []

        if let quantity = quantity {
            if let unit = unit {
                components.append("\(quantity) \(unit)")
            } else {
                components.append(quantity)
            }
        }

        components.append(item)

        var result = components.joined(separator: " ")

        if let preparation = preparation {
            result += ", \(preparation)"
        }

        return result
    }
}
