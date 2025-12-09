import XCTest
@testable import RecipeApp

final class SpoonacularServiceTests: XCTestCase {

    var service: SpoonacularService!
    var mockSession: MockURLSession!

    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        service = SpoonacularService(session: mockSession, apiKey: "test-api-key")
    }

    override func tearDown() {
        service = nil
        mockSession = nil
        super.tearDown()
    }

    @MainActor
    func testSearchRecipesSuccess() async throws {
        let mockResponse = """
        {
            "results": [
                {
                    "id": 123,
                    "title": "Pasta Carbonara",
                    "image": "https://example.com/image.jpg",
                    "imageType": "jpg"
                }
            ],
            "offset": 0,
            "number": 10,
            "totalResults": 1
        }
        """

        mockSession.mockData = mockResponse.data(using: .utf8)
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.spoonacular.com/recipes/complexSearch")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

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

        let response = try await service.searchRecipes(criteria: criteria)

        XCTAssertEqual(response.results.count, 1)
        XCTAssertEqual(response.results[0].id, 123)
        XCTAssertEqual(response.results[0].title, "Pasta Carbonara")
        XCTAssertEqual(response.totalResults, 1)
    }

    func testSearchRecipesNetworkError() async {
        mockSession.mockError = URLError(.notConnectedToInternet)

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

        do {
            _ = try await service.searchRecipes(criteria: criteria)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is URLError)
        }
    }

    @MainActor
    func testGetRecipeSuccess() async throws {
        let mockResponse = """
        {
            "id": 123,
            "title": "Pasta Carbonara",
            "image": "https://example.com/image.jpg",
            "imageType": "jpg",
            "servings": 4,
            "readyInMinutes": 30,
            "sourceUrl": "https://example.com/recipe",
            "sourceName": "Test Source",
            "cuisines": ["Italian"],
            "dishTypes": ["main course"],
            "vegetarian": false,
            "vegan": false,
            "glutenFree": false,
            "extendedIngredients": [
                {
                    "id": 1,
                    "name": "pasta",
                    "original": "1 lb pasta",
                    "measures": {
                        "us": {
                            "amount": 1.0,
                            "unitShort": "lb",
                            "unitLong": "pound"
                        },
                        "metric": {
                            "amount": 453.0,
                            "unitShort": "g",
                            "unitLong": "grams"
                        }
                    }
                }
            ],
            "analyzedInstructions": [
                {
                    "name": "",
                    "steps": [
                        {
                            "number": 1,
                            "step": "Boil water"
                        }
                    ]
                }
            ],
            "nutrition": {
                "nutrients": [
                    {
                        "name": "Calories",
                        "amount": 450.0,
                        "unit": "kcal",
                        "percentOfDailyNeeds": 22.5
                    }
                ]
            }
        }
        """

        mockSession.mockData = mockResponse.data(using: .utf8)
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.spoonacular.com/recipes/123/information")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let recipe = try await service.getRecipe(id: 123)

        XCTAssertEqual(recipe.id, 123)
        XCTAssertEqual(recipe.title, "Pasta Carbonara")
        XCTAssertEqual(recipe.servings, 4)
        XCTAssertEqual(recipe.readyInMinutes, 30)
        XCTAssertEqual(recipe.extendedIngredients?.count, 1)
        XCTAssertEqual(recipe.analyzedInstructions?.count, 1)
        XCTAssertNotNil(recipe.nutrition)
    }

    func testGetRecipeNetworkError() async {
        mockSession.mockError = URLError(.timedOut)

        do {
            _ = try await service.getRecipe(id: 123)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is URLError)
        }
    }
}

// MARK: - Mock URLSession

class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }

        guard let data = mockData, let response = mockResponse else {
            throw URLError(.badServerResponse)
        }

        return (data, response)
    }
}
