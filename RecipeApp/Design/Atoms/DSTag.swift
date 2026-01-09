import SwiftUI

/// Design System Tag Component
/// Small labeled pills for categories, filters, and metadata
struct DSTag: View {

    // MARK: - Configuration

    let text: String
    let style: TagStyle
    let size: TagSize
    let icon: String?

    // MARK: - Tag Style

    enum TagStyle {
        case primary    // Burgundy background
        case secondary  // Light background with burgundy text
        case accent     // Golden bronze
        case neutral    // Gray background
        case success    // Green (e.g., "Vegetarian")
        case outline    // Just border, no fill

        var backgroundColor: Color {
            switch self {
            case .primary: return Theme.Colors.primary
            case .secondary: return Theme.Colors.primary.opacity(0.1)
            case .accent: return Theme.Colors.accent
            case .neutral: return Theme.Colors.backgroundDark
            case .success: return Theme.Colors.success.opacity(0.15)
            case .outline: return .clear
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary: return .white
            case .secondary: return Theme.Colors.primary
            case .accent: return .white
            case .neutral: return Theme.Colors.textSecondary
            case .success: return Theme.Colors.success
            case .outline: return Theme.Colors.textPrimary
            }
        }

        var borderColor: Color {
            switch self {
            case .outline: return Theme.Colors.border
            default: return .clear
            }
        }

        var borderWidth: CGFloat {
            switch self {
            case .outline: return 1
            default: return 0
            }
        }
    }

    // MARK: - Tag Size

    enum TagSize {
        case small
        case medium
        case large

        var font: Font {
            switch self {
            case .small: return Theme.Typography.caption2
            case .medium: return Theme.Typography.caption1
            case .large: return Theme.Typography.footnote
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: return Theme.Spacing.sm
            case .medium: return Theme.Spacing.sm + 2
            case .large: return Theme.Spacing.md
            }
        }

        var verticalPadding: CGFloat {
            switch self {
            case .small: return Theme.Spacing.xs
            case .medium: return Theme.Spacing.xs + 2
            case .large: return Theme.Spacing.sm
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 12
            case .large: return 14
            }
        }
    }

    // MARK: - Initializer

    init(
        _ text: String,
        style: TagStyle = .secondary,
        size: TagSize = .medium,
        icon: String? = nil
    ) {
        self.text = text
        self.style = style
        self.size = size
        self.icon = icon
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: size.iconSize))
            }

            Text(text)
                .font(size.font)
        }
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .foregroundColor(style.foregroundColor)
        .background(style.backgroundColor)
        .cornerRadius(Theme.CornerRadius.full)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.full)
                .stroke(style.borderColor, lineWidth: style.borderWidth)
        )
    }
}

// MARK: - Previews

#Preview("Tag Styles") {
    VStack(spacing: Theme.Spacing.md) {
        HStack(spacing: Theme.Spacing.sm) {
            DSTag("Italian", style: .primary)
            DSTag("Quick", style: .secondary)
            DSTag("Premium", style: .accent)
        }

        HStack(spacing: Theme.Spacing.sm) {
            DSTag("30 min", style: .neutral)
            DSTag("Vegetarian", style: .success)
            DSTag("Dinner", style: .outline)
        }
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Tag Sizes") {
    VStack(spacing: Theme.Spacing.md) {
        HStack(spacing: Theme.Spacing.sm) {
            DSTag("Small", style: .primary, size: .small)
            DSTag("Medium", style: .primary, size: .medium)
            DSTag("Large", style: .primary, size: .large)
        }

        HStack(spacing: Theme.Spacing.sm) {
            DSTag("Compact", style: .secondary, size: .small)
            DSTag("Standard", style: .secondary, size: .medium)
            DSTag("Prominent", style: .secondary, size: .large)
        }
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Tags with Icons") {
    VStack(spacing: Theme.Spacing.md) {
        HStack(spacing: Theme.Spacing.sm) {
            DSTag("Italian", style: .primary, icon: "fork.knife")
            DSTag("30 min", style: .neutral, icon: "clock")
            DSTag("4 servings", style: .outline, icon: "person.2")
        }

        HStack(spacing: Theme.Spacing.sm) {
            DSTag("Favorite", style: .accent, icon: "heart.fill")
            DSTag("Vegetarian", style: .success, icon: "leaf")
            DSTag("Spicy", style: .secondary, icon: "flame")
        }
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Recipe Tags Example") {
    VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
        DSLabel("Spaghetti Carbonara", style: .recipeTitle)

        // Metadata tags
        HStack(spacing: Theme.Spacing.sm) {
            DSTag("30 min", style: .neutral, size: .small, icon: "clock")
            DSTag("4 servings", style: .neutral, size: .small, icon: "person.2")
            DSTag("Easy", style: .success, size: .small)
        }

        Divider()

        // Category tags
        DSLabel("Categories", style: .caption1, color: .secondary)

        // Note: Tags will naturally wrap using HStack in real views
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            HStack(spacing: Theme.Spacing.sm) {
                DSTag("Italian", style: .primary)
                DSTag("Pasta", style: .secondary)
                DSTag("Dinner", style: .secondary)
            }
            HStack(spacing: Theme.Spacing.sm) {
                DSTag("Quick Meals", style: .secondary)
                DSTag("Comfort Food", style: .secondary)
            }
        }

        Divider()

        // Dietary tags
        DSLabel("Dietary", style: .caption1, color: .secondary)

        HStack(spacing: Theme.Spacing.sm) {
            DSTag("Vegetarian", style: .success, icon: "leaf")
            DSTag("Gluten-Free Option", style: .outline)
        }
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Filter Tags") {
    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
        DSLabel("Active Filters", style: .caption1, color: .secondary)

        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            HStack(spacing: Theme.Spacing.sm) {
                DSTag("Italian", style: .primary, size: .small)
                DSTag("Under 30 min", style: .primary, size: .small, icon: "clock")
                DSTag("Vegetarian", style: .success, size: .small, icon: "leaf")
            }
            HStack(spacing: Theme.Spacing.sm) {
                DSTag("Dinner", style: .secondary, size: .small)
                DSTag("4 servings", style: .neutral, size: .small)
            }
        }
    }
    .padding()
    .background(Theme.Colors.background)
}

// MARK: - Dark Mode Previews

#Preview("Dark: Tag Styles") {
    VStack(spacing: Theme.Spacing.md) {
        HStack(spacing: Theme.Spacing.sm) {
            DSTag("Italian", style: .primary)
            DSTag("Quick", style: .secondary)
            DSTag("Premium", style: .accent)
        }

        HStack(spacing: Theme.Spacing.sm) {
            DSTag("30 min", style: .neutral)
            DSTag("Vegetarian", style: .success)
            DSTag("Dinner", style: .outline)
        }
    }
    .padding()
    .background(Theme.Colors.background)
    .preferredColorScheme(.dark)
}

#Preview("Dark: Tags with Icons") {
    VStack(spacing: Theme.Spacing.md) {
        HStack(spacing: Theme.Spacing.sm) {
            DSTag("Italian", style: .primary, icon: "fork.knife")
            DSTag("30 min", style: .neutral, icon: "clock")
            DSTag("4 servings", style: .outline, icon: "person.2")
        }

        HStack(spacing: Theme.Spacing.sm) {
            DSTag("Favorite", style: .accent, icon: "heart.fill")
            DSTag("Vegetarian", style: .success, icon: "leaf")
            DSTag("Spicy", style: .secondary, icon: "flame")
        }
    }
    .padding()
    .background(Theme.Colors.background)
    .preferredColorScheme(.dark)
}
