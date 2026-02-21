import Foundation

struct RecipeHTMLParser {

    // MARK: - Public API

    static func parseRecipe(from html: String, sourceURL: URL?) -> RecipeImportData? {
        guard let jsonLD = extractJSONLD(from: html) else { return nil }
        return buildRecipeImportData(from: jsonLD, sourceURL: sourceURL)
    }

    // MARK: - JSON-LD Extraction

    private static func extractJSONLD(from html: String) -> [String: Any]? {
        let pattern = #"<script[^>]*type="application/ld\+json"[^>]*>(.*?)</script>"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)) else {
            return nil
        }

        guard let jsonRange = Range(match.range(at: 1), in: html) else {
            return nil
        }
        let jsonString = String(html[jsonRange])

        guard let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data) else {
            return nil
        }

        if let array = jsonObject as? [[String: Any]] {
            return array.first { isRecipeType($0) }
        }

        if let dictionary = jsonObject as? [String: Any], isRecipeType(dictionary) {
            return dictionary
        }

        return nil
    }

    private static func isRecipeType(_ object: [String: Any]) -> Bool {
        if let type = object["@type"] as? String {
            return type == "Recipe"
        } else if let types = object["@type"] as? [String] {
            return types.contains("Recipe")
        }
        return false
    }

    // MARK: - Recipe Data Builder

    private static func buildRecipeImportData(
        from jsonLD: [String: Any],
        sourceURL: URL?
    ) -> RecipeImportData {
        let title = jsonLD["name"] as? String ?? "Untitled Recipe"
        let ingredients = parseStringArray(from: jsonLD["recipeIngredient"])
        let instructions = parseStringArray(from: jsonLD["recipeInstructions"])

        let imageURL = parseImageURL(jsonLD["image"])
        let prepTime = parseISODuration(jsonLD["prepTime"] as? String)
        let cookTime = parseISODuration(jsonLD["cookTime"] as? String)
        let totalTime = parseISODuration(jsonLD["totalTime"] as? String)
        let servings = parseServings(jsonLD["recipeYield"])
        let cuisine = parseCuisine(jsonLD["recipeCuisine"])
        let category = parseCategory(jsonLD["recipeCategory"])
        let nutrition = parseNutrition(jsonLD["nutrition"])
        let author = parseAuthor(jsonLD["author"])
        let description = jsonLD["description"] as? String

        return RecipeImportData(
            title: title,
            description: description,
            sourceURL: sourceURL?.absoluteString,
            imageURL: imageURL,
            prepTime: prepTime,
            cookTime: cookTime,
            totalTime: totalTime,
            servings: servings,
            cuisine: cuisine,
            category: category,
            ingredients: ingredients,
            instructions: instructions,
            nutrition: nutrition,
            author: author
        )
    }

    // MARK: - Field Parsers

    private static func parseStringArray(from value: Any?) -> [String] {
        guard let value = value else { return [] }

        if let strings = value as? [String] {
            return strings
        }

        if let objects = value as? [[String: Any]] {
            return objects.compactMap { $0["text"] as? String }
        }

        if let singleString = value as? String {
            return [singleString]
        }

        return []
    }

    private static func parseNutrition(_ value: Any?) -> NutritionImportData? {
        guard let nutritionObject = value as? [String: Any] else {
            return nil
        }

        func extractNumber(_ value: Any?) -> Double? {
            if let doubleValue = value as? Double {
                return doubleValue
            }
            if let intValue = value as? Int {
                return Double(intValue)
            }
            if let stringValue = value as? String {
                let numbers = stringValue.components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted).joined()
                return Double(numbers)
            }
            return nil
        }

        let calories = extractNumber(nutritionObject["calories"]).map { Int($0) }
        let carbs = extractNumber(nutritionObject["carbohydrateContent"])
        let protein = extractNumber(nutritionObject["proteinContent"])
        let fat = extractNumber(nutritionObject["fatContent"])
        let fiber = extractNumber(nutritionObject["fiberContent"])
        let sodium = extractNumber(nutritionObject["sodiumContent"])
        let sugar = extractNumber(nutritionObject["sugarContent"])

        if calories != nil || carbs != nil || protein != nil || fat != nil {
            return NutritionImportData(
                calories: calories,
                carbohydrates: carbs,
                protein: protein,
                fat: fat,
                fiber: fiber,
                sodium: sodium,
                sugar: sugar
            )
        }

        return nil
    }

    private static func parseImageURL(_ value: Any?) -> String? {
        if let imageString = value as? String {
            return imageString
        }

        if let imageObject = value as? [String: Any],
           let url = imageObject["url"] as? String {
            return url
        }

        if let imageArray = value as? [[String: Any]],
           let firstImage = imageArray.first,
           let url = firstImage["url"] as? String {
            return url
        }

        return nil
    }

    private static func parseCuisine(_ value: Any?) -> String? {
        if let cuisineString = value as? String {
            return cuisineString
        }
        if let cuisineArray = value as? [String] {
            return cuisineArray.first
        }
        return nil
    }

    private static func parseCategory(_ value: Any?) -> String? {
        if let categoryString = value as? String {
            return categoryString
        }
        if let categoryArray = value as? [String] {
            return categoryArray.first
        }
        return nil
    }

    private static func parseISODuration(_ duration: String?) -> Int? {
        guard let duration = duration else { return nil }

        var totalMinutes = 0

        if let hoursRegex = try? NSRegularExpression(pattern: #"T(\d+)H"#),
           let match = hoursRegex.firstMatch(in: duration, range: NSRange(duration.startIndex..., in: duration)),
           let range = Range(match.range(at: 1), in: duration),
           let hours = Int(duration[range]) {
            totalMinutes += hours * 60
        }

        if let minutesRegex = try? NSRegularExpression(pattern: #"T\d*H?(\d+)M"#),
           let match = minutesRegex.firstMatch(in: duration, range: NSRange(duration.startIndex..., in: duration)),
           let range = Range(match.range(at: 1), in: duration),
           let minutes = Int(duration[range]) {
            totalMinutes += minutes
        }

        return totalMinutes > 0 ? totalMinutes : nil
    }

    private static func parseServings(_ value: Any?) -> Int? {
        if let intValue = value as? Int {
            return intValue
        }
        if let stringValue = value as? String {
            let numbers = stringValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            return Int(numbers)
        }
        return nil
    }

    private static func parseAuthor(_ value: Any?) -> String? {
        if let stringValue = value as? String {
            return stringValue
        }
        if let authorObject = value as? [String: Any],
           let name = authorObject["name"] as? String {
            return name
        }
        if let authorArray = value as? [[String: Any]],
           let name = authorArray.first?["name"] as? String {
            return name
        }
        return nil
    }
}
