import SwiftUI

/// Design System Icon Button Component
/// Consistent icon-only button styling with optional backgrounds
struct DSIconButton: View {

    // MARK: - Configuration

    let icon: String
    let size: DSIcon.IconSize
    let color: DSIcon.IconColor
    let style: ButtonStyle
    let bounceValue: Bool?
    let accessibilityID: String
    let action: () -> Void

    // MARK: - Button Style

    enum ButtonStyle {
        case plain          // Just the icon, no background
        case filled         // Icon with circular colored background

        // Filled style background colors
        case filledPrimary  // Primary color background, white icon
        case filledAccent   // Accent color background, white icon
    }

    // MARK: - Initializer

    init(
        _ icon: String,
        size: DSIcon.IconSize = .medium,
        color: DSIcon.IconColor = .primary,
        style: ButtonStyle = .plain,
        bounceValue: Bool? = nil,
        accessibilityID: String,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.color = color
        self.style = style
        self.bounceValue = bounceValue
        self.accessibilityID = accessibilityID
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            iconContent
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityIdentifier(accessibilityID)
    }

    @ViewBuilder
    private var iconContent: some View {
        switch style {
        case .plain:
            DSIcon(icon, size: size, color: color, bounceValue: bounceValue)

        case .filled:
            DSIcon(icon, size: size, color: color, bounceValue: bounceValue)
                .padding(padding)
                .background(Theme.Colors.backgroundLight)
                .clipShape(Circle())

        case .filledPrimary:
            DSIcon(icon, size: size, color: .white, bounceValue: bounceValue)
                .padding(padding)
                .background(Theme.Colors.primary)
                .clipShape(Circle())
                .shadow(color: Theme.Colors.primary.opacity(0.3), radius: 4, x: 0, y: 2)

        case .filledAccent:
            DSIcon(icon, size: size, color: .white, bounceValue: bounceValue)
                .padding(padding)
                .background(Theme.Colors.accent)
                .clipShape(Circle())
                .shadow(color: Theme.Colors.accent.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }

    private var padding: CGFloat {
        switch size {
        case .small: return Theme.Spacing.sm
        case .medium: return Theme.Spacing.md
        case .large: return Theme.Spacing.md
        case .xlarge: return Theme.Spacing.lg
        }
    }
}

// MARK: - Previews

#Preview("Plain Style") {
    HStack(spacing: Theme.Spacing.lg) {
        DSIconButton("heart", size: .small, color: .secondary, accessibilityID: "preview-1") {}
        DSIconButton("heart.fill", size: .medium, color: .error, accessibilityID: "preview-2") {}
        DSIconButton("star.fill", size: .large, color: .accent, accessibilityID: "preview-3") {}
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Filled Styles") {
    VStack(spacing: Theme.Spacing.lg) {
        HStack(spacing: Theme.Spacing.lg) {
            DSIconButton("plus", size: .medium, style: .filled, accessibilityID: "preview-1") {}
            DSIconButton("xmark", size: .medium, style: .filled, accessibilityID: "preview-2") {}
        }

        HStack(spacing: Theme.Spacing.lg) {
            DSIconButton("line.3.horizontal", size: .medium, style: .filledPrimary, accessibilityID: "preview-3") {}
            DSIconButton("plus", size: .medium, style: .filledAccent, accessibilityID: "preview-4") {}
        }
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Common Use Cases") {
    VStack(spacing: Theme.Spacing.lg) {
        // Favorite button
        HStack {
            DSLabel("Favorite Toggle", style: .body)
            Spacer()
            DSIconButton("heart", size: .large, color: .secondary, accessibilityID: "favorite") {}
            DSIconButton("heart.fill", size: .large, color: .error, accessibilityID: "favorite-active") {}
        }

        // Action buttons
        HStack {
            DSLabel("Actions", style: .body)
            Spacer()
            DSIconButton("arrow.triangle.2.circlepath", size: .small, color: .secondary, accessibilityID: "swap") {}
            DSIconButton("plus.circle.fill", size: .medium, color: .accent, accessibilityID: "add") {}
        }

        // Menu button
        HStack {
            DSLabel("Menu Button", style: .body)
            Spacer()
            DSIconButton("line.3.horizontal", size: .medium, style: .filledPrimary, accessibilityID: "menu") {}
        }
    }
    .padding()
    .background(Theme.Colors.background)
}

// MARK: - Dark Mode Previews

#Preview("Dark: Icon Buttons") {
    VStack(spacing: Theme.Spacing.lg) {
        HStack(spacing: Theme.Spacing.lg) {
            DSIconButton("heart.fill", size: .medium, color: .error, accessibilityID: "preview-1") {}
            DSIconButton("star.fill", size: .medium, color: .accent, accessibilityID: "preview-2") {}
            DSIconButton("plus", size: .medium, style: .filledPrimary, accessibilityID: "preview-3") {}
        }
    }
    .padding()
    .background(Theme.Colors.background)
    .preferredColorScheme(.dark)
}
