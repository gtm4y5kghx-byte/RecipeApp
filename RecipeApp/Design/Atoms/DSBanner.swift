import SwiftUI

struct DSBanner: View {

    let message: String
    let icon: String
    let style: BannerStyle

    enum BannerStyle {
        case info
        case warning
        case error
        case success

        var backgroundColor: Color {
            switch self {
            case .info: return Theme.Colors.accent.opacity(0.12)
            case .warning: return Theme.Colors.warning.opacity(0.12)
            case .error: return Theme.Colors.error.opacity(0.12)
            case .success: return Theme.Colors.success.opacity(0.12)
            }
        }
    }

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            DSIcon(icon, size: .small, color: iconColor)
            DSLabel(message, style: .subheadline, color: labelColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.sm)
        .background(style.backgroundColor)
    }

    private var iconColor: DSIcon.IconColor {
        switch style {
        case .info: return .accent
        case .warning: return .warning
        case .error: return .error
        case .success: return .success
        }
    }

    private var labelColor: DSLabel.LabelColor {
        switch style {
        case .info: return .accent
        case .warning: return .warning
        case .error: return .error
        case .success: return .success
        }
    }
}

#Preview("All Styles") {
    VStack(spacing: Theme.Spacing.md) {
        DSBanner(message: "No Internet Connection", icon: "wifi.slash", style: .warning)
        DSBanner(message: "Recipe saved successfully", icon: "checkmark.circle", style: .success)
        DSBanner(message: "Generation failed", icon: "exclamationmark.triangle", style: .error)
        DSBanner(message: "New features available", icon: "info.circle", style: .info)
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Dark: All Styles") {
    VStack(spacing: Theme.Spacing.md) {
        DSBanner(message: "No Internet Connection", icon: "wifi.slash", style: .warning)
        DSBanner(message: "Recipe saved successfully", icon: "checkmark.circle", style: .success)
        DSBanner(message: "Generation failed", icon: "exclamationmark.triangle", style: .error)
        DSBanner(message: "New features available", icon: "info.circle", style: .info)
    }
    .padding()
    .background(Theme.Colors.background)
    .preferredColorScheme(.dark)
}
