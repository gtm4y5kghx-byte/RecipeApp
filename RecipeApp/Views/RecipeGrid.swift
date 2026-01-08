import SwiftUI
import SwiftData

struct RecipeGrid: View {

    let recipes: [Recipe]
    let suggestionReasons: [UUID: String]
    let scrollToTopTrigger: Int
    let onRecipeTap: (Recipe) -> Void
    let onFavoriteTap: (Recipe) -> Void
    let onDeleteTap: (Recipe) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            List {
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
                        },
                        suggestionReason: suggestionReasons[recipe.id],
                        onDeleteTap: {
                            onDeleteTap(recipe)
                        },
                        accessibilityID: "recipe-card-\(recipe.id)"
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: Theme.Spacing.sm, leading: Theme.Spacing.md, bottom: Theme.Spacing.sm, trailing: Theme.Spacing.md))
                    .swipeActions(edge: .trailing) {
                        Button("Delete", role: .destructive) {
                            onDeleteTap(recipe)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Theme.Colors.background)
            .contentMargins(.top, Theme.Spacing.sm, for: .scrollContent)
            .onChange(of: scrollToTopTrigger) { _, _ in
                if let firstRecipe = recipes.first {
                    withAnimation {
                        proxy.scrollTo(firstRecipe.id, anchor: .top)
                    }
                }
            }
        }
    }
}
