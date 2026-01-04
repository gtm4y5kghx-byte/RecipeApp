import XCTest
import SwiftData
@testable import RecipeApp

final class ShoppingListItemTests: XCTestCase {

    // MARK: - Initialization

    func testInitializationWithAllProperties() {
        let item = ShoppingListItem(
            item: "flour",
            quantity: "2",
            unit: "cups",
            preparation: "sifted"
        )

        XCTAssertEqual(item.item, "flour")
        XCTAssertEqual(item.quantity, "2")
        XCTAssertEqual(item.unit, "cups")
        XCTAssertEqual(item.preparation, "sifted")
        XCTAssertFalse(item.isChecked)
        XCTAssertEqual(item.order, 0)
        XCTAssertTrue(item.sourceRecipeIDs.isEmpty)
    }

    func testInitializationWithMinimalProperties() {
        let item = ShoppingListItem(item: "eggs")

        XCTAssertEqual(item.item, "eggs")
        XCTAssertNil(item.quantity)
        XCTAssertNil(item.unit)
        XCTAssertNil(item.preparation)
        XCTAssertFalse(item.isChecked)
    }

    func testInitializationGeneratesUniqueID() {
        let item1 = ShoppingListItem(item: "flour")
        let item2 = ShoppingListItem(item: "flour")

        XCTAssertNotEqual(item1.id, item2.id)
    }

    func testDateAddedDefaultsToNow() {
        let before = Date()
        let item = ShoppingListItem(item: "sugar")
        let after = Date()

        XCTAssertTrue(item.dateAdded >= before)
        XCTAssertTrue(item.dateAdded <= after)
    }

    // MARK: - Source Recipe Tracking

    func testSourceRecipeIDsDefaultsToEmpty() {
        let item = ShoppingListItem(item: "butter")

        XCTAssertTrue(item.sourceRecipeIDs.isEmpty)
    }

    func testAddSourceRecipeID() {
        let item = ShoppingListItem(item: "butter")
        let recipeID = UUID()

        item.sourceRecipeIDs.append(recipeID)

        XCTAssertEqual(item.sourceRecipeIDs.count, 1)
        XCTAssertTrue(item.sourceRecipeIDs.contains(recipeID))
    }

    func testMultipleSourceRecipeIDs() {
        let item = ShoppingListItem(item: "flour")
        let recipeID1 = UUID()
        let recipeID2 = UUID()

        item.sourceRecipeIDs.append(recipeID1)
        item.sourceRecipeIDs.append(recipeID2)

        XCTAssertEqual(item.sourceRecipeIDs.count, 2)
        XCTAssertTrue(item.sourceRecipeIDs.contains(recipeID1))
        XCTAssertTrue(item.sourceRecipeIDs.contains(recipeID2))
    }

    func testIsCommonIngredient() {
        let item = ShoppingListItem(item: "flour")

        // No sources - not common
        XCTAssertFalse(item.isCommonIngredient)

        // One source - not common
        item.sourceRecipeIDs.append(UUID())
        XCTAssertFalse(item.isCommonIngredient)

        // Two sources - common
        item.sourceRecipeIDs.append(UUID())
        XCTAssertTrue(item.isCommonIngredient)
    }

    func testIsManualItem() {
        let item = ShoppingListItem(item: "paper towels")

        // No sources - manual
        XCTAssertTrue(item.isManualItem)

        // Has source - not manual
        item.sourceRecipeIDs.append(UUID())
        XCTAssertFalse(item.isManualItem)
    }

    // MARK: - Checked State

    func testToggleChecked() {
        let item = ShoppingListItem(item: "milk")

        XCTAssertFalse(item.isChecked)

        item.isChecked = true
        XCTAssertTrue(item.isChecked)

        item.isChecked = false
        XCTAssertFalse(item.isChecked)
    }

    // MARK: - Display Text

    func testDisplayTextWithAllComponents() {
        let item = ShoppingListItem(
            item: "flour",
            quantity: "2",
            unit: "cups",
            preparation: "sifted"
        )

        XCTAssertEqual(item.displayText, "2 cups flour, sifted")
    }

    func testDisplayTextWithQuantityAndUnit() {
        let item = ShoppingListItem(
            item: "milk",
            quantity: "1",
            unit: "gallon"
        )

        XCTAssertEqual(item.displayText, "1 gallon milk")
    }

    func testDisplayTextWithQuantityOnly() {
        let item = ShoppingListItem(
            item: "eggs",
            quantity: "12"
        )

        XCTAssertEqual(item.displayText, "12 eggs")
    }

    func testDisplayTextWithItemOnly() {
        let item = ShoppingListItem(item: "salt")

        XCTAssertEqual(item.displayText, "salt")
    }

    func testDisplayTextWithPreparationNoQuantity() {
        let item = ShoppingListItem(
            item: "garlic",
            preparation: "minced"
        )

        XCTAssertEqual(item.displayText, "garlic, minced")
    }
}

// MARK: - ShoppingList Tests

final class ShoppingListTests: XCTestCase {

    func testInitialization() {
        let list = ShoppingList()

        XCTAssertNotNil(list.id)
        XCTAssertTrue(list.items.isEmpty)
    }

    func testDateCreatedDefaultsToNow() {
        let before = Date()
        let list = ShoppingList()
        let after = Date()

        XCTAssertTrue(list.dateCreated >= before)
        XCTAssertTrue(list.dateCreated <= after)
    }

    func testDateModifiedDefaultsToNow() {
        let before = Date()
        let list = ShoppingList()
        let after = Date()

        XCTAssertTrue(list.dateModified >= before)
        XCTAssertTrue(list.dateModified <= after)
    }

    func testAddItem() {
        let list = ShoppingList()
        let item = ShoppingListItem(item: "bread")

        list.items.append(item)

        XCTAssertEqual(list.items.count, 1)
        XCTAssertEqual(list.items.first?.item, "bread")
    }

    func testUncheckedItems() {
        let list = ShoppingList()

        let item1 = ShoppingListItem(item: "milk")
        let item2 = ShoppingListItem(item: "eggs")
        item2.isChecked = true
        let item3 = ShoppingListItem(item: "bread")

        list.items.append(contentsOf: [item1, item2, item3])

        XCTAssertEqual(list.uncheckedItems.count, 2)
        XCTAssertTrue(list.uncheckedItems.contains { $0.item == "milk" })
        XCTAssertTrue(list.uncheckedItems.contains { $0.item == "bread" })
        XCTAssertFalse(list.uncheckedItems.contains { $0.item == "eggs" })
    }

    func testCheckedItems() {
        let list = ShoppingList()

        let item1 = ShoppingListItem(item: "milk")
        item1.isChecked = true
        let item2 = ShoppingListItem(item: "eggs")
        let item3 = ShoppingListItem(item: "bread")
        item3.isChecked = true

        list.items.append(contentsOf: [item1, item2, item3])

        XCTAssertEqual(list.checkedItems.count, 2)
        XCTAssertTrue(list.checkedItems.contains { $0.item == "milk" })
        XCTAssertTrue(list.checkedItems.contains { $0.item == "bread" })
    }

    func testHasItems() {
        let list = ShoppingList()

        XCTAssertFalse(list.hasItems)

        list.items.append(ShoppingListItem(item: "milk"))

        XCTAssertTrue(list.hasItems)
    }

    func testHasCheckedItems() {
        let list = ShoppingList()
        let item = ShoppingListItem(item: "milk")
        list.items.append(item)

        XCTAssertFalse(list.hasCheckedItems)

        item.isChecked = true

        XCTAssertTrue(list.hasCheckedItems)
    }
}
