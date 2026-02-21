import SwiftUI

struct RecipeImportBanner: View {
    let onViewTap: () -> Void

    var body: some View {
        DSBanner(
            message: "Recipe imported successfully!",
            icon: "checkmark.circle.fill",
            style: .success,
            actionTitle: "View",
            onAction: onViewTap
        )
        .transition(.move(edge: .top).combined(with: .opacity))
        .accessibilityIdentifier("import-banner-view-button")
    }
}

#Preview {
    RecipeImportBanner(onViewTap: {})
        .padding()
        .background(Theme.Colors.background)
}
