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
    @State private var recipeToDelete: Recipe?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(items) { item in
                    itemView(for: item)
                    DSDivider(thickness: .thin, color: .subtle, spacing: .none)
                        .padding(.horizontal, Theme.Spacing.md)
                }
            }
            .scrollTargetLayout()
        }
        .background(Theme.Colors.background)
        .scrollPosition($scrollPosition)
        .scrollDisabled(isSwipingAnItem)
        .alert("Delete Recipe", isPresented: .init(
            get: { recipeToDelete != nil },
            set: { if !$0 { recipeToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let recipe = recipeToDelete {
                    onDeleteTap(recipe)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            if let recipe = recipeToDelete {
                Text("Are you sure you want to delete \"\(recipe.title)\"?")
            }
        }
    }

    @ViewBuilder
    private func itemView(for item: RecipeListItem) -> some View {
        switch item {
        case .recipe(let recipe, let suggestionReason):
            recipeCardView(recipe: recipe, suggestionReason: suggestionReason)
        case .generatedRecipe(let generated, let reason):
            generatedCardView(generated: generated, reason: reason)
        }
    }

    private func recipeCardView(recipe: Recipe, suggestionReason: String?) -> some View {
        Swipy(isSwipingAnItem: $isSwipingAnItem) { model in
            DSRecipeCard(
                title: recipe.title,
                imageURL: recipe.imageURL,
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
                    recipeToDelete = recipe
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

    private func generatedCardView(generated: GeneratedRecipe, reason: String) -> some View {
        DSRecipeCard(
            title: generated.title,
            subtitle: reason,
            showSuggestionBadge: true,
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
