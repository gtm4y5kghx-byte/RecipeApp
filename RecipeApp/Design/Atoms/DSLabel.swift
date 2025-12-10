import SwiftUI

/// Design System Label Component
/// Consistent text styling with semantic typography and color options
struct DSLabel: View {

    // MARK: - Configuration

    let text: String
    let style: LabelStyle
    let color: LabelColor
    let alignment: TextAlignment

    // MARK: - Label Style

    enum LabelStyle {
        case largeTitle
        case title1
        case title2
        case title3
        case headline
        case body
        case callout
        case subheadline
        case footnote
        case caption1
        case caption2

        // Semantic aliases
        case recipeTitle
        case sectionHeader
        case ingredientText
        case instructionText
        case metadata
        case tag

        var font: Font {
            switch self {
            case .largeTitle: return Theme.Typography.largeTitle
            case .title1: return Theme.Typography.title1
            case .title2: return Theme.Typography.title2
            case .title3: return Theme.Typography.title3
            case .headline: return Theme.Typography.headline
            case .body: return Theme.Typography.body
            case .callout: return Theme.Typography.callout
            case .subheadline: return Theme.Typography.subheadline
            case .footnote: return Theme.Typography.footnote
            case .caption1: return Theme.Typography.caption1
            case .caption2: return Theme.Typography.caption2

            // Semantic styles
            case .recipeTitle: return Theme.Typography.recipeTitle
            case .sectionHeader: return Theme.Typography.sectionHeader
            case .ingredientText: return Theme.Typography.ingredientText
            case .instructionText: return Theme.Typography.instructionText
            case .metadata: return Theme.Typography.metadata
            case .tag: return Theme.Typography.tag
            }
        }
    }

    // MARK: - Label Color

    enum LabelColor {
        case primary
        case secondary
        case tertiary
        case accent
        case success
        case warning
        case error
        case white

        var color: Color {
            switch self {
            case .primary: return Theme.Colors.textPrimary
            case .secondary: return Theme.Colors.textSecondary
            case .tertiary: return Theme.Colors.textTertiary
            case .accent: return Theme.Colors.accent
            case .success: return Theme.Colors.success
            case .warning: return Theme.Colors.warning
            case .error: return Theme.Colors.error
            case .white: return .white
            }
        }
    }

    // MARK: - Initializer

    init(
        _ text: String,
        style: LabelStyle = .body,
        color: LabelColor = .primary,
        alignment: TextAlignment = .leading
    ) {
        self.text = text
        self.style = style
        self.color = color
        self.alignment = alignment
    }

    // MARK: - Body

    var body: some View {
        Text(text)
            .font(style.font)
            .foregroundColor(color.color)
            .multilineTextAlignment(alignment)
    }
}

// MARK: - Previews

#Preview("Typography Hierarchy") {
    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
        DSLabel("Large Title", style: .largeTitle)
        DSLabel("Title 1", style: .title1)
        DSLabel("Title 2", style: .title2)
        DSLabel("Title 3", style: .title3)
        DSLabel("Headline", style: .headline)
        DSLabel("Body text for main content", style: .body)
        DSLabel("Callout text", style: .callout)
        DSLabel("Subheadline", style: .subheadline)
        DSLabel("Footnote", style: .footnote)
        DSLabel("Caption 1", style: .caption1)
        DSLabel("Caption 2", style: .caption2)
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Semantic Styles") {
    VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
        DSLabel("Spaghetti Carbonara", style: .recipeTitle)
        DSLabel("Ingredients", style: .sectionHeader)
        DSLabel("200g spaghetti pasta", style: .ingredientText)
        DSLabel("1. Boil water and cook pasta according to package directions", style: .instructionText)
        DSLabel("Prep: 10 min • Cook: 15 min • Serves: 4", style: .metadata)
        DSLabel("Italian • Quick • Dinner", style: .tag)
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Color Variations") {
    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
        DSLabel("Primary text color", style: .body, color: .primary)
        DSLabel("Secondary text color", style: .body, color: .secondary)
        DSLabel("Tertiary text color", style: .body, color: .tertiary)
        DSLabel("Accent text color", style: .body, color: .accent)
        DSLabel("Success message", style: .body, color: .success)
        DSLabel("Warning message", style: .body, color: .warning)
        DSLabel("Error message", style: .body, color: .error)

        HStack {
            Spacer()
            DSLabel("White text on dark", style: .body, color: .white)
            Spacer()
        }
        .padding()
        .background(Theme.Colors.primary)
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Text Alignment") {
    VStack(spacing: Theme.Spacing.lg) {
        DSLabel("Left aligned text (default)", style: .headline, alignment: .leading)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Theme.Colors.backgroundLight)

        DSLabel("Center aligned text", style: .headline, alignment: .center)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Theme.Colors.backgroundLight)

        DSLabel("Right aligned text", style: .headline, alignment: .trailing)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Theme.Colors.backgroundLight)

        DSLabel("This is a longer piece of text that wraps to multiple lines. The alignment affects how the text flows across those lines.", style: .body, alignment: .center)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Theme.Colors.backgroundLight)
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Real Recipe Example") {
    VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
        DSLabel("Chicken Tikka Masala", style: .recipeTitle)

        HStack(spacing: Theme.Spacing.md) {
            DSLabel("⏱ 45 min", style: .metadata, color: .secondary)
            DSLabel("•", style: .metadata, color: .tertiary)
            DSLabel("👥 4 servings", style: .metadata, color: .secondary)
        }

        Divider()

        DSLabel("Ingredients", style: .sectionHeader)

        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            DSLabel("500g chicken breast, cubed", style: .ingredientText)
            DSLabel("2 tbsp tikka masala paste", style: .ingredientText)
            DSLabel("400ml coconut cream", style: .ingredientText)
            DSLabel("1 onion, diced", style: .ingredientText)
        }

        Divider()

        DSLabel("Instructions", style: .sectionHeader)

        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            DSLabel("1. Marinate chicken in tikka paste for 30 minutes", style: .instructionText)
            DSLabel("2. Cook chicken in a large pan until browned", style: .instructionText)
            DSLabel("3. Add onion and cook until soft", style: .instructionText)
            DSLabel("4. Pour in coconut cream and simmer for 15 minutes", style: .instructionText)
        }
    }
    .padding()
    .background(Theme.Colors.background)
}
