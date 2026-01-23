import SwiftUI
import SwiftData

struct RecipeGrid: View {

    let recipes: [Recipe]
    let suggestionReasons: [UUID: String]
    @Binding var scrollPosition: ScrollPosition
    var selectedRecipe: Binding<Recipe?>?
    let onFavoriteTap: (Recipe) -> Void
    let onDeleteTap: (Recipe) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.sm) {
                ForEach(recipes) { recipe in
                    DSRecipeCard(
                        title: recipe.title,
                        cuisine: recipe.cuisine,
                        prepTime: recipe.prepTime,
                        cookTime: recipe.cookTime,
                        servings: recipe.servings,
                        isFavorite: recipe.isFavorite,
                        tags: recipe.userTags,
                        onFavoriteTap: {
                            onFavoriteTap(recipe)
                        },
                        suggestionReason: suggestionReasons[recipe.id],
                        onDeleteTap: {
                            onDeleteTap(recipe)
                        },
                        accessibilityID: "recipe-card-\(recipe.id)"
                    )
                    .padding(.horizontal, Theme.Spacing.md)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedRecipe?.wrappedValue = recipe
                    }
                }
            }
            .scrollTargetLayout()
            .padding(.top, Theme.Spacing.sm)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Theme.Colors.background)
        .scrollPosition($scrollPosition)
    }
}
