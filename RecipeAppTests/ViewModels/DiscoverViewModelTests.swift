import XCTest
import SwiftData
@testable import RecipeApp

@MainActor
final class DiscoverViewModelTests: XCTestCase {

    var viewModel: DiscoverViewModel!
    var mockService: MockSpoonacularService!
    var mockCache: SpoonacularCache!
    var mockTracker: SpoonacularUsageTracker!
    var modelContext: ModelContext!
    var modelContainer: ModelContainer!

    override func setUp() {
        super.setUp()

        let schema = Schema([Recipe.self, Ingredient.self, Step.self, NutritionInfo.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(for: schema, configurations: config)
        modelContext = ModelContext(modelContainer)

        mockService = MockSpoonacularService()
        mockCache = SpoonacularCache()
        mockTracker = SpoonacularUsageTracker()
        mockTracker.reset()

        viewModel = DiscoverViewModel(
            service: mockService,
            cache: mockCache,
            usageTracker: mockTracker,
            modelContext: modelContext
        )
    }

    override func tearDown() {
        mockTracker.reset()
        mockCache.clearAll()
        viewModel = nil
        mockService = nil
        mockCache = nil
        mockTracker = nil
        modelContext = nil
        modelContainer = nil
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

    // MARK: - Save Recipe Tests

    func testSaveRecipeBasicProperties() throws {
        let discoveredRecipe = DiscoveredRecipe(
            id: 123,
            title: "Spaghetti Carbonara",
            image: nil,
            imageType: nil,
            servings: 4,
            readyInMinutes: 30,
            sourceUrl: "https://example.com/recipe",
            sourceName: "Example Site",
            cuisines: ["Italian"],
            dishTypes: nil,
            vegetarian: false,
            vegan: false,
            glutenFree: false,
            extendedIngredients: nil,
            analyzedInstructions: nil,
            nutrition: nil
        )

        try viewModel.saveRecipe(discoveredRecipe)

        let descriptor = FetchDescriptor<Recipe>()
        let recipes = try modelContext.fetch(descriptor)

        XCTAssertEqual(recipes.count, 1)
        let savedRecipe = recipes[0]
        XCTAssertEqual(savedRecipe.title, "Spaghetti Carbonara")
        XCTAssertEqual(savedRecipe.sourceType, .spoonacular)
        XCTAssertEqual(savedRecipe.servings, 4)
        XCTAssertEqual(savedRecipe.cookTime, 30)
        XCTAssertEqual(savedRecipe.sourceURL, "https://example.com/recipe")
        XCTAssertEqual(savedRecipe.cuisine, "Italian")
        XCTAssertEqual(savedRecipe.notes, "Imported from Example Site")
    }

    func testSaveRecipeWithIngredients() throws {
        let discoveredRecipe = DiscoveredRecipe(
            id: 123,
            title: "Pasta",
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
            extendedIngredients: [
                SpoonacularIngredient(
                    id: 1,
                    name: "spaghetti",
                    original: "200g spaghetti",
                    measures: SpoonacularMeasures(
                        us: SpoonacularMeasure(amount: 7.05, unitShort: "oz", unitLong: "ounces"),
                        metric: SpoonacularMeasure(amount: 200, unitShort: "g", unitLong: "grams")
                    )
                ),
                SpoonacularIngredient(
                    id: 2,
                    name: "bacon",
                    original: "100g bacon",
                    measures: SpoonacularMeasures(
                        us: SpoonacularMeasure(amount: 3.53, unitShort: "oz", unitLong: "ounces"),
                        metric: SpoonacularMeasure(amount: 100, unitShort: "g", unitLong: "grams")
                    )
                )
            ],
            analyzedInstructions: nil,
            nutrition: nil
        )

        try viewModel.saveRecipe(discoveredRecipe)

        let descriptor = FetchDescriptor<Recipe>()
        let recipes = try modelContext.fetch(descriptor)

        XCTAssertEqual(recipes.count, 1)
        let savedRecipe = recipes[0]
        let sortedIngredients = savedRecipe.sortedIngredients
        XCTAssertEqual(sortedIngredients.count, 2)
        XCTAssertEqual(sortedIngredients[0].item, "spaghetti")
        XCTAssertEqual(sortedIngredients[0].quantity, "7.05")
        XCTAssertEqual(sortedIngredients[0].unit, "ounces")
        XCTAssertEqual(sortedIngredients[0].order, 0)
        XCTAssertEqual(sortedIngredients[1].item, "bacon")
        XCTAssertEqual(sortedIngredients[1].order, 1)
    }

    func testSaveRecipeWithInstructions() throws {
        let discoveredRecipe = DiscoveredRecipe(
            id: 123,
            title: "Pasta",
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
            analyzedInstructions: [
                SpoonacularInstruction(
                    name: nil,
                    steps: [
                        SpoonacularStep(number: 1, step: "Boil water"),
                        SpoonacularStep(number: 2, step: "Add pasta"),
                        SpoonacularStep(number: 3, step: "Cook for 10 minutes")
                    ]
                )
            ],
            nutrition: nil
        )

        try viewModel.saveRecipe(discoveredRecipe)

        let descriptor = FetchDescriptor<Recipe>()
        let recipes = try modelContext.fetch(descriptor)

        XCTAssertEqual(recipes.count, 1)
        let savedRecipe = recipes[0]
        let sortedInstructions = savedRecipe.sortedInstructions
        XCTAssertEqual(sortedInstructions.count, 3)
        XCTAssertEqual(sortedInstructions[0].instruction, "Boil water")
        XCTAssertEqual(sortedInstructions[0].order, 0)
        XCTAssertEqual(sortedInstructions[1].instruction, "Add pasta")
        XCTAssertEqual(sortedInstructions[1].order, 1)
        XCTAssertEqual(sortedInstructions[2].instruction, "Cook for 10 minutes")
        XCTAssertEqual(sortedInstructions[2].order, 2)
    }

    func testSaveRecipeWithNutrition() throws {
        let discoveredRecipe = DiscoveredRecipe(
            id: 123,
            title: "Pasta",
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
            nutrition: SpoonacularNutrition(
                nutrients: [
                    SpoonacularNutrient(name: "Calories", amount: 450, unit: "kcal", percentOfDailyNeeds: nil),
                    SpoonacularNutrient(name: "Carbohydrates", amount: 60, unit: "g", percentOfDailyNeeds: nil),
                    SpoonacularNutrient(name: "Protein", amount: 15, unit: "g", percentOfDailyNeeds: nil),
                    SpoonacularNutrient(name: "Fat", amount: 12, unit: "g", percentOfDailyNeeds: nil),
                    SpoonacularNutrient(name: "Fiber", amount: 3, unit: "g", percentOfDailyNeeds: nil),
                    SpoonacularNutrient(name: "Sodium", amount: 500, unit: "mg", percentOfDailyNeeds: nil),
                    SpoonacularNutrient(name: "Sugar", amount: 5, unit: "g", percentOfDailyNeeds: nil)
                ]
            )
        )

        try viewModel.saveRecipe(discoveredRecipe)

        let descriptor = FetchDescriptor<Recipe>()
        let recipes = try modelContext.fetch(descriptor)

        XCTAssertEqual(recipes.count, 1)
        let savedRecipe = recipes[0]
        XCTAssertNotNil(savedRecipe.nutrition)
        XCTAssertEqual(savedRecipe.nutrition?.calories, 450)
        XCTAssertEqual(savedRecipe.nutrition?.carbohydrates, 60)
        XCTAssertEqual(savedRecipe.nutrition?.protein, 15)
        XCTAssertEqual(savedRecipe.nutrition?.fat, 12)
        XCTAssertEqual(savedRecipe.nutrition?.fiber, 3)
        XCTAssertEqual(savedRecipe.nutrition?.sodium, 500)
        XCTAssertEqual(savedRecipe.nutrition?.sugar, 5)
    }

    func testSaveRecipeMultipleTimes() throws {
        let recipe1 = DiscoveredRecipe(
            id: 123,
            title: "Recipe 1",
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

        let recipe2 = DiscoveredRecipe(
            id: 456,
            title: "Recipe 2",
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

        try viewModel.saveRecipe(recipe1)
        try viewModel.saveRecipe(recipe2)

        let descriptor = FetchDescriptor<Recipe>()
        let recipes = try modelContext.fetch(descriptor)

        XCTAssertEqual(recipes.count, 2)
        XCTAssertTrue(recipes.contains(where: { $0.title == "Recipe 1" }))
        XCTAssertTrue(recipes.contains(where: { $0.title == "Recipe 2" }))
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
