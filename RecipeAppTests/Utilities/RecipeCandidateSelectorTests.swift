import Testing
import Foundation
@testable import RecipeApp

@Suite("RecipeCandidateSelector Tests")
@MainActor
struct RecipeCandidateSelectorTests {

    // MARK: - Passthrough Behavior

    @Test("Returns all recipes when count is below limit")
    func passthroughWhenBelowLimit() {
        let recipes = createRecipes(count: 30)

        let candidates = RecipeCandidateSelector.selectCandidates(from: recipes, limit: 60)

        #expect(candidates.count == 30)
    }

    @Test("Returns all recipes when count equals limit")
    func passthroughWhenAtLimit() {
        let recipes = createRecipes(count: 60)

        let candidates = RecipeCandidateSelector.selectCandidates(from: recipes, limit: 60)

        #expect(candidates.count == 60)
    }

    // MARK: - Limit Enforcement

    @Test("Caps results at specified limit")
    func capsAtLimit() {
        let recipes = createRecipes(count: 100)

        let candidates = RecipeCandidateSelector.selectCandidates(from: recipes, limit: 60)

        #expect(candidates.count == 60)
    }

    @Test("Respects custom limit parameter")
    func respectsCustomLimit() {
        let recipes = createRecipes(count: 100)

        let candidates = RecipeCandidateSelector.selectCandidates(from: recipes, limit: 25)

        #expect(candidates.count == 25)
    }

    // MARK: - Favorites Prioritization

    @Test("Includes all favorites when under favorites cap")
    func includesAllFavorites() {
        let recipes = createRecipes(count: 100)
        let favoriteIndices = [0, 10, 20, 30, 40]
        for index in favoriteIndices {
            recipes[index].isFavorite = true
        }

        let candidates = RecipeCandidateSelector.selectCandidates(from: recipes, limit: 60)
        let favoriteCount = candidates.filter { $0.isFavorite }.count

        #expect(favoriteCount == 5)
    }

    @Test("Caps favorites at 15")
    func capsFavoritesAt15() {
        let recipes = createRecipes(count: 100)
        for i in 0..<25 {
            recipes[i].isFavorite = true
        }

        let candidates = RecipeCandidateSelector.selectCandidates(from: recipes, limit: 60)
        let favoriteCount = candidates.filter { $0.isFavorite }.count

        #expect(favoriteCount >= 15)
        #expect(favoriteCount <= 25)
    }

    // MARK: - Meal Type Tag Filtering

    @Test("Prioritizes recipes with matching meal type tags")
    func prioritizesMealTypeTags() {
        let recipes = createRecipes(count: 100)
        for i in 0..<10 {
            recipes[i].userTags = ["breakfast", "quick"]
        }

        let candidates = RecipeCandidateSelector.selectCandidates(from: recipes, for: .breakfast, limit: 60)
        let breakfastTagged = candidates.filter { $0.userTags.contains("breakfast") }

        #expect(breakfastTagged.count == 10)
    }

    @Test("Does not filter by tags when mealType is nil")
    func noTagFilteringWithoutMealType() {
        let recipes = createRecipes(count: 100)
        for i in 0..<10 {
            recipes[i].userTags = ["dinner"]
        }

        let candidates = RecipeCandidateSelector.selectCandidates(from: recipes, for: nil, limit: 60)

        #expect(candidates.count == 60)
    }

    @Test("Matches tags case-insensitively")
    func caseInsensitiveTagMatching() {
        let recipes = createRecipes(count: 100)
        recipes[0].userTags = ["DINNER"]
        recipes[1].userTags = ["Dinner"]
        recipes[2].userTags = ["dinner"]

        let candidates = RecipeCandidateSelector.selectCandidates(from: recipes, for: .dinner, limit: 60)
        let dinnerTagged = candidates.filter { recipe in
            recipe.userTags.contains { $0.lowercased().contains("dinner") }
        }

        #expect(dinnerTagged.count == 3)
    }

    // MARK: - Stale Recipe Prioritization

    @Test("Prioritizes recipes never made")
    func prioritizesNeverMadeRecipes() {
        let recipes = createRecipes(count: 100)
        let recentDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!

        for i in 0..<50 {
            recipes[i].lastMade = recentDate
        }

        let candidates = RecipeCandidateSelector.selectCandidates(from: recipes, limit: 60)
        let neverMade = candidates.filter { $0.lastMade == nil }

        #expect(neverMade.count >= 20)
    }

    @Test("Prioritizes recipes made over 30 days ago")
    func prioritizesStaleRecipes() {
        let recipes = createRecipes(count: 100)
        let recentDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let staleDate = Calendar.current.date(byAdding: .day, value: -45, to: Date())!

        for i in 0..<80 {
            recipes[i].lastMade = recentDate
        }
        for i in 80..<100 {
            recipes[i].lastMade = staleDate
        }

        let candidates = RecipeCandidateSelector.selectCandidates(from: recipes, limit: 60)
        let staleRecipes = candidates.filter { recipe in
            guard let lastMade = recipe.lastMade else { return false }
            return Date().daysSince(lastMade) > 30
        }

        #expect(staleRecipes.count == 20)
    }

    // MARK: - No Duplicates

    @Test("Never returns duplicate recipes")
    func noDuplicates() {
        let recipes = createRecipes(count: 100)
        recipes[0].isFavorite = true
        recipes[0].userTags = ["dinner"]
        recipes[0].lastMade = nil

        let candidates = RecipeCandidateSelector.selectCandidates(from: recipes, for: .dinner, limit: 60)
        let uniqueIDs = Set(candidates.map { $0.id })

        #expect(uniqueIDs.count == candidates.count)
    }

    // MARK: - Combined Prioritization

    @Test("Combines all prioritization criteria")
    func combinesAllCriteria() {
        let recipes = createRecipes(count: 100)
        let recentDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!

        recipes[0].isFavorite = true
        recipes[0].userTags = ["dinner"]
        recipes[0].lastMade = nil

        recipes[1].isFavorite = true
        recipes[1].lastMade = recentDate

        recipes[2].userTags = ["dinner"]
        recipes[2].lastMade = recentDate

        for i in 3..<100 {
            recipes[i].lastMade = recentDate
        }

        let candidates = RecipeCandidateSelector.selectCandidates(from: recipes, for: .dinner, limit: 60)

        #expect(candidates.contains { $0.id == recipes[0].id })
        #expect(candidates.contains { $0.id == recipes[1].id })
        #expect(candidates.contains { $0.id == recipes[2].id })
    }

    // MARK: - Edge Cases

    @Test("Handles empty recipe array")
    func handlesEmptyArray() {
        let recipes: [Recipe] = []

        let candidates = RecipeCandidateSelector.selectCandidates(from: recipes, limit: 60)

        #expect(candidates.isEmpty)
    }

    @Test("Handles limit of zero")
    func handlesZeroLimit() {
        let recipes = createRecipes(count: 10)

        let candidates = RecipeCandidateSelector.selectCandidates(from: recipes, limit: 0)

        #expect(candidates.isEmpty)
    }

    @Test("Uses default limit of 60")
    func usesDefaultLimit() {
        let recipes = createRecipes(count: 100)

        let candidates = RecipeCandidateSelector.selectCandidates(from: recipes)

        #expect(candidates.count == RecipeCandidateSelector.defaultLimit)
    }

    // MARK: - Helpers

    private func createRecipes(count: Int) -> [Recipe] {
        (0..<count).map { index in
            RecipeTestFixtures.createRecipe(title: "Recipe \(index)")
        }
    }
}
