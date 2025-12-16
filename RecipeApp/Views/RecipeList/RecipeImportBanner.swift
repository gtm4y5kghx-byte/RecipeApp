import SwiftUI

struct RecipeImportBanner: View {
    let onViewTap: () -> Void

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            DSIcon("checkmark.circle.fill", size: .medium, color: .success)
            DSLabel("Recipe imported successfully!", style: .body, color: .success)
            Spacer()
            DSButton(title: "View", style: .secondary, size: .small) {
                onViewTap()
            }
            .accessibilityIdentifier("import-banner-view-button")
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.success.opacity(0.1))
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
