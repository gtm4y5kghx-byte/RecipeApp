import SwiftUI

struct CookingModeIngredientsSheet: View {
    let ingredients: [Ingredient]
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            List(ingredients) { ingredient in
                DSLabel(IngredientFormatter.format(ingredient), style: .body)
            }
            .navigationTitle("Ingredients")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { onDismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
