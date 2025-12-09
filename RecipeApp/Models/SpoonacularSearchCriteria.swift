import Foundation

struct SpoonacularSearchCriteria: Codable {
    let query: String?
    let cuisine: String?
    let diet: String?
    let maxReadyTime: Int?
    let type: String?
    let intolerances: [String]?
    let includeIngredients: [String]?
    let excludeIngredients: [String]?
    let maxCalories: Int?
    let minProtein: Int?
    let sort: String?

    func toQueryItems(apiKey: String) -> [URLQueryItem] {
        var items = [URLQueryItem(name: "apiKey", value: apiKey)]

        if let query = query {
            items.append(URLQueryItem(name: "query", value: query))
        }
        if let cuisine = cuisine {
            items.append(URLQueryItem(name: "cuisine", value: cuisine))
        }
        if let diet = diet {
            items.append(URLQueryItem(name: "diet", value: diet))
        }
        if let maxReadyTime = maxReadyTime {
            items.append(URLQueryItem(name: "maxReadyTime", value: String(maxReadyTime)))
        }
        if let type = type {
            items.append(URLQueryItem(name: "type", value: type))
        }
        if let intolerances = intolerances, !intolerances.isEmpty {
            items.append(URLQueryItem(name: "intolerances", value: intolerances.joined(separator: ",")))
        }
        if let includeIngredients = includeIngredients, !includeIngredients.isEmpty {
            items.append(URLQueryItem(name: "includeIngredients", value: includeIngredients.joined(separator: ",")))
        }
        if let excludeIngredients = excludeIngredients, !excludeIngredients.isEmpty {
            items.append(URLQueryItem(name: "excludeIngredients", value: excludeIngredients.joined(separator: ",")))
        }
        if let maxCalories = maxCalories {
            items.append(URLQueryItem(name: "maxCalories", value: String(maxCalories)))
        }
        if let minProtein = minProtein {
            items.append(URLQueryItem(name: "minProtein", value: String(minProtein)))
        }
        if let sort = sort {
            items.append(URLQueryItem(name: "sort", value: sort))
        }

        return items
    }
}
