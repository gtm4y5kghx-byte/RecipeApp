import SwiftUI

struct GeneratedPlanCard: View {
    let result: MealPlanGenerationResult
    let isAdded: Bool
    let onAdd: () -> Void
    let onRemove: () -> Void
    let onSwap: () -> Void

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
            if let cuisine = result.recipe.cuisine, !cuisine.isEmpty {
                DSLabel(cuisine, style: .caption1, color: .secondary)
            }
        }
    }

    // MARK: - Actions

    @ViewBuilder
    private var actions: some View {
        if isAdded {
            Button { onRemove() } label: {
                DSIcon("arrow.uturn.backward.circle", size: .medium, color: .secondary)
            }
        } else {
            HStack(spacing: Theme.Spacing.sm) {
                Button { onSwap() } label: {
                    DSIcon("arrow.triangle.2.circlepath", size: .small, color: .secondary)
                }
                Button { onAdd() } label: {
                    DSIcon("plus.circle.fill", size: .medium, color: .accent)
                }
            }
        }
    }
}

#Preview("Not Added") {
    let recipe = Recipe(title: "Spaghetti Carbonara", sourceType: .manual)
    recipe.cuisine = "Italian"

    return GeneratedPlanCard(
        result: MealPlanGenerationResult(date: Date(), recipe: recipe),
        isAdded: false,
        onAdd: {},
        onRemove: {},
        onSwap: {}
    )
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Added") {
    let recipe = Recipe(title: "Chicken Tikka Masala", sourceType: .manual)
    recipe.cuisine = "Indian"

    return GeneratedPlanCard(
        result: MealPlanGenerationResult(date: Date(), recipe: recipe),
        isAdded: true,
        onAdd: {},
        onRemove: {},
        onSwap: {}
    )
    .padding()
    .background(Theme.Colors.background)
}
