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
              You are a recipe structuring assistant. Convert voice transcripts
              into well-structured recipes. Extract ingredients as complete phrases
              (e.g., "2 cups all-purpose flour"). Number instructions sequentially.
              If prep time, cook time, servings, or cuisine are mentioned, extract them.
              If not mentioned, leave them nil/empty.
              """
        }
        
        let response = try await session.respond(to: transcript, generating: VoiceRecipe.self)
        return response.content
    }
}
