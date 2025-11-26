import Foundation
import FoundationModels

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
}
