import Foundation

struct FuzzySearchService {
    static func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1 = Array(s1.lowercased())
        let s2 = Array(s2.lowercased())
        
        let empty = [Int](repeating: 0, count: s2.count)
        var last = [Int](0...s2.count)
        
        for (i, char1) in s1.enumerated() {
            var current = [i + 1] + empty
            for (j, char2) in s2.enumerated() {
                current[j + 1] = char1 == char2
                ? last[j]
                : min(last[j], last[j + 1], current[j]) + 1
            }
            last = current
        }
        
        return last.last ?? 0
    }
    
    static func fuzzyMatch(query: String, in text: String) -> Bool {
        let query = query.lowercased().trimmingCharacters(in: .whitespaces)
        let text = text.lowercased()
        
        // Empty query = no match
        guard !query.isEmpty else { return false }
        
        // Exact substring match (fast path)
        if text.contains(query) {
            return true
        }
        
        // Fuzzy match: Check if edit distance ≤ 2
        if levenshteinDistance(query, text) <= 2 {
            return true
        }
        
        // Check each word in text for fuzzy match
        let words = text.components(separatedBy: .whitespaces)
        for word in words {
            if levenshteinDistance(query, word) <= 2 {
                return true
            }
        }
        
        return false
    }
}
