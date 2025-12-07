import SwiftUI

struct RecipeIngredientsSection: View {
    let ingredients: [Ingredient]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ingredients")
                .font(.headline)

            ForEach(ingredients) { ingredient in
                HStack(alignment: .top) {
                    Image(systemName: "circle")
                        .foregroundStyle(.secondary)

                    Text(IngredientFormatter.format(ingredient))
                }
            }
        }
    }
}
