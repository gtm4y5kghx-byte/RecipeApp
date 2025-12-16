import SwiftUI

struct RecipeListSearchBar: View {
    @Binding var searchText: String
    @Binding var searchScope: SearchScope
    let onSubmit: () -> Void
    let onAISearch: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if !searchText.isEmpty {
                Picker("Search In", selection: $searchScope) {
                    ForEach(SearchScope.allCases, id: \.self) { scope in
                        Text(scope.rawValue).tag(scope)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.xs)
                .accessibilityIdentifier("search-scope-picker")
            }

            SearchBar(
                text: $searchText,
                onSubmit: onSubmit,
                onAISearch: onAISearch
            )
        }
    }
}
