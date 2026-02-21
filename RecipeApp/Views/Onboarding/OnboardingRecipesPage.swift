import SwiftUI

struct OnboardingRecipesPage: View {

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()

            DSIcon("book.fill", size: .xlarge, color: .adaptiveBrand)
                .padding(Theme.Spacing.lg)
                .background(Theme.Colors.backgroundLight)
                .clipShape(Circle())

            DSLabel("Your Recipes", style: .largeTitle, color: .primary, alignment: .center)

            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                featureRow(icon: "square.and.arrow.down", text: "Import from your favorite recipe sites")
                featureRow(icon: "folder", text: "Organize with tags")
                featureRow(icon: "flame", text: "Cook with step-by-step mode")
            }
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.top, Theme.Spacing.md)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            DSIcon(icon, size: .medium, color: .adaptiveBrand)
            DSLabel(text, style: .body, color: .primary)
        }
    }
}

#Preview {
    OnboardingRecipesPage()
}