import SwiftUI

struct CookingModeIngredientsSheet: View {
    let ingredients: [Ingredient]
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                DSSection("Ingredients", titleColor: .accent, verticalPadding: Theme.Spacing.md) {
                    ForEach(Array(ingredients.enumerated()), id: \.element.id) { index, ingredient in
                        DSLabel(ingredient.displayText, style: .body, color: .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if index < ingredients.count - 1 {
                            DSDivider(thickness: .thin, color: .subtle, spacing: .compact)
                                .opacity(0.7)
                        }
                    }
                }
                .frame(maxWidth: Theme.Layout.maxSheetContentWidth)
                .frame(maxWidth: .infinity)
            }
            .background(Theme.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { onDismiss() }
                        .accessibilityIdentifier("cooking-mode-ingredients-done-button")
                }
            }
        }
    }
}
