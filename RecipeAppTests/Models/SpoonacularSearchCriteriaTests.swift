import XCTest
@testable import RecipeApp

final class SpoonacularSearchCriteriaTests: XCTestCase {

    func testToQueryItemsBasic() {
        let criteria = SpoonacularSearchCriteria(
            query: "pasta",
            cuisine: "Italian",
            diet: nil,
            maxReadyTime: 30,
            type: nil,
            intolerances: nil,
            includeIngredients: nil,
            excludeIngredients: nil,
            maxCalories: nil,
            minProtein: nil,
            sort: nil
        )

        let items = criteria.toQueryItems(apiKey: "test-key")

        XCTAssertTrue(items.contains(where: { $0.name == "apiKey" && $0.value == "test-key" }))
        XCTAssertTrue(items.contains(where: { $0.name == "query" && $0.value == "pasta" }))
        XCTAssertTrue(items.contains(where: { $0.name == "cuisine" && $0.value == "Italian" }))
        XCTAssertTrue(items.contains(where: { $0.name == "maxReadyTime" && $0.value == "30" }))
    }

    func testToQueryItemsOnlyIncludesNonNilValues() {
        let criteria = SpoonacularSearchCriteria(
            query: "pasta",
            cuisine: nil,
            diet: nil,
            maxReadyTime: nil,
            type: nil,
            intolerances: nil,
            includeIngredients: nil,
            excludeIngredients: nil,
            maxCalories: nil,
            minProtein: nil,
            sort: nil
        )

        let items = criteria.toQueryItems(apiKey: "test-key")

        XCTAssertEqual(items.count, 2) // apiKey + query
        XCTAssertFalse(items.contains(where: { $0.name == "cuisine" }))
        XCTAssertFalse(items.contains(where: { $0.name == "maxReadyTime" }))
    }

    func testToQueryItemsWithAllParameters() {
        let criteria = SpoonacularSearchCriteria(
            query: "pasta",
            cuisine: "Italian",
            diet: "vegetarian",
            maxReadyTime: 30,
            type: "main course",
            intolerances: ["dairy", "gluten"],
            includeIngredients: ["tomato"],
            excludeIngredients: ["nuts"],
            maxCalories: 500,
            minProtein: 20,
            sort: "healthiness"
        )

        let items = criteria.toQueryItems(apiKey: "test-key")

        XCTAssertTrue(items.contains(where: { $0.name == "query" && $0.value == "pasta" }))
        XCTAssertTrue(items.contains(where: { $0.name == "cuisine" && $0.value == "Italian" }))
        XCTAssertTrue(items.contains(where: { $0.name == "diet" && $0.value == "vegetarian" }))
        XCTAssertTrue(items.contains(where: { $0.name == "maxReadyTime" && $0.value == "30" }))
        XCTAssertTrue(items.contains(where: { $0.name == "type" && $0.value == "main course" }))
        XCTAssertTrue(items.contains(where: { $0.name == "sort" && $0.value == "healthiness" }))
    }
}
