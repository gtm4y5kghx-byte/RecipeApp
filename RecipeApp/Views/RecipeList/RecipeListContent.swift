import SwiftUI

struct RecipeListContent: View {
    @Environment(\.isSearching) private var isSearching

    let items: [RecipeListItem]
    let searchText: String
    let selectedSectionTitle: String?
    let selectedSectionIcon: String?
    let hasRecipes: Bool
    @Binding var scrollPosition: ScrollPosition
    @Binding var searchScope: SearchScope
    var selectedRecipe: Binding<Recipe?>?
    let onFavoriteTap: (Recipe) -> Void
    let onDeleteTap: (Recipe) -> Void
    let onSaveGeneratedRecipe: (GeneratedRecipe) -> Void
    let onAddRecipe: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if isSearching {
                SearchScopePicker(selectedScope: $searchScope)
            }

            if items.isEmpty {
                emptyState
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                RecipeGrid(
                    items: items,
                    scrollPosition: $scrollPosition,
                    selectedRecipe: selectedRecipe,
                    onFavoriteTap: onFavoriteTap,
                    onDeleteTap: onDeleteTap,
                    onSaveGeneratedRecipe: onSaveGeneratedRecipe
                )
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if isSearching && !searchText.isEmpty {
            DSEmptyState(
                icon: "magnifyingglass",
                title: "No Results Found",
                message: String(localized: "We couldn't find any recipes matching '\(searchText)'."),
                accessibilityID: "recipe-list-no-results-empty-state"
            )
        } else if let sectionTitle = selectedSectionTitle, let sectionIcon = selectedSectionIcon {
            DSEmptyState(
                icon: sectionIcon,
                title: String(localized: "No \(sectionTitle)"),
                message: "No recipes found in this category.",
                accessibilityID: "recipe-list-section-empty-state"
            )
        } else if !hasRecipes {
            DSEmptyState(
                icon: "fork.knife",
                title: "No Recipes Yet",
                message: "Start building your recipe collection.",
                actionTitle: "Add Recipe",
                action: onAddRecipe,
                accessibilityID: "recipe-list-empty-state"
            )
        }
    }
}

#Preview {
    @Previewable @State var scrollPosition = ScrollPosition(edge: .top)
    @Previewable @State var searchScope: SearchScope = .all

    RecipeListContent(
        items: [],
        searchText: "",
        selectedSectionTitle: nil,
        selectedSectionIcon: nil,
        hasRecipes: false,
        scrollPosition: $scrollPosition,
        searchScope: $searchScope,
        onFavoriteTap: { _ in },
        onDeleteTap: { _ in },
        onSaveGeneratedRecipe: { _ in },
        onAddRecipe: {}
    )
}
