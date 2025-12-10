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

    // MARK: - Typography

    enum Typography {

        // MARK: Display Sizes (Large headings, hero text)

        static let largeTitle = Font.system(size: 34, weight: .bold)
        static let title1 = Font.system(size: 28, weight: .bold)
        static let title2 = Font.system(size: 22, weight: .bold)
        static let title3 = Font.system(size: 20, weight: .semibold)

        // MARK: Body Sizes (Main content)

        static let headline = Font.system(size: 17, weight: .semibold)
        static let body = Font.system(size: 17, weight: .regular)
        static let callout = Font.system(size: 16, weight: .regular)
        static let subheadline = Font.system(size: 15, weight: .regular)
        static let footnote = Font.system(size: 13, weight: .regular)
        static let caption1 = Font.system(size: 12, weight: .regular)
        static let caption2 = Font.system(size: 11, weight: .regular)

        // MARK: Semantic Styles (Use these in views)

        static let recipeTitle = title1
        static let sectionHeader = title3
        static let ingredientText = body
        static let instructionText = body
        static let metadata = caption1          // serving size, cook time, etc.
        static let tag = caption1               // recipe tags, categories
        static let buttonLabel = headline
    }

    // MARK: - Spacing

    enum Spacing {

        // MARK: Base Scale (4pt grid system)

        static let xs: CGFloat = 4      // Tiny gaps, icon padding
        static let sm: CGFloat = 8      // Compact spacing
        static let md: CGFloat = 16     // Standard spacing (most common)
        static let lg: CGFloat = 24     // Section spacing
        static let xl: CGFloat = 32     // Large gaps between major sections
        static let xxl: CGFloat = 48    // Extra large spacing (rare)

        // MARK: Semantic Spacing (Use these in views)

        static let cardPadding = md     // 16pt padding inside cards
        static let sectionGap = lg      // 24pt gap between sections
        static let itemGap = sm         // 8pt gap between list items
        static let screenEdge = md      // 16pt margin from screen edges
        static let buttonPadding = md   // 16pt horizontal padding in buttons
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        static let sm: CGFloat = 8      // Small radius (tags, small buttons)
        static let md: CGFloat = 12     // Medium radius (cards, inputs)
        static let lg: CGFloat = 16     // Large radius (prominent cards)
        static let full: CGFloat = 999  // Fully rounded (pills, circular buttons)
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
