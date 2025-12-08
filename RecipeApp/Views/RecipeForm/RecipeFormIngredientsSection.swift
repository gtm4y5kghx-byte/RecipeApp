import SwiftUI

struct RecipeFormIngredientsSection: View {
    @Binding var ingredientFields: [String]

    var body: some View {
        Section("Ingredients") {
            ForEach(ingredientFields.indices, id: \.self) { index in
                HStack {
                    TextField("e.g., 2 cups flour", text: $ingredientFields[index])
                        .accessibilityIdentifier("ingredient-field-\(index)")

                    Button(action: {
                        ingredientFields.remove(at: index)
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundStyle(.red)
                    }
                    .disabled(ingredientFields.count == 1)
                    .accessibilityIdentifier("delete-ingredient-\(index)")
                }
            }
            .onMove { source, destination in
                ingredientFields.move(fromOffsets: source, toOffset: destination)
            }

            Button(action: {
                ingredientFields.append("")
            }) {
                Label("Add Ingredient", systemImage: "plus.circle.fill")
            }
            .accessibilityIdentifier("add-ingredient-button")
        }
    }
}
