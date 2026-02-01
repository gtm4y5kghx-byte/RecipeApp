import SwiftUI

struct OnboardingAIFeaturesPage: View {

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()

            DSIcon("sparkles", size: .xlarge, color: .accent)
                .scaleEffect(1.5)
                .padding(Theme.Spacing.xl)
                .background(Theme.Colors.backgroundLight)
                .clipShape(Circle())

            DSLabel("AI-Powered", style: .largeTitle, color: .primary, alignment: .center)

            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                featureRow(icon: "lightbulb", text: "Smart recipe suggestions")
                featureRow(icon: "calendar", text: "Automated meal planning")
                featureRow(icon: "wand.and.stars", text: "Recipe generation")
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
            DSIcon(icon, size: .medium, color: .accent)
            DSLabel(text, style: .body, color: .primary)
        }
    }
}

#Preview {
    OnboardingAIFeaturesPage()
}
