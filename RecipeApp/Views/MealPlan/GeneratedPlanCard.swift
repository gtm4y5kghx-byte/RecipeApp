import SwiftUI

struct GeneratedPlanCard: View {
    let result: MealPlanGenerationResult
    let isAdded: Bool
    let onAdd: () -> Void
    let onRemove: () -> Void
    let onSwap: () -> Void
    let accessibilityID: String

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            dateBadge
            recipeInfo
            Spacer()
            actions
        }
        .padding()
        .background(isAdded ? Theme.Colors.backgroundDark : Theme.Colors.backgroundLight)
        .cornerRadius(Theme.CornerRadius.md)
        .opacity(isAdded ? 0.7 : 1.0)
        .accessibilityIdentifier(accessibilityID)
    }

    // MARK: - Date Badge

    private var dateBadge: some View {
        VStack(spacing: 2) {
            DSLabel(result.dayOfWeek, style: .caption1, color: .secondary)
            DSLabel(result.dayNumber, style: .headline)
        }
        .frame(width: 44)
    }

    // MARK: - Recipe Info

    private var recipeInfo: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            DSLabel(result.recipe.title, style: .headline)
            HStack(spacing: Theme.Spacing.xs) {
                DSLabel(result.mealType.rawValue.capitalized, style: .caption1, color: .secondary)
                if let cuisine = result.recipe.cuisine, !cuisine.isEmpty {
                    DSLabel("·", style: .caption1, color: .secondary)
                    DSLabel(cuisine, style: .caption1, color: .secondary)
                }
            }
        }
    }

    // MARK: - Actions

    @ViewBuilder
    private var actions: some View {
        if isAdded {
            DSIconButton(
                "arrow.uturn.backward.circle",
                size: .medium,
                color: .secondary,
                accessibilityID: "\(accessibilityID)-undo-button",
                action: onRemove
            )
        } else {
            HStack(spacing: Theme.Spacing.sm) {
                DSIconButton(
                    "arrow.triangle.2.circlepath",
                    size: .small,
                    color: .secondary,
                    accessibilityID: "\(accessibilityID)-swap-button",
                    action: onSwap
                )
                DSIconButton(
                    "plus.circle.fill",
                    size: .medium,
                    color: .accent,
                    accessibilityID: "\(accessibilityID)-add-button",
                    action: onAdd
                )
            }
        }
    }
}

#Preview("Not Added") {
    let recipe = Recipe(title: "Spaghetti Carbonara", sourceType: .manual)
    recipe.cuisine = "Italian"

    return GeneratedPlanCard(
        result: MealPlanGenerationResult(date: Date(), mealType: .dinner, recipe: recipe),
        isAdded: false,
        onAdd: {},
        onRemove: {},
        onSwap: {},
        accessibilityID: "preview-generated-plan-card"
    )
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Added") {
    let recipe = Recipe(title: "Chicken Tikka Masala", sourceType: .manual)
    recipe.cuisine = "Indian"

    return GeneratedPlanCard(
        result: MealPlanGenerationResult(date: Date(), mealType: .dinner, recipe: recipe),
        isAdded: true,
        onAdd: {},
        onRemove: {},
        onSwap: {},
        accessibilityID: "preview-generated-plan-card"
    )
    .padding()
    .background(Theme.Colors.background)
}
