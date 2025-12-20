import SwiftUI
import SwiftData

struct RecipeDetailIngredients: View {
    let groupedIngredients: [(section: String?, ingredients: [Ingredient])]
    
    var body: some View {
        if !groupedIngredients.isEmpty {
            DSSection("Ingredients") {
                ForEach(groupedIngredients, id: \.section) { group in
                    if let section = group.section {
                        DSLabel(section, style: .headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    ForEach(Array(group.ingredients.enumerated()), id: \.element.id) { index, ingredient in
                        HStack(alignment: .top) {
                            DSLabel(ingredient.displayText, style: .body, color: .primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
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
