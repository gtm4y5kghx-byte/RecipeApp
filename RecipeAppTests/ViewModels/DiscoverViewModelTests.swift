import XCTest
@testable import RecipeApp

@MainActor
final class DiscoverViewModelTests: XCTestCase {

    var viewModel: DiscoverViewModel!
    var mockService: MockSpoonacularService!
    var mockCache: SpoonacularCache!
    var mockTracker: SpoonacularUsageTracker!

    override func setUp() {
        super.setUp()
        mockService = MockSpoonacularService()
        mockCache = SpoonacularCache()
        mockTracker = SpoonacularUsageTracker()
        mockTracker.reset()

        viewModel = DiscoverViewModel(
            service: mockService,
            cache: mockCache,
            usageTracker: mockTracker
        )
    }

    override func tearDown() {
        mockTracker.reset()
        mockCache.clearAll()
        viewModel = nil
        mockService = nil
        mockCache = nil
        mockTracker = nil
        super.tearDown()
    }

    func testSearchUsesCache() async {
        let cachedResponse = SpoonacularSearchResponse(
            results: [
                DiscoveredRecipe(
                    id: 999,
                    title: "Cached Recipe",
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
            ],
            offset: 0,
            number: 10,
            totalResults: 1
        )

        mockCache.setSearch(key: "pasta", response: cachedResponse)

        await viewModel.search(query: "pasta")

        XCTAssertEqual(viewModel.results.count, 1)
        XCTAssertEqual(viewModel.results[0].title, "Cached Recipe")
        XCTAssertFalse(mockService.searchWasCalled)
        XCTAssertEqual(mockTracker.searchesUsedToday, 0)
    }

    func testSearchCallsServiceWhenNoCacheHit() async {
        mockService.mockSearchResponse = SpoonacularSearchResponse(
            results: [
                DiscoveredRecipe(
                    id: 123,
                    title: "Fresh Recipe",
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
            ],
            offset: 0,
            number: 10,
            totalResults: 1
        )

        await viewModel.search(query: "pasta")

        XCTAssertEqual(viewModel.results.count, 1)
        XCTAssertEqual(viewModel.results[0].title, "Fresh Recipe")
        XCTAssertTrue(mockService.searchWasCalled)
        XCTAssertEqual(mockTracker.searchesUsedToday, 1)
    }

    func testSearchRespectsUsageLimit() async {
        for _ in 0..<5 {
            mockTracker.recordSearch()
        }

        await viewModel.search(query: "pasta")

        XCTAssertTrue(viewModel.results.isEmpty)
        XCTAssertFalse(mockService.searchWasCalled)
        XCTAssertNotNil(viewModel.error)
    }

    func testSearchHandlesServiceError() async {
        mockService.shouldThrowError = true

        await viewModel.search(query: "pasta")

        XCTAssertTrue(viewModel.results.isEmpty)
        XCTAssertNotNil(viewModel.error)
        XCTAssertEqual(mockTracker.searchesUsedToday, 0)
    }

    func testGetRecipeDetails() async {
        mockService.mockRecipeResponse = DiscoveredRecipe(
            id: 123,
            title: "Full Recipe",
            image: nil,
            imageType: nil,
            servings: 4,
            readyInMinutes: 30,
            sourceUrl: nil,
            sourceName: nil,
            cuisines: ["Italian"],
            dishTypes: nil,
            vegetarian: nil,
            vegan: nil,
            glutenFree: nil,
            extendedIngredients: nil,
            analyzedInstructions: nil,
            nutrition: nil
        )

        await viewModel.getRecipeDetails(id: 123)

        XCTAssertNotNil(viewModel.selectedRecipe)
        XCTAssertEqual(viewModel.selectedRecipe?.title, "Full Recipe")
        XCTAssertEqual(viewModel.selectedRecipe?.servings, 4)
    }

    func testGetRecipeDetailsHandlesError() async {
        mockService.shouldThrowError = true

        await viewModel.getRecipeDetails(id: 123)

        XCTAssertNil(viewModel.selectedRecipe)
        XCTAssertNotNil(viewModel.error)
    }

    // MARK: - Filter Tests

    func testSetDiet() {
        viewModel.diet = .vegetarian

        XCTAssertEqual(viewModel.diet, .vegetarian)
    }

    func testSetIntolerances() {
        viewModel.intolerances = [.dairy, .gluten]

        XCTAssertEqual(viewModel.intolerances.count, 2)
        XCTAssertTrue(viewModel.intolerances.contains(.dairy))
        XCTAssertTrue(viewModel.intolerances.contains(.gluten))
    }

    func testSetMaxReadyTime() {
        viewModel.maxReadyTime = 30

        XCTAssertEqual(viewModel.maxReadyTime, 30)
    }

    func testDietForAPIReturnsSpoonacularValue() {
        viewModel.diet = .vegetarian

        XCTAssertEqual(viewModel.dietForAPI, "Vegetarian")
    }

    func testDietForAPIReturnsNilWhenNoDiet() {
        viewModel.diet = nil

        XCTAssertNil(viewModel.dietForAPI)
    }

    func testIntolerancesForAPIReturnsArray() {
        viewModel.intolerances = [.dairy, .peanut, .shellfish]

        let result = viewModel.intolerancesForAPI

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 3)
        XCTAssertTrue(result?.contains("Dairy") == true)
        XCTAssertTrue(result?.contains("Peanut") == true)
        XCTAssertTrue(result?.contains("Shellfish") == true)
    }

    func testIntolerancesForAPIReturnsNilWhenEmpty() {
        viewModel.intolerances = []

        XCTAssertNil(viewModel.intolerancesForAPI)
    }

    func testHasActiveFiltersReturnsTrueWithDiet() {
        viewModel.diet = .vegan

        XCTAssertTrue(viewModel.hasActiveFilters)
    }

    func testHasActiveFiltersReturnsTrueWithIntolerances() {
        viewModel.intolerances = [.dairy]

        XCTAssertTrue(viewModel.hasActiveFilters)
    }

    func testHasActiveFiltersReturnsTrueWithMaxReadyTime() {
        viewModel.maxReadyTime = 30

        XCTAssertTrue(viewModel.hasActiveFilters)
    }

    func testHasActiveFiltersReturnsFalseWhenEmpty() {
        XCTAssertFalse(viewModel.hasActiveFilters)
    }

    func testClearFiltersResetsAllFilters() {
        viewModel.diet = .vegetarian
        viewModel.intolerances = [.dairy, .gluten]
        viewModel.maxReadyTime = 30

        viewModel.clearFilters()

        XCTAssertNil(viewModel.diet)
        XCTAssertTrue(viewModel.intolerances.isEmpty)
        XCTAssertNil(viewModel.maxReadyTime)
    }

    func testSearchWithDietFilter() async {
        viewModel.diet = .vegetarian

        mockService.mockSearchResponse = SpoonacularSearchResponse(
            results: [],
            offset: 0,
            number: 10,
            totalResults: 0
        )

        await viewModel.search(query: "pasta")

        XCTAssertTrue(mockService.searchWasCalled)
        XCTAssertEqual(mockService.lastCriteria?.diet, "Vegetarian")
    }

    func testSearchWithIntolerancesFilter() async {
        viewModel.intolerances = [.dairy, .gluten]

        mockService.mockSearchResponse = SpoonacularSearchResponse(
            results: [],
            offset: 0,
            number: 10,
            totalResults: 0
        )

        await viewModel.search(query: "pasta")

        XCTAssertTrue(mockService.searchWasCalled)
        XCTAssertNotNil(mockService.lastCriteria?.intolerances)
        XCTAssertEqual(mockService.lastCriteria?.intolerances?.count, 2)
        XCTAssertTrue(mockService.lastCriteria?.intolerances?.contains("Dairy") == true)
        XCTAssertTrue(mockService.lastCriteria?.intolerances?.contains("Gluten") == true)
    }

    func testSearchWithMaxReadyTimeFilter() async {
        viewModel.maxReadyTime = 30

        mockService.mockSearchResponse = SpoonacularSearchResponse(
            results: [],
            offset: 0,
            number: 10,
            totalResults: 0
        )

        await viewModel.search(query: "pasta")

        XCTAssertTrue(mockService.searchWasCalled)
        XCTAssertEqual(mockService.lastCriteria?.maxReadyTime, 30)
    }

    func testSearchWithAllFilters() async {
        viewModel.diet = .vegetarian
        viewModel.intolerances = [.dairy]
        viewModel.maxReadyTime = 30

        mockService.mockSearchResponse = SpoonacularSearchResponse(
            results: [],
            offset: 0,
            number: 10,
            totalResults: 0
        )

        await viewModel.search(query: "pasta")

        XCTAssertTrue(mockService.searchWasCalled)
        XCTAssertEqual(mockService.lastCriteria?.diet, "Vegetarian")
        XCTAssertEqual(mockService.lastCriteria?.intolerances, ["Dairy"])
        XCTAssertEqual(mockService.lastCriteria?.maxReadyTime, 30)
    }

    func testSearchWithDifferentFiltersCacheSeparately() async {
        mockService.mockSearchResponse = SpoonacularSearchResponse(
            results: [
                DiscoveredRecipe(
                    id: 1,
                    title: "Vegetarian Pasta",
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
            ],
            offset: 0,
            number: 10,
            totalResults: 1
        )

        viewModel.diet = .vegetarian
        await viewModel.search(query: "pasta")
        XCTAssertEqual(viewModel.results.count, 1)
        XCTAssertEqual(mockTracker.searchesUsedToday, 1)

        mockService.searchWasCalled = false
        mockService.mockSearchResponse = SpoonacularSearchResponse(
            results: [
                DiscoveredRecipe(
                    id: 2,
                    title: "Vegan Pasta",
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
            ],
            offset: 0,
            number: 10,
            totalResults: 1
        )

        viewModel.diet = .vegan
        await viewModel.search(query: "pasta")

        XCTAssertTrue(mockService.searchWasCalled)
        XCTAssertEqual(viewModel.results.count, 1)
        XCTAssertEqual(viewModel.results[0].title, "Vegan Pasta")
        XCTAssertEqual(mockTracker.searchesUsedToday, 2)
    }
}

// MARK: - Mock SpoonacularService

class MockSpoonacularService: SpoonacularServiceProtocol {
    var searchWasCalled = false
    var mockSearchResponse: SpoonacularSearchResponse?
    var mockRecipeResponse: DiscoveredRecipe?
    var shouldThrowError = false
    var lastCriteria: SpoonacularSearchCriteria?

    func searchRecipes(criteria: SpoonacularSearchCriteria) async throws -> SpoonacularSearchResponse {
        searchWasCalled = true
        lastCriteria = criteria

        if shouldThrowError {
            throw SpoonacularError.apiError("Mock error")
        }

        guard let response = mockSearchResponse else {
            throw SpoonacularError.apiError("No mock response set")
        }

        return response
    }

    func getRecipe(id: Int) async throws -> DiscoveredRecipe {
        if shouldThrowError {
            throw SpoonacularError.apiError("Mock error")
        }

        guard let recipe = mockRecipeResponse else {
            throw SpoonacularError.apiError("No mock recipe set")
        }

        return recipe
    }
}
