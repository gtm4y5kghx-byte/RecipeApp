import SwiftUI

struct ScopedSearchBar: View {
    @Binding var searchText: String
    @Binding var searchScope: SearchScope
    let onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            DSSection {
                if !searchText.isEmpty {
                    Picker("Search In", selection: $searchScope) {
                        ForEach(SearchScope.allCases, id: \.self) { scope in
                            Text(scope.rawValue).tag(scope)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("search-scope-picker")
                }

                DSSearchBar(
                    text: $searchText,
                    onSubmit: onSubmit
                )
            }
        }
    }
}
