import Foundation

struct RecipeSearchCriteria: Codable {
    let cuisine: String?
    let maxTotalTime: Int?
    let favoritesOnly: Bool
    let onlyNeverCooked: Bool
    let onlyCookedLongAgo: Bool
    let onlyCookedRecently: Bool
    
    let titleKeywords: [String]
    let ingredientKeywords: [String]
    let notesKeywords: [String]
    
    let combineMode: String  // "and" or "or"
}

struct RecipeSuggestion: Codable, Identifiable {
    let id: UUID
    let recipeID: UUID
    let aiGeneratedReason: String
    let generatedAt: Date
    
    init(recipeID: UUID, aiGeneratedReason: String) {
        self.id = UUID()
        self.recipeID = recipeID
        self.aiGeneratedReason = aiGeneratedReason
        self.generatedAt = Date()
    }
}

struct SuggestionCache: Codable {
    let suggestions: [RecipeSuggestion]
    let generatedAt: Date
    
    // Check if cache is stale (> 7 days old)
    var isStale: Bool {
        let daysSinceGeneration = Calendar.current.dateComponents([.day], from: generatedAt, to: Date()).day ?? 0
        return daysSinceGeneration >= 7
    }
}
