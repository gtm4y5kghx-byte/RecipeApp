import Testing
import Foundation
@testable import RecipeApp

@Suite("UnifiedSuggestion Tests")
@MainActor
struct UnifiedSuggestionTests {

    // MARK: - Test Fixtures

    private func createRecipeSuggestion(
        id: UUID = UUID(),
        recipeID: UUID = UUID(),
        reason: String = "Try this again!"
    ) -> RecipeSuggestion {
        RecipeSuggestion(recipeID: recipeID, aiGeneratedReason: reason)
    }

    private func createGeneratedRecipe(
        id: UUID = UUID(),
        title: String = "AI Recipe"
    ) -> GeneratedRecipe {
        GeneratedRecipe(
            id: id,
            title: title,
            description: "A delicious AI-generated recipe"
        )
    }

    // MARK: - ID Tests

    @Test("fromCollection case returns suggestion's ID")
    func fromCollectionReturnsCorrectID() {
        let suggestion = createRecipeSuggestion()
        let unified = UnifiedSuggestion.fromCollection(suggestion)

        #expect(unified.id == suggestion.id)
    }

    @Test("aiGenerated case returns generated recipe's ID")
    func aiGeneratedReturnsCorrectID() {
        let recipe = createGeneratedRecipe()
        let unified = UnifiedSuggestion.aiGenerated(recipe, reason: "Based on your tastes")

        #expect(unified.id == recipe.id)
    }

    // MARK: - Reason Tests

    @Test("fromCollection case returns aiGeneratedReason")
    func fromCollectionReturnsCorrectReason() {
        let suggestion = createRecipeSuggestion(reason: "You haven't made this in a while")
        let unified = UnifiedSuggestion.fromCollection(suggestion)

        #expect(unified.reason == "You haven't made this in a while")
    }

    @Test("aiGenerated case returns custom reason")
    func aiGeneratedReturnsCorrectReason() {
        let recipe = createGeneratedRecipe()
        let unified = UnifiedSuggestion.aiGenerated(recipe, reason: "Based on your love of Italian food")

        #expect(unified.reason == "Based on your love of Italian food")
    }

    // MARK: - RecipeID Tests

    @Test("fromCollection case returns recipeID")
    func fromCollectionReturnsRecipeID() {
        let recipeID = UUID()
        let suggestion = createRecipeSuggestion(recipeID: recipeID)
        let unified = UnifiedSuggestion.fromCollection(suggestion)

        #expect(unified.recipeID == recipeID)
    }

    @Test("aiGenerated case returns nil recipeID")
    func aiGeneratedReturnsNilRecipeID() {
        let recipe = createGeneratedRecipe()
        let unified = UnifiedSuggestion.aiGenerated(recipe, reason: "Try this!")

        #expect(unified.recipeID == nil)
    }

    // MARK: - GeneratedRecipe Tests

    @Test("fromCollection case returns nil generatedRecipe")
    func fromCollectionReturnsNilGeneratedRecipe() {
        let suggestion = createRecipeSuggestion()
        let unified = UnifiedSuggestion.fromCollection(suggestion)

        #expect(unified.generatedRecipe == nil)
    }

    @Test("aiGenerated case returns the generatedRecipe")
    func aiGeneratedReturnsGeneratedRecipe() {
        let recipe = createGeneratedRecipe(title: "Test AI Recipe")
        let unified = UnifiedSuggestion.aiGenerated(recipe, reason: "Try this!")

        #expect(unified.generatedRecipe?.title == "Test AI Recipe")
        #expect(unified.generatedRecipe?.id == recipe.id)
    }

    // MARK: - IsAIGenerated Tests

    @Test("fromCollection case returns false for isAIGenerated")
    func fromCollectionIsNotAIGenerated() {
        let suggestion = createRecipeSuggestion()
        let unified = UnifiedSuggestion.fromCollection(suggestion)

        #expect(unified.isAIGenerated == false)
    }

    @Test("aiGenerated case returns true for isAIGenerated")
    func aiGeneratedIsAIGenerated() {
        let recipe = createGeneratedRecipe()
        let unified = UnifiedSuggestion.aiGenerated(recipe, reason: "Try this!")

        #expect(unified.isAIGenerated == true)
    }

    // MARK: - Identifiable Conformance

    @Test("UnifiedSuggestion conforms to Identifiable")
    func identifiableConformance() {
        let suggestion = createRecipeSuggestion()
        let recipe = createGeneratedRecipe()

        let unified1 = UnifiedSuggestion.fromCollection(suggestion)
        let unified2 = UnifiedSuggestion.aiGenerated(recipe, reason: "Try this!")

        // Should be usable in ForEach
        let suggestions: [UnifiedSuggestion] = [unified1, unified2]
        #expect(suggestions.count == 2)
        #expect(suggestions[0].id != suggestions[1].id)
    }
}
