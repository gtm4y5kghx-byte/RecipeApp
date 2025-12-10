import Foundation

protocol SpoonacularServiceProtocol {
    func searchRecipes(criteria: SpoonacularSearchCriteria) async throws -> SpoonacularSearchResponse
    func getRecipe(id: Int) async throws -> DiscoveredRecipe
}
