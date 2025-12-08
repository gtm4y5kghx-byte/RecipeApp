import Foundation

@MainActor
class ClaudeRecipeTransformationService {

    private let claudeClient: ClaudeAPIClient

    init() {
        self.claudeClient = ClaudeAPIClient(apiKey: Config.claudeAPIKey)
    }

    func transformRecipe(recipe: Recipe, transformation: String) async throws -> RecipeTransformation {
        let recipeContext = RecipeContextFormatter.format(recipe)

        let systemPrompt = """
        You are a recipe transformation assistant. Transform recipes based on user requests while preserving the essence of the dish.

        CRITICAL RULES - Follow these exactly:
        1. Return ONLY raw JSON - no markdown, no ```json blocks, no explanation text
        2. Your entire response must be valid JSON that can be directly parsed
        3. DO NOT change the cooking method unless explicitly requested (e.g., don't convert raw to pre-cooked)
        4. When doubling/halving: multiply ALL quantities and servings by EXACTLY the same number
        5. When converting to air fryer: reduce oil to minimal spray, adjust temperature 25°F lower, keep ingredients raw
        6. When making vegan/gluten-free: ONLY substitute the non-compliant ingredients
        7. Provide brief explanations for ingredient substitutions in changeNote
        8. Leave changeNote as empty string for unchanged items
        9. Calculate servings mathematically (e.g., 12 servings doubled = 24 servings exactly)

        JSON structure:
        {
          "title": "string",
          "variationNote": "string",
          "notes": "string or null",
          "prepTime": number or null,
          "cookTime": number or null,
          "servings": number or null,
          "cuisine": "string or null",
          "ingredients": [
            {"text": "string", "changeNote": "string or empty string"}
          ],
          "instructions": [
            {"text": "string", "changeNote": "string or empty string"}
          ]
        }
        """

        let userPrompt = """
        Original Recipe:
        \(recipeContext)

        Transformation Request: \(transformation)

        IMPORTANT: If doubling, multiply servings by exactly 2. If halving, divide by exactly 2.
        Return only the JSON transformation, no other text.
        """

        let responseText = try await claudeClient.sendMessage(prompt: userPrompt, systemPrompt: systemPrompt)

        // Clean response using existing extension
        let cleanedJSON = responseText.strippingMarkdownCodeFences()

        // Parse JSON response manually since RecipeTransformation is @Generable, not Codable
        let jsonData = cleanedJSON.data(using: .utf8)!
        let json = try JSONSerialization.jsonObject(with: jsonData) as! [String: Any]

        let title = json["title"] as! String
        let variationNote = json["variationNote"] as! String
        let notes = json["notes"] as? String
        let prepTime = json["prepTime"] as? Int
        let cookTime = json["cookTime"] as? Int
        let servings = json["servings"] as? Int
        let cuisine = json["cuisine"] as? String

        let ingredientsJSON = json["ingredients"] as! [[String: Any]]
        let ingredients = ingredientsJSON.map { ingredientJSON in
            TransformedIngredient(
                text: ingredientJSON["text"] as! String,
                changeNote: ingredientJSON["changeNote"] as? String
            )
        }

        let instructionsJSON = json["instructions"] as! [[String: Any]]
        let instructions = instructionsJSON.map { instructionJSON in
            TransformedInstruction(
                text: instructionJSON["text"] as! String,
                changeNote: instructionJSON["changeNote"] as? String
            )
        }

        return RecipeTransformation(
            title: title,
            variationNote: variationNote,
            notes: notes,
            prepTime: prepTime,
            cookTime: cookTime,
            servings: servings,
            cuisine: cuisine,
            ingredients: ingredients,
            instructions: instructions
        )
    }
}
