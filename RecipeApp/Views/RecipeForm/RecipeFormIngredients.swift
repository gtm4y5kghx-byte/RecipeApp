import SwiftUI

struct RecipeFormIngredients : View {
    @Binding var ingredients: [String]
    let onAdd: () -> Void
    let onRemove: (Int) -> Void
    
    var body: some View {
        DSSection("Ingredients") {
            ForEach(ingredients.indices, id: \.self) { index in
                HStack {
                    DSFormField(
                        label: "Ingredient",
                        placeholder: "Enter ingredient",
                        text: $ingredients[index],
                        accessibilityID: "recipe-form-ingredient-\(index)-field"
                    )
                    
                    if ingredients.count > 1 {
                        DSButton(title: "Remove Ingredient",
                                 style: .tertiary,
                                 icon: "minus.circle.fill",
                                 fullWidth: false
                        ) {
                            onRemove(index)
                        }
                    }
                }
            }
            
            DSButton(
                title: "Add Ingredient",
                style: .tertiary,
                icon: "plus.circle.fill",
                fullWidth: false
            ) {
                onAdd()
            }
        }
    }
}
