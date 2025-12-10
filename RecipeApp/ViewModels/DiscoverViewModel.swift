import Foundation

@Observable
class DiscoverViewModel {
    private let service: SpoonacularServiceProtocol
    private let cache: SpoonacularCache
    private let usageTracker: SpoonacularUsageTracker

    var results: [DiscoveredRecipe] = []
    var selectedRecipe: DiscoveredRecipe?
    var error: Error?
    var isLoading = false

    var diet: DietaryRestriction?
    var intolerances: [FoodIntolerance] = []
    var maxReadyTime: Int?

    init(
        service: SpoonacularServiceProtocol,
        cache: SpoonacularCache,
        usageTracker: SpoonacularUsageTracker
    ) {
        self.service = service
        self.cache = cache
        self.usageTracker = usageTracker
    }

    @MainActor
    func search(query: String, cuisine: String? = nil) async {
        isLoading = true
        error = nil
        results = []

        let cacheKey = buildCacheKey(query: query, cuisine: cuisine)

        if let cachedResponse = cache.getSearch(key: cacheKey) {
            results = cachedResponse.results
            isLoading = false
            return
        }

        guard usageTracker.canSearch else {
            error = SpoonacularError.apiError("Daily search limit reached (5 searches per day)")
            isLoading = false
            return
        }

        do {
            let criteria = SpoonacularSearchCriteria(
                query: query,
                cuisine: cuisine,
                diet: dietForAPI,
                maxReadyTime: maxReadyTime,
                type: nil,
                intolerances: intolerancesForAPI,
                includeIngredients: nil,
                excludeIngredients: nil,
                maxCalories: nil,
                minProtein: nil,
                sort: nil
            )

            let response = try await service.searchRecipes(criteria: criteria)

            usageTracker.recordSearch()
            cache.setSearch(key: cacheKey, response: response)
            results = response.results
        } catch {
            self.error = error
        }

        isLoading = false
    }

    @MainActor
    func getRecipeDetails(id: Int) async {
        isLoading = true
        error = nil
        selectedRecipe = nil

        if let cachedRecipe = cache.getRecipe(id: id) {
            selectedRecipe = cachedRecipe
            isLoading = false
            return
        }

        do {
            let recipe = try await service.getRecipe(id: id)
            cache.setRecipe(recipe: recipe)
            selectedRecipe = recipe
        } catch {
            self.error = error
        }

        isLoading = false
    }

    private func buildCacheKey(query: String, cuisine: String?) -> String {
        var parts: [String] = [query]

        if let cuisine = cuisine {
            parts.append(cuisine)
        }

        if let diet = dietForAPI {
            parts.append(diet)
        }

        if let intolerances = intolerancesForAPI {
            parts.append(intolerances.joined(separator: ","))
        }

        if let maxTime = maxReadyTime {
            parts.append(String(maxTime))
        }

        return parts.joined(separator: "_")
    }

    var dietForAPI: String? {
        diet?.spoonacularValue
    }

    var intolerancesForAPI: [String]? {
        guard !intolerances.isEmpty else { return nil }
        return intolerances.map { $0.spoonacularValue }
    }

    var hasActiveFilters: Bool {
        diet != nil || !intolerances.isEmpty || maxReadyTime != nil
    }

    func clearFilters() {
        diet = nil
        intolerances = []
        maxReadyTime = nil
    }
}
