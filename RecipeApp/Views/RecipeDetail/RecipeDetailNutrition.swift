import SwiftUI

struct RecipeDetailNutrition: View {
    let nutrition: NutritionInfo?

    var body: some View {
        if let nutrition = nutrition {
            DSSection("Nutrition", titleColor: .accent, verticalPadding: Theme.Spacing.md) {
                let items = nutrition.displayItems
                ForEach(Array(items.enumerated()), id: \.element.label) { index, item in
                    HStack {
                        DSLabel(item.label)
                        Spacer()
                        DSLabel(item.value)
                    }

                    if index < items.count - 1 {
                        DSDivider(thickness: .thin, color: .subtle, spacing: .compact)
                            .opacity(0.5)
                    }
                }
            }
        }
    }
}
