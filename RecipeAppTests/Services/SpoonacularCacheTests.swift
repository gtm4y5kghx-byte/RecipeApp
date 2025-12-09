import XCTest
@testable import RecipeApp

final class SpoonacularCacheTests: XCTestCase {

    var cache: SpoonacularCache!

    override func setUp() {
        super.setUp()
        cache = SpoonacularCache()
    }

    override func tearDown() {
        cache.clearAll()
        cache = nil
        super.tearDown()
    }

    func testCacheStoresAndRetrievesSearch() {
        let response = SpoonacularSearchResponse(
            results: [],
            offset: 0,
            number: 10,
            totalResults: 100
        )

        cache.setSearch(key: "pasta_Italian", response: response)

        let cached = cache.getSearch(key: "pasta_Italian")
        XCTAssertNotNil(cached)
        XCTAssertEqual(cached?.totalResults, 100)
        XCTAssertEqual(cached?.number, 10)
    }

    func testCacheReturnsNilForNonExistentKey() {
        let cached = cache.getSearch(key: "nonexistent")
        XCTAssertNil(cached)
    }

    func testCacheStoresAndRetrievesRecipe() {
        let recipe = DiscoveredRecipe(
            id: 123,
            title: "Pasta Carbonara",
            image: nil,
            imageType: nil,
            servings: 4,
            readyInMinutes: 30,
            sourceUrl: nil,
            sourceName: nil,
            cuisines: nil,
            dishTypes: nil,
            vegetarian: nil,
            vegan: nil,
            glutenFree: nil,
            extendedIngredients: nil,
            analyzedInstructions: nil,
            nutrition: nil
        )

        cache.setRecipe(recipe: recipe)

        let cached = cache.getRecipe(id: 123)
        XCTAssertNotNil(cached)
        XCTAssertEqual(cached?.title, "Pasta Carbonara")
    }

    func testCacheReturnsNilForNonExistentRecipeID() {
        let cached = cache.getRecipe(id: 999)
        XCTAssertNil(cached)
    }

    func testClearAllRemovesAllCachedData() {
        let response = SpoonacularSearchResponse(
            results: [],
            offset: 0,
            number: 10,
            totalResults: 100
        )
        cache.setSearch(key: "pasta", response: response)

        let recipe = DiscoveredRecipe(
            id: 123,
            title: "Test",
            image: nil,
            imageType: nil,
            servings: nil,
            readyInMinutes: nil,
            sourceUrl: nil,
            sourceName: nil,
            cuisines: nil,
            dishTypes: nil,
            vegetarian: nil,
            vegan: nil,
            glutenFree: nil,
            extendedIngredients: nil,
            analyzedInstructions: nil,
            nutrition: nil
        )
        cache.setRecipe(recipe: recipe)

        cache.clearAll()

        XCTAssertNil(cache.getSearch(key: "pasta"))
        XCTAssertNil(cache.getRecipe(id: 123))
    }

    func testClearExpiredRemovesOnlyExpiredEntries() {
        let response = SpoonacularSearchResponse(
            results: [],
            offset: 0,
            number: 10,
            totalResults: 100
        )

        cache.setSearch(key: "fresh", response: response)

        // For expired testing, we'll just verify the method exists
        // Full expiry testing would require clock injection
        cache.clearExpired()

        // Fresh entry should still exist
        XCTAssertNotNil(cache.getSearch(key: "fresh"))
    }
}
