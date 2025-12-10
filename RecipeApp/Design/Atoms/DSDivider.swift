import SwiftUI

/// Design System Divider Component
/// Consistent separators with configurable thickness and color
struct DSDivider: View {

    // MARK: - Configuration

    let thickness: DividerThickness
    let color: DividerColor
    let spacing: DividerSpacing

    // MARK: - Divider Thickness

    enum DividerThickness {
        case thin       // 1pt - subtle separation
        case medium     // 2pt - standard separation
        case thick      // 4pt - strong separation

        var height: CGFloat {
            switch self {
            case .thin: return 1
            case .medium: return 2
            case .thick: return 4
            }
        }
    }

    // MARK: - Divider Color

    enum DividerColor {
        case subtle     // Very light, minimal contrast
        case standard   // Normal divider color
        case prominent  // Darker, more visible

        var color: Color {
            switch self {
            case .subtle: return Theme.Colors.border
            case .standard: return Theme.Colors.divider
            case .prominent: return Theme.Colors.textTertiary.opacity(0.3)
            }
        }
    }

    // MARK: - Divider Spacing

    enum DividerSpacing {
        case none       // No vertical padding
        case compact    // 8pt padding
        case standard   // 16pt padding
        case loose      // 24pt padding

        var padding: CGFloat {
            switch self {
            case .none: return 0
            case .compact: return Theme.Spacing.sm
            case .standard: return Theme.Spacing.md
            case .loose: return Theme.Spacing.lg
            }
        }
    }

    // MARK: - Initializer

    init(
        thickness: DividerThickness = .thin,
        color: DividerColor = .standard,
        spacing: DividerSpacing = .standard
    ) {
        self.thickness = thickness
        self.color = color
        self.spacing = spacing
    }

    // MARK: - Body

    var body: some View {
        Rectangle()
            .fill(color.color)
            .frame(height: thickness.height)
            .padding(.vertical, spacing.padding)
    }
}

// MARK: - Previews

#Preview("Divider Thickness") {
    VStack(spacing: Theme.Spacing.xl) {
        VStack(spacing: 0) {
            DSLabel("Thin Divider (1pt)", style: .caption1, color: .secondary)
            DSDivider(thickness: .thin, spacing: .compact)
            DSLabel("Content below", style: .body)
        }

        VStack(spacing: 0) {
            DSLabel("Medium Divider (2pt)", style: .caption1, color: .secondary)
            DSDivider(thickness: .medium, spacing: .compact)
            DSLabel("Content below", style: .body)
        }

        VStack(spacing: 0) {
            DSLabel("Thick Divider (4pt)", style: .caption1, color: .secondary)
            DSDivider(thickness: .thick, spacing: .compact)
            DSLabel("Content below", style: .body)
        }
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Divider Colors") {
    VStack(spacing: Theme.Spacing.xl) {
        VStack(spacing: 0) {
            DSLabel("Subtle", style: .caption1, color: .secondary)
            DSDivider(color: .subtle, spacing: .compact)
            DSLabel("Very light separation", style: .body)
        }

        VStack(spacing: 0) {
            DSLabel("Standard", style: .caption1, color: .secondary)
            DSDivider(color: .standard, spacing: .compact)
            DSLabel("Normal separation", style: .body)
        }

        VStack(spacing: 0) {
            DSLabel("Prominent", style: .caption1, color: .secondary)
            DSDivider(color: .prominent, spacing: .compact)
            DSLabel("Strong separation", style: .body)
        }
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Divider Spacing") {
    VStack(spacing: 0) {
        DSLabel("No spacing", style: .body)
        DSDivider(spacing: .none)
        DSLabel("Content immediately adjacent", style: .caption1, color: .secondary)

        DSDivider(thickness: .medium, color: .prominent, spacing: .standard)

        DSLabel("Compact spacing (8pt)", style: .body)
        DSDivider(spacing: .compact)
        DSLabel("Tight vertical rhythm", style: .caption1, color: .secondary)

        DSDivider(thickness: .medium, color: .prominent, spacing: .standard)

        DSLabel("Standard spacing (16pt)", style: .body)
        DSDivider(spacing: .standard)
        DSLabel("Balanced separation", style: .caption1, color: .secondary)

        DSDivider(thickness: .medium, color: .prominent, spacing: .standard)

        DSLabel("Loose spacing (24pt)", style: .body)
        DSDivider(spacing: .loose)
        DSLabel("Generous breathing room", style: .caption1, color: .secondary)
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Recipe Card Example") {
    VStack(alignment: .leading, spacing: 0) {
        // Header
        HStack {
            DSLabel("Spaghetti Carbonara", style: .recipeTitle)
            Spacer()
            DSIcon("heart.fill", size: .large, color: .error)
        }

        DSDivider(spacing: .standard)

        // Metadata
        HStack(spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.xs) {
                DSIcon("clock", size: .small, color: .secondary)
                DSLabel("30 min", style: .metadata, color: .secondary)
            }
            HStack(spacing: Theme.Spacing.xs) {
                DSIcon("person.2", size: .small, color: .secondary)
                DSLabel("4 servings", style: .metadata, color: .secondary)
            }
        }

        DSDivider(spacing: .standard)

        // Section
        DSLabel("Ingredients", style: .sectionHeader)
        DSDivider(thickness: .thin, color: .subtle, spacing: .compact)
        DSLabel("200g spaghetti", style: .ingredientText)
        DSLabel("100g pancetta", style: .ingredientText)
        DSLabel("2 eggs", style: .ingredientText)

        DSDivider(spacing: .standard)

        // Another section
        DSLabel("Instructions", style: .sectionHeader)
        DSDivider(thickness: .thin, color: .subtle, spacing: .compact)
        DSLabel("1. Boil water and cook pasta", style: .instructionText)
        DSLabel("2. Fry pancetta until crispy", style: .instructionText)
        DSLabel("3. Mix eggs with pasta", style: .instructionText)
    }
    .padding()
    .background(Theme.Colors.backgroundLight)
    .cornerRadius(Theme.CornerRadius.md)
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Section Separators") {
    VStack(alignment: .leading, spacing: 0) {
        // Light section divider
        DSLabel("Recent Recipes", style: .headline)
        DSDivider(thickness: .thin, color: .subtle, spacing: .compact)
        DSLabel("3 recipes", style: .caption1, color: .secondary)

        DSDivider(thickness: .medium, spacing: .loose)

        // Standard section divider
        DSLabel("Favorites", style: .headline)
        DSDivider(spacing: .compact)
        DSLabel("12 recipes", style: .caption1, color: .secondary)

        DSDivider(thickness: .medium, spacing: .loose)

        // Strong section divider
        DSLabel("All Recipes", style: .headline)
        DSDivider(thickness: .thick, color: .prominent, spacing: .compact)
        DSLabel("47 recipes", style: .caption1, color: .secondary)
    }
    .padding()
    .background(Theme.Colors.background)
}
