import XCTest
@testable import RecipeApp

final class SpoonacularUsageTrackerTests: XCTestCase {

    var tracker: SpoonacularUsageTracker!

    override func setUp() {
        super.setUp()
        tracker = SpoonacularUsageTracker()
        tracker.reset()
    }

    override func tearDown() {
        tracker.reset()
        tracker = nil
        super.tearDown()
    }

    func testTrackerStartsWithZeroSearches() {
        XCTAssertEqual(tracker.searchesUsedToday, 0)
        XCTAssertTrue(tracker.canSearch)
    }

    func testRecordSearchIncrementsCount() {
        tracker.recordSearch()
        XCTAssertEqual(tracker.searchesUsedToday, 1)

        tracker.recordSearch()
        XCTAssertEqual(tracker.searchesUsedToday, 2)
    }

    func testCanSearchReturnsFalseWhenLimitReached() {
        for _ in 0..<5 {
            tracker.recordSearch()
        }

        XCTAssertEqual(tracker.searchesUsedToday, 5)
        XCTAssertFalse(tracker.canSearch)
    }

    func testCanSearchReturnsTrueBeforeLimit() {
        for _ in 0..<4 {
            tracker.recordSearch()
        }

        XCTAssertEqual(tracker.searchesUsedToday, 4)
        XCTAssertTrue(tracker.canSearch)
    }

    func testResetClearsSearchCount() {
        for _ in 0..<5 {
            tracker.recordSearch()
        }

        XCTAssertEqual(tracker.searchesUsedToday, 5)
        XCTAssertFalse(tracker.canSearch)

        tracker.reset()

        XCTAssertEqual(tracker.searchesUsedToday, 0)
        XCTAssertTrue(tracker.canSearch)
    }
}
