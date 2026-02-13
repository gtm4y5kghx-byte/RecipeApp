import SwiftUI

/// Reusable row for displaying premium feature benefits in upsell contexts
struct PremiumFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
            DSIcon(icon, size: .medium, color: .adaptiveBrand)
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                DSLabel(title, style: .headline)
                DSLabel(description, style: .subheadline, color: .secondary)
            }
        }
    }
}

// MARK: - Convenience initializers using PremiumFeatureCopy

extension PremiumFeatureRow {
    static var suggestions: PremiumFeatureRow {
        PremiumFeatureRow(
            icon: "sparkles",
            title: PremiumFeatureCopy.Suggestions.title,
            description: PremiumFeatureCopy.Suggestions.description
        )
    }

    static var generation: PremiumFeatureRow {
        PremiumFeatureRow(
            icon: "wand.and.stars",
            title: PremiumFeatureCopy.Generation.title,
            description: PremiumFeatureCopy.Generation.description
        )
    }

    static var mealPlanning: PremiumFeatureRow {
        PremiumFeatureRow(
            icon: "calendar",
            title: PremiumFeatureCopy.MealPlanning.title,
            description: PremiumFeatureCopy.MealPlanning.description
        )
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
        PremiumFeatureRow.mealPlanning
        PremiumFeatureRow.suggestions
        PremiumFeatureRow.generation
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Dark") {
    VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
        PremiumFeatureRow.mealPlanning
        PremiumFeatureRow.suggestions
        PremiumFeatureRow.generation
    }
    .padding()
    .background(Theme.Colors.background)
    .preferredColorScheme(.dark)
}
