import Foundation

extension Date {
    /// Returns the number of days between this date and another date
    func daysSince(_ date: Date) -> Int {
        Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    
    /// Returns true if this date is within the specified number of days from now
    func isWithinDays(_ days: Int) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        // Get start of day for both dates to avoid time-of-day precision issues
        guard let selfStartOfDay = calendar.startOfDay(for: self) as Date?,
              let nowStartOfDay = calendar.startOfDay(for: now) as Date? else {
            return false
        }
        
        // Calculate threshold at start of day
        guard let threshold = calendar.date(
            byAdding: .day,
            value: -days,
            to: nowStartOfDay
        ) else {
            return false
        }
        
        return selfStartOfDay >= threshold
    }
    
    /// Returns a user-friendly relative date string (e.g., "2 days ago", "yesterday")
    func relativeDescription() -> String {
        let calendar = Calendar.current
        let now = Date()
        
        let components = calendar.dateComponents([.day], from: self, to: now)
        
        guard let days = components.day else {
            return "recently"
        }
        
        if days == 0 {
            return "today"
        } else if days == 1 {
            return "yesterday"
        } else if days < 7 {
            return "\(days) days ago"
        } else if days < 30 {
            let weeks = days / 7
            return "\(weeks) \(weeks == 1 ? "week" : "weeks") ago"
        } else if days < 365 {
            let months = days / 30
            return "\(months) \(months == 1 ? "month" : "months") ago"
        } else {
            let years = days / 365
            return "\(years) \(years == 1 ? "year" : "years") ago"
        }
    }
}
