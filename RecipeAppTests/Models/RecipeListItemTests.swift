import Testing
@testable import RecipeApp

@Suite("RecipeListItem Tests")
@MainActor
struct RecipeListItemTests {

    // MARK: - ID Tests

    @Test("recipe case returns recipe ID")
    func testRecipeCaseReturnsRecipeID() {
        let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe")
        let item = RecipeListItem.recipe(recipe, suggestionReason: nil)

        #expect(item.id == recipe.id)
    }

    @Test("generatedRecipe case returns generated recipe ID")
    func testGeneratedRecipeCaseReturnsGeneratedRecipeID() {
        let generated = RecipeTestFixtures.createGeneratedRecipe(title: "AI Recipe")
        let item = RecipeListItem.generatedRecipe(generated, reason: "Made for you")

        #expect(item.id == generated.id)
    }

    // MARK: - Recipe Property Tests

    @Test("recipe case returns the recipe")
    func testRecipeCaseReturnsRecipe() {
        let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe")
        let item = RecipeListItem.recipe(recipe, suggestionReason: nil)

        #expect(item.recipe?.id == recipe.id)
        #expect(item.recipe?.title == "Test Recipe")
    }

    @Test("generatedRecipe case returns nil for recipe")
    func testGeneratedRecipeCaseReturnsNilForRecipe() {
        let generated = RecipeTestFixtures.createGeneratedRecipe(title: "AI Recipe")
        let item = RecipeListItem.generatedRecipe(generated, reason: "Made for you")

        #expect(item.recipe == nil)
    }

    // MARK: - Generated Recipe Property Tests

    @Test("generatedRecipe case returns the generated recipe")
    func testGeneratedRecipeCaseReturnsGeneratedRecipe() {
        let generated = RecipeTestFixtures.createGeneratedRecipe(title: "AI Recipe")
        let item = RecipeListItem.generatedRecipe(generated, reason: "Made for you")

        #expect(item.generatedRecipe?.id == generated.id)
        #expect(item.generatedRecipe?.title == "AI Recipe")
    }

    @Test("recipe case returns nil for generatedRecipe")
    func testRecipeCaseReturnsNilForGeneratedRecipe() {
        let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe")
        let item = RecipeListItem.recipe(recipe, suggestionReason: nil)

        #expect(item.generatedRecipe == nil)
    }

    // MARK: - Suggestion Reason Tests

    @Test("recipe with suggestion reason returns reason")
    func testRecipeWithSuggestionReasonReturnsReason() {
        let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe")
        let item = RecipeListItem.recipe(recipe, suggestionReason: "You haven't cooked this in a while")

        #expect(item.suggestionReason == "You haven't cooked this in a while")
    }

    @Test("recipe without suggestion reason returns nil")
    func testRecipeWithoutSuggestionReasonReturnsNil() {
        let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe")
        let item = RecipeListItem.recipe(recipe, suggestionReason: nil)

        #expect(item.suggestionReason == nil)
    }

    @Test("generatedRecipe returns reason")
    func testGeneratedRecipeReturnsReason() {
        let generated = RecipeTestFixtures.createGeneratedRecipe(title: "AI Recipe")
        let item = RecipeListItem.generatedRecipe(generated, reason: "Made for you • Italian")

        #expect(item.suggestionReason == "Made for you • Italian")
    }

    // MARK: - isGenerated Tests

    @Test("recipe case returns false for isGenerated")
    func testRecipeCaseReturnsFalseForIsGenerated() {
        let recipe = RecipeTestFixtures.createRecipe(title: "Test Recipe")
        let item = RecipeListItem.recipe(recipe, suggestionReason: nil)

        #expect(item.isGenerated == false)
    }

    @Test("generatedRecipe case returns true for isGenerated")
    func testGeneratedRecipeCaseReturnsTrueForIsGenerated() {
        let generated = RecipeTestFixtures.createGeneratedRecipe(title: "AI Recipe")
        let item = RecipeListItem.generatedRecipe(generated, reason: "Made for you")

        #expect(item.isGenerated == true)
    }
}
