import SwiftUI

/// Design System Icon Component
/// Consistent icon styling with semantic colors and sizes
struct DSIcon: View {

    // MARK: - Configuration

    let name: String
    let size: IconSize
    let color: IconColor
    let bounceValue: Bool?

    // MARK: - Icon Size

    enum IconSize {
        case small
        case medium
        case large
        case xlarge

        var points: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 20
            case .large: return 24
            case .xlarge: return 32
            }
        }
    }

    // MARK: - Icon Color

    enum IconColor {
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
        _ name: String,
        size: IconSize = .medium,
        color: IconColor = .primary,
        bounceValue: Bool? = nil
    ) {
        self.name = name
        self.size = size
        self.color = color
        self.bounceValue = bounceValue
    }

    // MARK: - Body

    var body: some View {
        Image(systemName: name)
            .font(.system(size: size.points))
            .foregroundColor(color.color)
            .symbolEffect(.bounce, value: bounceValue ?? false)
    }
}

// MARK: - Previews

#Preview("Icon Sizes") {
    VStack(spacing: Theme.Spacing.lg) {
        HStack(spacing: Theme.Spacing.md) {
            DSIcon("heart.fill", size: .small)
            DSLabel("Small (16pt)", style: .caption1, color: .secondary)
        }

        HStack(spacing: Theme.Spacing.md) {
            DSIcon("heart.fill", size: .medium)
            DSLabel("Medium (20pt)", style: .caption1, color: .secondary)
        }

        HStack(spacing: Theme.Spacing.md) {
            DSIcon("heart.fill", size: .large)
            DSLabel("Large (24pt)", style: .caption1, color: .secondary)
        }

        HStack(spacing: Theme.Spacing.md) {
            DSIcon("heart.fill", size: .xlarge)
            DSLabel("X-Large (32pt)", style: .caption1, color: .secondary)
        }
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Icon Colors") {
    VStack(spacing: Theme.Spacing.md) {
        HStack(spacing: Theme.Spacing.md) {
            DSIcon("star.fill", size: .large, color: .primary)
            DSLabel("Primary", style: .body, color: .primary)
        }

        HStack(spacing: Theme.Spacing.md) {
            DSIcon("star.fill", size: .large, color: .secondary)
            DSLabel("Secondary", style: .body, color: .secondary)
        }

        HStack(spacing: Theme.Spacing.md) {
            DSIcon("star.fill", size: .large, color: .tertiary)
            DSLabel("Tertiary", style: .body, color: .tertiary)
        }

        HStack(spacing: Theme.Spacing.md) {
            DSIcon("star.fill", size: .large, color: .accent)
            DSLabel("Accent", style: .body, color: .accent)
        }

        HStack(spacing: Theme.Spacing.md) {
            DSIcon("checkmark.circle.fill", size: .large, color: .success)
            DSLabel("Success", style: .body, color: .success)
        }

        HStack(spacing: Theme.Spacing.md) {
            DSIcon("exclamationmark.triangle.fill", size: .large, color: .warning)
            DSLabel("Warning", style: .body, color: .warning)
        }

        HStack(spacing: Theme.Spacing.md) {
            DSIcon("xmark.circle.fill", size: .large, color: .error)
            DSLabel("Error", style: .body, color: .error)
        }

        HStack {
            Spacer()
            HStack(spacing: Theme.Spacing.md) {
                DSIcon("star.fill", size: .large, color: .white)
                DSLabel("White", style: .body, color: .white)
            }
            Spacer()
        }
        .padding()
        .background(Theme.Colors.primary)
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Recipe Icons") {
    VStack(spacing: Theme.Spacing.lg) {
        DSLabel("Common Recipe Icons", style: .headline)

        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.md) {
                DSIcon("clock", size: .medium, color: .secondary)
                DSLabel("Prep/Cook Time", style: .body)
            }

            HStack(spacing: Theme.Spacing.md) {
                DSIcon("person.2", size: .medium, color: .secondary)
                DSLabel("Servings", style: .body)
            }

            HStack(spacing: Theme.Spacing.md) {
                DSIcon("fork.knife", size: .medium, color: .secondary)
                DSLabel("Cuisine Type", style: .body)
            }

            HStack(spacing: Theme.Spacing.md) {
                DSIcon("heart.fill", size: .medium, color: .error)
                DSLabel("Favorite", style: .body)
            }

            HStack(spacing: Theme.Spacing.md) {
                DSIcon("bookmark.fill", size: .medium, color: .accent)
                DSLabel("Saved", style: .body)
            }

            HStack(spacing: Theme.Spacing.md) {
                DSIcon("flame", size: .medium, color: .warning)
                DSLabel("Spicy", style: .body)
            }

            HStack(spacing: Theme.Spacing.md) {
                DSIcon("leaf", size: .medium, color: .success)
                DSLabel("Vegetarian", style: .body)
            }

            HStack(spacing: Theme.Spacing.md) {
                DSIcon("link", size: .medium, color: .primary)
                DSLabel("Source URL", style: .body)
            }

            HStack(spacing: Theme.Spacing.md) {
                DSIcon("square.and.arrow.up", size: .medium, color: .primary)
                DSLabel("Share", style: .body)
            }

            HStack(spacing: Theme.Spacing.md) {
                DSIcon("trash", size: .medium, color: .error)
                DSLabel("Delete", style: .body)
            }
        }
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Icon Usage in Context") {
    VStack(spacing: Theme.Spacing.lg) {
        // Recipe card header
        HStack {
            DSLabel("Spaghetti Carbonara", style: .recipeTitle)
            Spacer()
            DSIcon("heart.fill", size: .large, color: .error)
        }

        // Metadata row
        HStack(spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.xs) {
                DSIcon("clock", size: .small, color: .secondary)
                DSLabel("30 min", style: .metadata, color: .secondary)
            }

            HStack(spacing: Theme.Spacing.xs) {
                DSIcon("person.2", size: .small, color: .secondary)
                DSLabel("4 servings", style: .metadata, color: .secondary)
            }

            HStack(spacing: Theme.Spacing.xs) {
                DSIcon("fork.knife", size: .small, color: .secondary)
                DSLabel("Italian", style: .metadata, color: .secondary)
            }
        }

        Divider()

        // Success message
        HStack(spacing: Theme.Spacing.sm) {
            DSIcon("checkmark.circle.fill", size: .medium, color: .success)
            DSLabel("Recipe saved successfully", style: .body, color: .success)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.success.opacity(0.1))
        .cornerRadius(Theme.CornerRadius.md)

        // Error message
        HStack(spacing: Theme.Spacing.sm) {
            DSIcon("xmark.circle.fill", size: .medium, color: .error)
            DSLabel("Failed to load recipe", style: .body, color: .error)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.error.opacity(0.1))
        .cornerRadius(Theme.CornerRadius.md)

        // Warning message
        HStack(spacing: Theme.Spacing.sm) {
            DSIcon("exclamationmark.triangle.fill", size: .medium, color: .warning)
            DSLabel("Some ingredients may be out of stock", style: .body, color: .warning)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.warning.opacity(0.1))
        .cornerRadius(Theme.CornerRadius.md)
    }
    .padding()
    .background(Theme.Colors.background)
}

