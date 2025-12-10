import SwiftUI

enum Theme {

    // MARK: - Colors

    enum Colors {

        // MARK: Core Colors

        static let primary = Color(hex: "#8b3342")         // Deep burgundy
        static let secondary = Color(hex: "#a65160")       // Lighter burgundy
        static let accent = Color(hex: "#b8935f")          // Golden bronze

        // MARK: Backgrounds

        static let background = Color(hex: "#f0e8dc")      // Light cream
        static let backgroundLight = Color(hex: "#f9f5f0") // Almost white cream
        static let backgroundDark = Color(hex: "#d9cfc2")  // Subtle contrast

        // MARK: Text

        static let textPrimary = Color(hex: "#343331")     // Dark charcoal brown
        static let textSecondary = Color(hex: "#6b635f")   // Medium warm gray
        static let textTertiary = Color(hex: "#9d948e")    // Light warm gray

        // MARK: Semantic Colors

        static let success = Color(hex: "#6b8e4e")         // Muted olive green
        static let warning = Color(hex: "#c97a3a")         // Warm amber
        static let error = Color(hex: "#a14437")           // Deeper terracotta

        // MARK: UI Elements

        static let border = Color(hex: "#e5ddd4")          // Very light warm beige
        static let divider = Color(hex: "#e5ddd4")         // Same as border
    }
}

// MARK: - Color Extension for Hex Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
