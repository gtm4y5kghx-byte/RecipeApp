import SwiftUI
import SwiftData
import Swipy

struct RecipeGrid: View {

    let recipes: [Recipe]
    let suggestionReasons: [UUID: String]
    @Binding var scrollPosition: ScrollPosition
    var selectedRecipe: Binding<Recipe?>?
    let onFavoriteTap: (Recipe) -> Void
    let onDeleteTap: (Recipe) -> Void

    @State private var isSwipingAnItem = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.sm) {
                ForEach(recipes) { recipe in
                    Swipy(isSwipingAnItem: $isSwipingAnItem) { model in
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
                    } actions: {
                        SwipyAction { model in
                            Button {
                                onDeleteTap(recipe)
                                model.unswipe()
                            } label: {
                                Image(systemName: "trash")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding(.horizontal, Theme.Spacing.lg)
                                    .background(Theme.Colors.error)
                            }
                        }
                    }
                }
            }
            .scrollTargetLayout()
            .padding(.top, Theme.Spacing.sm)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Theme.Colors.background)
        .scrollPosition($scrollPosition)
        .scrollDisabled(isSwipingAnItem)
    }
}
