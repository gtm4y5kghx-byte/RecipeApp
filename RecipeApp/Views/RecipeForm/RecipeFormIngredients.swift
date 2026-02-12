import SwiftUI

struct RecipeFormIngredients : View {
    @Binding var ingredients: [String]
    let onAdd: () -> Void
    let onRemove: (Int) -> Void
    
    var body: some View {
        DSSection("Ingredients", titleColor: .brand, spacing: Theme.Spacing.md, titleSpacing: Theme.Spacing.xs) {
            ForEach(ingredients.indices, id: \.self) { index in
                HStack {
                    DSFormField(
                        label: "Ingredient",
                        placeholder: "Enter ingredient",
                        text: $ingredients[index],
                        accessibilityID: "recipe-form-ingredient-\(index)-field"
                    )
                    
                    if ingredients.count > 1 {
                        DSIconButton(
                            "minus.circle.fill",
                            size: .medium,
                            color: .brand,
                            accessibilityID: "remove-ingredient-\(index)"
                        ) {
                            onRemove(index)
                        }
                    }
                }
            }
            
            DSIconButton(
                "plus.circle.fill",
                size: .medium,
                color: .brand,
                accessibilityID: "add-ingredient"
            ) {
                onAdd()
            }
        }
    }
}
