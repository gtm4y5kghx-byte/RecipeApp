import SwiftUI

struct RecipeListContent: View {
    let items: [RecipeListItem]
    let isSearching: Bool
    let searchText: String
    let selectedSectionTitle: String?
    let selectedSectionIcon: String?
    @Binding var scrollPosition: ScrollPosition
    var selectedRecipe: Binding<Recipe?>?
    let onFavoriteTap: (Recipe) -> Void
    let onDeleteTap: (Recipe) -> Void
    let onSaveGeneratedRecipe: (GeneratedRecipe) -> Void
    let onClearSearch: () -> Void
    let onAddRecipe: () -> Void

    var body: some View {
        if items.isEmpty {
            emptyState
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

    @ViewBuilder
    private var emptyState: some View {
        if isSearching {
            DSEmptyState(
                icon: "magnifyingglass",
                title: "No Results Found",
                message: String(localized: "We couldn't find any recipes matching '\(searchText)'. Try different keywords."),
                actionTitle: "Clear Search",
                action: onClearSearch,
                accessibilityID: "recipe-list-no-results-empty-state"
            )
        } else if let sectionTitle = selectedSectionTitle, let sectionIcon = selectedSectionIcon {
            DSEmptyState(
                icon: sectionIcon,
                title: String(localized: "No \(sectionTitle)"),
                message: "No recipes found in this category.",
                accessibilityID: "recipe-list-section-empty-state"
            )
        } else {
            DSEmptyState(
                icon: "fork.knife",
                title: "No Recipes Yet",
                message: "Start building your recipe collection by adding your first recipe.",
                actionTitle: "Add Recipe",
                action: onAddRecipe,
                accessibilityID: "recipe-list-empty-state"
            )
        }
    }
}

#Preview {
    @Previewable @State var scrollPosition = ScrollPosition(edge: .top)

    RecipeListContent(
        items: [],
        isSearching: false,
        searchText: "",
        selectedSectionTitle: nil,
        selectedSectionIcon: nil,
        scrollPosition: $scrollPosition,
        onFavoriteTap: { _ in },
        onDeleteTap: { _ in },
        onSaveGeneratedRecipe: { _ in },
        onClearSearch: {},
        onAddRecipe: {}
    )
}
