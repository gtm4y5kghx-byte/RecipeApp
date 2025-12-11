import SwiftUI
import SwiftData

struct RecipeGrid: View {
    
    let recipes: [Recipe]
    let onRecipeTap: (Recipe) -> Void
    let onFavoriteTap: (Recipe) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.md) {
                ForEach(recipes) { recipe in
                    DSRecipeCard(
                        title: recipe.title,
                        cuisine: recipe.cuisine,
                        prepTime: recipe.prepTime,
                        cookTime: recipe.cookTime,
                        servings: recipe.servings,
                        isFavorite: recipe.isFavorite,
                        tags: recipe.userTags,
                        imageURL: recipe.imageURL,
                        onTap: {
                            onRecipeTap(recipe)
                        },
                        onFavoriteTap: {
                            onFavoriteTap(recipe)
                        }
                    )
                }
            }
            .padding(Theme.Spacing.md)
            .padding(.bottom, 80)
        }
    }
}
