import SwiftUI

struct RecipesSection: View {
    let displayedRecipes: [Recipe]
    let sectionTitle: String
    let onDelete: (IndexSet) -> Void

    var body: some View {
        Section {
            if displayedRecipes.isEmpty {
                ContentUnavailableView(
                    "No Recipes",
                    systemImage: "book.closed",
                    description: Text("Add your first recipe to get started")
                )
            } else {
                ForEach(displayedRecipes) { recipe in
                    NavigationLink(value: recipe) {
                        RecipeRow(recipe: recipe)
                    }
                }
                .onDelete(perform: onDelete)
            }
        } header: {
            Text(sectionTitle)
        }
    }
}
