import SwiftUI

/// Design System Button Component
/// Supports multiple styles, sizes, and states with consistent theming
struct DSButton: View {

    // MARK: - Configuration

    let title: String
    let style: ButtonStyle
    let size: ButtonSize
    let icon: String?
    let action: () -> Void
    let fullWidth: Bool

    @Environment(\.isEnabled) private var isEnabled

    // MARK: - Styles

    enum ButtonStyle {
        case primary    // Solid burgundy background
        case secondary  // Outlined burgundy
        case tertiary   // Text only
        case destructive // Error color for dangerous actions
    }

    enum ButtonSize {
        case small
        case medium
        case large

        var fontSize: Font {
            switch self {
            case .small: return Theme.Typography.callout
            case .medium: return Theme.Typography.buttonLabel
            case .large: return Theme.Typography.headline
            }
        }

        var verticalPadding: CGFloat {
            switch self {
            case .small: return Theme.Spacing.sm
            case .medium: return Theme.Spacing.md
            case .large: return Theme.Spacing.lg
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: return Theme.Spacing.md
            case .medium: return Theme.Spacing.buttonPadding
            case .large: return Theme.Spacing.lg
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .small: return Theme.CornerRadius.sm
            case .medium: return Theme.CornerRadius.md
            case .large: return Theme.CornerRadius.md
            }
        }
    }

    // MARK: - Initializer

    init(
        title: String,
        style: ButtonStyle = .primary,
        size: ButtonSize = .medium,
        icon: String? = nil,
        fullWidth: Bool = true,
        action: @escaping () -> Void,
    ) {
        self.title = title
        self.style = style
        self.size = size
        self.icon = icon
        self.action = action
        self.fullWidth = fullWidth
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(size.fontSize)
                }

                Text(title)
                    .font(size.fontSize)
            }
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(size.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isEnabled ? 1.0 : 0.5)
    }

    // MARK: - Style Properties

    private var backgroundColor: Color {
        guard isEnabled else {
            return Theme.Colors.backgroundDark
        }

        switch style {
        case .primary:
            return Theme.Colors.primary
        case .secondary:
            return .clear
        case .tertiary:
            return .clear
        case .destructive:
            return Theme.Colors.error
        }
    }

    private var foregroundColor: Color {
        guard isEnabled else {
            return Theme.Colors.textTertiary
        }

        switch style {
        case .primary:
            return .white
        case .secondary:
            return Theme.Colors.primary
        case .tertiary:
            return Theme.Colors.primary
        case .destructive:
            return .white
        }
    }

    private var borderColor: Color {
        guard isEnabled else {
            return Theme.Colors.border
        }

        switch style {
        case .primary:
            return .clear
        case .secondary:
            return Theme.Colors.primary
        case .tertiary:
            return .clear
        case .destructive:
            return .clear
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .secondary:
            return 2
        default:
            return 0
        }
    }
}

// MARK: - Previews

#Preview("Button Styles") {
    VStack(spacing: Theme.Spacing.lg) {
        DSButton(title: "Primary Button", style: .primary) {}
        DSButton(title: "Secondary Button", style: .secondary) {}
        DSButton(title: "Tertiary Button", style: .tertiary) {}
        DSButton(title: "Destructive Button", style: .destructive) {}
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Button Sizes") {
    VStack(spacing: Theme.Spacing.lg) {
        DSButton(title: "Small Button", style: .primary, size: .small) {}
        DSButton(title: "Medium Button", style: .primary, size: .medium) {}
        DSButton(title: "Large Button", style: .primary, size: .large) {}
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Buttons with Icons") {
    VStack(spacing: Theme.Spacing.lg) {
        DSButton(title: "Save Recipe", style: .primary, icon: "bookmark.fill") {}
        DSButton(title: "Share", style: .secondary, icon: "square.and.arrow.up") {}
        DSButton(title: "Delete", style: .destructive, icon: "trash") {}
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Button States") {
    VStack(spacing: Theme.Spacing.lg) {
        DSButton(title: "Normal State", style: .primary) {}

        DSButton(title: "Disabled State", style: .primary) {}
            .disabled(true)

        DSButton(title: "Disabled Secondary", style: .secondary) {}
            .disabled(true)
    }
    .padding()
    .background(Theme.Colors.background)
}
