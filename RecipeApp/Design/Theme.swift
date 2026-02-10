import SwiftUI

enum Theme {

    // MARK: - Colors

    enum Colors {

        // MARK: Core Colors

        static let primary = Color("Colors/Primary")
        static let secondary = Color("Colors/Secondary")
        static let accent = Color("Colors/Accent")

        // MARK: Backgrounds

        static let background = Color("Colors/Background")
        static let backgroundLight = Color("Colors/BackgroundLight")
        static let backgroundDark = Color("Colors/BackgroundDark")

        // MARK: Text

        static let textPrimary = Color("Colors/TextPrimary")
        static let textSecondary = Color("Colors/TextSecondary")
        static let textTertiary = Color("Colors/TextTertiary")

        // MARK: Semantic Colors

        static let success = Color("Colors/Success")
        static let warning = Color("Colors/Warning")
        static let error = Color("Colors/Error")

        // MARK: UI Elements

        static let border = Color("Colors/Border")
        static let divider = Color("Colors/Divider")
        static let tagSecondaryText = Color("Colors/TagSecondaryText")
        static let tagSecondaryBackground = Color("Colors/TagSecondaryBackground")
    }

    // MARK: - Typography
    // Uses SwiftUI's built-in text styles for Dynamic Type accessibility support

    enum Typography {

        // MARK: Display Sizes (Large headings, hero text)

        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title1 = Font.title.weight(.bold)
        static let title2 = Font.title2.weight(.bold)
        static let title3 = Font.title3.weight(.semibold)

        // MARK: Body Sizes (Main content)

        static let headline = Font.headline
        static let body = Font.body
        static let callout = Font.callout
        static let subheadline = Font.subheadline
        static let footnote = Font.footnote
        static let caption1 = Font.caption
        static let caption2 = Font.caption2

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

