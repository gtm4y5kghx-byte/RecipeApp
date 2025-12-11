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

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Recipe.self,
        configurations: config
    )
    
    let recipes = [
        Recipe(title: "Pasta Carbonara", sourceType: .manual),
        Recipe(title: "Chicken Tikka Masala", sourceType: .manual),
        Recipe(title: "Caesar Salad", sourceType: .manual),
        Recipe(title: "Thai Green Curry", sourceType: .manual),
    ]
    
    recipes[0].cuisine = "Italian"
    recipes[0].prepTime = 10
    recipes[0].cookTime = 20
    recipes[0].imageURL = "https://placehold.co/400x300"
    
    recipes[1].cuisine = "Indian"
    recipes[1].prepTime = 30
    recipes[1].cookTime = 45
    recipes[1].imageURL = "https://placehold.co/400x300"
    
    recipes[2].cuisine = "American"
    recipes[2].prepTime = 5
    recipes[2].imageURL = "https://placehold.co/400x300"
    
    recipes[3].cuisine = "Thai"
    recipes[3].prepTime = 15
    recipes[3].cookTime = 20
    recipes[3].isFavorite = true
    recipes[3].imageURL = "https://placehold.co/400x300"
    
    return RecipeGrid(
        recipes: recipes,
        onRecipeTap: { recipe in
            print("Tapped: \(recipe.title)")
        },
        onFavoriteTap: { recipe in
            print("Favorited: \(recipe.title)")
        }
    )
    .modelContainer(container)
}
