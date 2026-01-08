import SwiftUI

struct RecipeListContent: View {
    let recipes: [Recipe]
    let isSearching: Bool
    let searchText: String
    let selectedSectionTitle: String?
    let selectedSectionIcon: String?
    let suggestionReasons: [UUID: String]
    let scrollToTopTrigger: Int
    let onRecipeTap: (Recipe) -> Void
    let onFavoriteTap: (Recipe) -> Void
    let onDeleteTap: (Recipe) -> Void
    let onClearSearch: () -> Void
    let onAddRecipe: () -> Void

    var body: some View {
        if recipes.isEmpty {
            emptyState
        } else {
            RecipeGrid(
                recipes: recipes,
                suggestionReasons: suggestionReasons,
                scrollToTopTrigger: scrollToTopTrigger,
                onRecipeTap: onRecipeTap,
                onFavoriteTap: onFavoriteTap,
                onDeleteTap: onDeleteTap
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
    RecipeListContent(
        recipes: [],
        isSearching: false,
        searchText: "",
        selectedSectionTitle: nil,
        selectedSectionIcon: nil,
        suggestionReasons: [:],
        scrollToTopTrigger: 0,
        onRecipeTap: { _ in },
        onFavoriteTap: { _ in },
        onDeleteTap: { _ in },
        onClearSearch: {},
        onAddRecipe: {}
    )
}
