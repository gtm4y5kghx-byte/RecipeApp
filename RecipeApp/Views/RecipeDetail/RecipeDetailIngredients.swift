import SwiftUI
import SwiftData

struct RecipeDetailIngredients: View {
    let groupedIngredients: [(section: String?, ingredients: [Ingredient])]

    var body: some View {
        if !groupedIngredients.isEmpty {
            DSSection("Ingredients", titleColor: .adaptiveBrand, verticalPadding: Theme.Spacing.md) {
                ForEach(Array(groupedIngredients.enumerated()), id: \.element.section) { groupIndex, group in
                    if let section = group.section {
                        DSLabel(section, style: .headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, groupIndex > 0 ? Theme.Spacing.md : 0)
                            .padding(.bottom, Theme.Spacing.xs)
                    }

                    ForEach(Array(group.ingredients.enumerated()), id: \.element.id) { index, ingredient in
                        DSLabel(ingredient.displayText, style: .body, color: .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if index < group.ingredients.count - 1 {
                            DSDivider(thickness: .thin, color: .subtle, spacing: .compact)
                                .opacity(0.7)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    RecipeDetailIngredients(groupedIngredients: [
        (section: nil, ingredients: [
            Ingredient(quantity: "2", unit: "cups", item: "flour", preparation: nil, section: nil)
        ]),
        (section: "Filling", ingredients: [
            Ingredient(quantity: "3", unit: nil, item: "apples", preparation: "sliced", section: "Filling")
        ])
    ])
}
