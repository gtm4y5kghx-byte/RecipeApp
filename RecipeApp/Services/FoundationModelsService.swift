import Foundation
import FoundationModels
import SwiftData

@MainActor
class FoundationModelsService {
    
    static var isAvailable: Bool {
        SystemLanguageModel.default.availability == .available
    }
    
    static var unavailabilityReason: String? {
        switch SystemLanguageModel.default.availability {
        case .available:
            return nil
        case .unavailable(let reason):
            switch reason {
            case .appleIntelligenceNotEnabled:
                return "Please enable Apple Intelligence in Settings to use AI features."
            case .deviceNotEligible:
                return "Your device doesn't support AI features. Requires iOS 26 and Apple Intelligence compatible hardware."
            case .modelNotReady:
                return "AI model is downloading. Please try again in a few moments."
            @unknown default:
                return "AI features are unavailable."
            }
        }
    }
    
    func structureRecipe(from transcript: String) async throws -> VoiceRecipe {
        let session = LanguageModelSession {
              """
              You are a recipe structuring assistant. Convert voice transcripts into well-structured recipes.
              
              Extract ALL ingredients mentioned, including:
              - Main ingredients with measurements (e.g., "3 eggs", "2 tablespoons butter")
              - Seasonings and condiments (e.g., "salt", "pepper", "a pinch of salt")
              - Even vague amounts (e.g., "some flour", "a bit of oil")
              
              Format each ingredient as a complete phrase with quantity when mentioned.
              If no quantity is given, just include the ingredient name.
              
              Extract instructions as sequential steps in the order they're mentioned.
              
              Extract structured metadata when mentioned:
              - Servings: "serves X", "makes X servings", "feeds X people"
              - Prep time: "prep time", "preparation time"
              - Cook time: "cook time", "cooking time", "takes X minutes"
              - Cuisine: "Italian", "Mexican", "Thai", etc.
              
              Notes are ONLY for tips, variations, or comments EXPLICITLY mentioned in the transcript.
              Do NOT add your own commentary or infer information not stated.
              Do NOT duplicate structured data (servings, times, cuisine) in notes.
              Leave notes empty if no additional comments were mentioned.
              """
        }
        
        let response = try await session.respond(to: transcript, generating: VoiceRecipe.self)
        return response.content
    }
    
    func transformRecipe(recipe: Recipe, transformation: String) async throws -> RecipeTransformation {
        let recipeContext = buildRecipeContext(recipe)
        
        let session = LanguageModelSession {
              """
              You are a recipe transformation assistant. Transform recipes based on user requests while preserving the essence of the dish.
              
              When transforming:
              - Make the requested changes (vegan, gluten-free, doubled, air fryer, etc.)
              - Keep the recipe recognizable and true to the original intent
              - Provide brief explanations for ingredient substitutions in changeNote
              - Provide brief explanations for modified steps in changeNote
              - Leave changeNote empty for unchanged items
              - Update times and servings if affected by the transformation
              - Create a clear variationNote describing what was changed
              
              Be practical and specific with substitutions and modifications.
              """
        }
        
        let prompt = """
          Original Recipe:
          \(recipeContext)
          
          Transformation Request: \(transformation)
          
          Please transform this recipe according to the request.
          """
        
        let response = try await session.respond(to: prompt, generating: RecipeTransformation.self)
        return response.content
    }
    
    private func buildRecipeContext(_ recipe: Recipe) -> String {
        var context = "Title: \(recipe.title)\n"
        
        if let servings = recipe.servings {
            context += "Servings: \(servings)\n"
        }
        if let prepTime = recipe.prepTime {
            context += "Prep Time: \(prepTime) minutes\n"
        }
        if let cookTime = recipe.cookTime {
            context += "Cook Time: \(cookTime) minutes\n"
        }
        if let cuisine = recipe.cuisine {
            context += "Cuisine: \(cuisine)\n"
        }
        
        context += "\nIngredients:\n"
        for ingredient in recipe.sortedIngredients {
            context += "- \(IngredientFormatter.format(ingredient))\n"
        }
        
        context += "\nInstructions:\n"
        for (index, step) in recipe.sortedInstructions.enumerated() {
            context += "\(index + 1). \(step.instruction)\n"
        }
        
        if let notes = recipe.notes, !notes.isEmpty {
            context += "Notes: \(notes)\n"
        }
        
        return context
    }
}
