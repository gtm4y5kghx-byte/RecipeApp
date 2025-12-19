import SwiftUI
import SwiftData

struct RecipeDetailIngredients: View {
    let ingredients: [Ingredient]
    
    var body: some View {
        if !ingredients.isEmpty {
            DSSection("Ingredients") {
                ForEach(ingredients) { ingredient in
                    HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                        DSIcon("circle.fill", size: .small, color: .secondary)
                            .padding(.top, 4)
                        
                        DSLabel(ingredient.displayText, style: .body, color: .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, configurations: config)
    
    SampleData.loadSampleRecipes(into: container.mainContext)
    let recipes = try! container.mainContext.fetch(FetchDescriptor<Recipe>())
    
    return RecipeDetailIngredients(ingredients: recipes[0].ingredients)
        .modelContainer(container)
}
