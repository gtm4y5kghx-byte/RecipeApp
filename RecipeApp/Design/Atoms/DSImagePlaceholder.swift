import SwiftUI

/// Design System Image Placeholder
/// Displays a consistent placeholder when recipe images are unavailable
struct DSImagePlaceholder: View {

    // MARK: - Configuration

    let height: CGFloat
    let cornerRadius: CGFloat

    // MARK: - Computed Properties

    private var iconSize: CGFloat {
        // Scale icon size based on height
        min(height * 0.25, 48)
    }

    // MARK: - Initializer

    init(height: CGFloat, cornerRadius: CGFloat = Theme.CornerRadius.md) {
        self.height = height
        self.cornerRadius = cornerRadius
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Theme.Colors.backgroundDark)
            Image(systemName: "fork.knife")
                .font(.system(size: iconSize))
                .foregroundColor(Theme.Colors.textTertiary)
        }
        .frame(height: height)
    }
}

// MARK: - Previews

#Preview("Placeholder Sizes") {
    VStack(spacing: Theme.Spacing.lg) {
        DSLabel("Small (48pt - thumbnail)", style: .caption1, color: .secondary)
        DSImagePlaceholder(height: 48)
            .frame(width: 48)

        DSLabel("Medium (160pt - card)", style: .caption1, color: .secondary)
        DSImagePlaceholder(height: 160)

        DSLabel("Large (300pt - detail)", style: .caption1, color: .secondary)
        DSImagePlaceholder(height: 300, cornerRadius: 0)
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Dark: Placeholder") {
    VStack(spacing: Theme.Spacing.lg) {
        DSImagePlaceholder(height: 160)
        DSImagePlaceholder(height: 48)
            .frame(width: 48)
    }
    .padding()
    .background(Theme.Colors.background)
    .preferredColorScheme(.dark)
}
