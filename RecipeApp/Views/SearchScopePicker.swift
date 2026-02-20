import SwiftUI

struct SearchScopePicker: View {
    @Binding var selectedScope: SearchScope

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.sm) {
                ForEach(SearchScope.allCases, id: \.self) { scope in
                    Button {
                        selectedScope = scope
                    } label: {
                        DSTag(
                            scope.localizedName,
                            style: scope == selectedScope ? .primary : .outline,
                            size: .large
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityIdentifier("search-scope-\(scope.rawValue.lowercased())")
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
        }
    }
}

#Preview {
    @Previewable @State var scope: SearchScope = .all

    VStack {
        SearchScopePicker(selectedScope: $scope)
        Spacer()
    }
    .background(Theme.Colors.background)
}
