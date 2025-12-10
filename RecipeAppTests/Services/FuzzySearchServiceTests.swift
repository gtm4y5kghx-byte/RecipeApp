import Testing
import Foundation
@testable import RecipeApp

@Suite("FuzzySearchService Tests")
struct FuzzySearchServiceTests {

    // MARK: - Levenshtein Distance Tests

    @Test("Levenshtein distance between identical strings")
    func testLevenshteinDistanceIdentical() {
        let distance = FuzzySearchService.levenshteinDistance("pasta", "pasta")
        #expect(distance == 0)
    }

    @Test("Levenshtein distance with one character difference")
    func testLevenshteinDistanceOneEdit() {
        #expect(FuzzySearchService.levenshteinDistance("pasta", "paste") == 1) // substitution
        #expect(FuzzySearchService.levenshteinDistance("pasta", "past") == 1)  // deletion
        #expect(FuzzySearchService.levenshteinDistance("pasta", "pastas") == 1) // insertion
    }

    @Test("Levenshtein distance with two character difference")
    func testLevenshteinDistanceTwoEdits() {
        #expect(FuzzySearchService.levenshteinDistance("pasta", "posta") == 1) // 1 substitution
        #expect(FuzzySearchService.levenshteinDistance("pasta", "past") == 1)  // 1 deletion
        #expect(FuzzySearchService.levenshteinDistance("pasta", "pista") == 1) // 1 substitution
        #expect(FuzzySearchService.levenshteinDistance("pasta", "pizza") == 3) // 3 edits
    }

    @Test("Levenshtein distance is case insensitive")
    func testLevenshteinDistanceCaseInsensitive() {
        let distance = FuzzySearchService.levenshteinDistance("Pasta", "PASTA")
        #expect(distance == 0)
    }

    @Test("Levenshtein distance with completely different strings")
    func testLevenshteinDistanceDifferent() {
        let distance = FuzzySearchService.levenshteinDistance("pasta", "chicken")
        #expect(distance > 2)
    }

    @Test("Levenshtein distance with empty strings")
    func testLevenshteinDistanceEmpty() {
        #expect(FuzzySearchService.levenshteinDistance("", "") == 0)
        #expect(FuzzySearchService.levenshteinDistance("pasta", "") == 5)
        #expect(FuzzySearchService.levenshteinDistance("", "pasta") == 5)
    }

    // MARK: - Fuzzy Match Tests

    @Test("Fuzzy match with exact substring")
    func testFuzzyMatchExactSubstring() {
        #expect(FuzzySearchService.fuzzyMatch(query: "pasta", in: "Spaghetti pasta carbonara"))
        #expect(FuzzySearchService.fuzzyMatch(query: "carb", in: "Pasta Carbonara"))
    }

    @Test("Fuzzy match with typo within threshold")
    func testFuzzyMatchTypo() {
        // 1 character typo
        #expect(FuzzySearchService.fuzzyMatch(query: "psta", in: "pasta")) // missing 'a'
        #expect(FuzzySearchService.fuzzyMatch(query: "pasto", in: "pasta")) // 'o' instead of 'a'

        // 2 character typo
        #expect(FuzzySearchService.fuzzyMatch(query: "psta", in: "pasta"))
        #expect(FuzzySearchService.fuzzyMatch(query: "pasa", in: "pasta"))
    }

    @Test("Fuzzy match fails with too many differences")
    func testFuzzyMatchTooManyDifferences() {
        // More than 2 edits required
        #expect(!FuzzySearchService.fuzzyMatch(query: "chicken", in: "pasta"))
        #expect(!FuzzySearchService.fuzzyMatch(query: "xyz", in: "abc"))
    }

    @Test("Fuzzy match with empty query")
    func testFuzzyMatchEmptyQuery() {
        #expect(!FuzzySearchService.fuzzyMatch(query: "", in: "pasta carbonara"))
        #expect(!FuzzySearchService.fuzzyMatch(query: "  ", in: "pasta carbonara"))
    }

    @Test("Fuzzy match is case insensitive")
    func testFuzzyMatchCaseInsensitive() {
        #expect(FuzzySearchService.fuzzyMatch(query: "PASTA", in: "pasta carbonara"))
        #expect(FuzzySearchService.fuzzyMatch(query: "pasta", in: "PASTA CARBONARA"))
        #expect(FuzzySearchService.fuzzyMatch(query: "PaStA", in: "pAsTa CaRbOnArA"))
    }

    @Test("Fuzzy match with word boundary matching")
    func testFuzzyMatchWordBoundary() {
        // Match individual words with typos
        #expect(FuzzySearchService.fuzzyMatch(query: "carb", in: "pasta carbonara"))
        #expect(FuzzySearchService.fuzzyMatch(query: "carbonra", in: "pasta carbonara")) // 1 typo in "carbonara"
        #expect(FuzzySearchService.fuzzyMatch(query: "psta", in: "pasta carbonara")) // 1 typo in "pasta"
    }

    @Test("Fuzzy match trims whitespace from query")
    func testFuzzyMatchTrimsWhitespace() {
        #expect(FuzzySearchService.fuzzyMatch(query: "  pasta  ", in: "pasta carbonara"))
        #expect(FuzzySearchService.fuzzyMatch(query: "\tpasta\n", in: "pasta carbonara"))
    }

    @Test("Fuzzy match with real recipe search scenarios")
    func testFuzzyMatchRealScenarios() {
        // Common misspellings
        #expect(FuzzySearchService.fuzzyMatch(query: "spagetti", in: "Spaghetti Carbonara")) // 1 missing 'h'
        #expect(FuzzySearchService.fuzzyMatch(query: "chiken", in: "Chicken Tikka Masala"))  // 1 typo

        // Partial ingredient searches
        #expect(FuzzySearchService.fuzzyMatch(query: "tom", in: "tomato sauce"))
        #expect(FuzzySearchService.fuzzyMatch(query: "garl", in: "garlic bread"))

        // Should NOT match very different words
        #expect(!FuzzySearchService.fuzzyMatch(query: "beef", in: "Vegetarian Pasta"))
    }
}