// MARK: - Dark Mode Previews

#Preview("Dark: Icon Colors") {
    VStack(spacing: Theme.Spacing.md) {
        HStack(spacing: Theme.Spacing.md) {
            DSIcon("star.fill", size: .large, color: .primary)
            DSLabel("Primary", style: .body, color: .primary)
        }

        HStack(spacing: Theme.Spacing.md) {
            DSIcon("star.fill", size: .large, color: .secondary)
            DSLabel("Secondary", style: .body, color: .secondary)
        }

        HStack(spacing: Theme.Spacing.md) {
            DSIcon("star.fill", size: .large, color: .accent)
            DSLabel("Accent", style: .body, color: .accent)
        }

        HStack(spacing: Theme.Spacing.md) {
            DSIcon("checkmark.circle.fill", size: .large, color: .success)
            DSLabel("Success", style: .body, color: .success)
        }

        HStack(spacing: Theme.Spacing.md) {
            DSIcon("exclamationmark.triangle.fill", size: .large, color: .warning)
            DSLabel("Warning", style: .body, color: .warning)
        }

        HStack(spacing: Theme.Spacing.md) {
            DSIcon("xmark.circle.fill", size: .large, color: .error)
            DSLabel("Error", style: .body, color: .error)
        }
    }
    .padding()
    .background(Theme.Colors.background)
    .preferredColorScheme(.dark)
}
