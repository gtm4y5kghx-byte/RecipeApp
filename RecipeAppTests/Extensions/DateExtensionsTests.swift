import Testing
import Foundation
@testable import RecipeApp

@Suite("Date Extension Tests")
struct DateExtensionsTests {
    
    // MARK: - daysSince Tests
    
    @Test("Days since calculates correct difference")
    func testDaysSince() {
        let now = Date()
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: now)!
        
        let days = now.daysSince(threeDaysAgo)
        
        #expect(days == 3)
    }
    
    @Test("Days since returns 0 for same date")
    func testDaysSinceSameDate() {
        let now = Date()
        
        let days = now.daysSince(now)
        
        #expect(days == 0)
    }
    
    @Test("Days since handles future dates")
    func testDaysSinceFutureDate() {
        let now = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        
        let days = now.daysSince(tomorrow)
        
        #expect(days == -1)
    }
    
    // MARK: - isWithinDays Tests
    
    @Test("Is within days returns true for recent date")
    func testIsWithinDaysTrue() {
        let now = Date()
        let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: now)!
        
        let result = fiveDaysAgo.isWithinDays(7)
        
        #expect(result == true)
    }
    
    @Test("Is within days returns false for old date")
    func testIsWithinDaysFalse() {
        let now = Date()
        let tenDaysAgo = Calendar.current.date(byAdding: .day, value: -10, to: now)!
        
        let result = tenDaysAgo.isWithinDays(7)
        
        #expect(result == false)
    }
    
    @Test("Is within days handles exact boundary")
    func testIsWithinDaysBoundary() {
        let now = Date()
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        
        let result = sevenDaysAgo.isWithinDays(7)
        
        // Should be true (>= comparison, not >)
        #expect(result == true)
    }
    
    // MARK: - relativeDescription Tests
    
    @Test("Relative description for today")
    func testRelativeDescriptionToday() {
        let now = Date()
        
        let description = now.relativeDescription()
        
        #expect(description == "today")
    }
    
    @Test("Relative description for yesterday")
    func testRelativeDescriptionYesterday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        let description = yesterday.relativeDescription()
        
        #expect(description == "yesterday")
    }
    
    @Test("Relative description for days ago")
    func testRelativeDescriptionDaysAgo() {
        let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        
        let description = fiveDaysAgo.relativeDescription()
        
        #expect(description == "5 days ago")
    }
    
    @Test("Relative description for weeks ago")
    func testRelativeDescriptionWeeksAgo() {
        let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: Date())!
        
        let description = twoWeeksAgo.relativeDescription()
        
        #expect(description == "2 weeks ago")
    }
    
    @Test("Relative description for months ago")
    func testRelativeDescriptionMonthsAgo() {
        let twoMonthsAgo = Calendar.current.date(byAdding: .day, value: -60, to: Date())!
        
        let description = twoMonthsAgo.relativeDescription()
        
        #expect(description == "2 months ago")
    }
    
    @Test("Relative description for years ago")
    func testRelativeDescriptionYearsAgo() {
        let twoYearsAgo = Calendar.current.date(byAdding: .day, value: -730, to: Date())!
        
        let description = twoYearsAgo.relativeDescription()
        
        #expect(description == "2 years ago")
    }
    
    @Test("Relative description for single week")
    func testRelativeDescriptionOneWeek() {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        
        let description = oneWeekAgo.relativeDescription()
        
        #expect(description == "1 week ago")
    }
    
    @Test("Relative description for single month")
    func testRelativeDescriptionOneMonth() {
        let oneMonthAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        
        let description = oneMonthAgo.relativeDescription()
        
        #expect(description == "1 month ago")
    }
}
