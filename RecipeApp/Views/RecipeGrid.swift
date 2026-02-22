import SwiftUI
import SwiftData
import Swipy

struct RecipeGrid: View {

    let items: [RecipeListItem]
    @Binding var scrollPosition: ScrollPosition
    var selectedRecipe: Binding<Recipe?>?
    let onFavoriteTap: (Recipe) -> Void
    let onDeleteTap: (Recipe) -> Void
    let onSaveGeneratedRecipe: (GeneratedRecipe) -> Void

    @State private var isSwipingAnItem = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.sm) {
                ForEach(items) { item in
                    itemView(for: item)
                }
            }
            .scrollTargetLayout()
            .padding(.top, Theme.Spacing.sm)
        }
        .background(Theme.Colors.background)
        .scrollPosition($scrollPosition)
        .scrollDisabled(isSwipingAnItem)
    }

    @ViewBuilder
    private func itemView(for item: RecipeListItem) -> some View {
        switch item {
        case .recipe(let recipe, let suggestionReason):
            RecipeCardRow(
                recipe: recipe,
                suggestionReason: suggestionReason,
                isSwipingAnItem: $isSwipingAnItem,
                selectedRecipe: selectedRecipe,
                onFavoriteTap: onFavoriteTap,
                onDeleteTap: onDeleteTap
            )
        case .generatedRecipe(let generated, let reason):
            generatedCardView(generated: generated, reason: reason)
        }
    }

    private func generatedCardView(generated: GeneratedRecipe, reason: String) -> some View {
        DSRecipeCard(
            title: generated.title,
            subtitle: reason,
            showSuggestionBadge: false,
            cuisine: generated.cuisine,
            prepTime: generated.prepTime,
            cookTime: generated.cookTime,
            servings: generated.servings,
            tags: generated.tags,
            action: .save(onTap: {
                onSaveGeneratedRecipe(generated)
            }),
            accessibilityID: "generated-recipe-card-\(generated.id)"
        )
        .padding(.horizontal, Theme.Spacing.md)
    }
}

// MARK: - Recipe Card Row

private struct RecipeCardRow: View {
    let recipe: Recipe
    let suggestionReason: String?
    @Binding var isSwipingAnItem: Bool
    var selectedRecipe: Binding<Recipe?>?
    let onFavoriteTap: (Recipe) -> Void
    let onDeleteTap: (Recipe) -> Void

    var body: some View {
        Swipy(isSwipingAnItem: $isSwipingAnItem) { model in
            DSRecipeCard(
                title: recipe.title,
                subtitle: suggestionReason,
                showSuggestionBadge: suggestionReason != nil,
                cuisine: recipe.cuisine,
                prepTime: recipe.prepTime,
                cookTime: recipe.cookTime,
                servings: recipe.servings,
                tags: recipe.userTags,
                action: .favorite(isFavorite: recipe.isFavorite, onTap: {
                    onFavoriteTap(recipe)
                }),
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
