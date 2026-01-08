import Testing
@testable import RecipeApp

@Suite("Time Constants Tests")
struct TimeConstantsTests {
    
    @Test("Recently cooked threshold is 30 days")
    func testRecentlyCookedThreshold() {
        #expect(TimeConstants.recentlyCookedThreshold == 30)
    }
    
    @Test("Cooked long ago threshold is 30 days")
    func testCookedLongAgoThreshold() {
        #expect(TimeConstants.cookedLongAgoThreshold == 30)
    }
    
    @Test("AI cache stale days is 7")
    func testAICacheStaleDays() {
        #expect(TimeConstants.aiCacheStaleDays == 7)
    }
    
    @Test("Fuzzy search threshold is 2")
    func testFuzzySearchThreshold() {
        #expect(TimeConstants.fuzzySearchThreshold == 2)
    }
    
    @Test("Minimum recipes for suggestions is 20")
    func testMinimumRecipesForSuggestions() {
        #expect(TimeConstants.minimumRecipesForSuggestions == 20)
    }
}
