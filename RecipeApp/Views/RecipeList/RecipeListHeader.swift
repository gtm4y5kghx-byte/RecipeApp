import SwiftUI

struct RecipeListHeader: View {
    let title: String
    let hasFilter: Bool
    let filterIcon: String?
    let filterTitle: String?
    let onMenuTap: () -> Void
    let onClearFilter: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            HStack {
                DSLabel(title, style: .largeTitle)
                Spacer()
                MenuButton {
                    onMenuTap()
                }
            }

            if hasFilter, let filterIcon = filterIcon, let filterTitle = filterTitle {
                HStack(spacing: Theme.Spacing.xs) {
                    DSIcon(filterIcon, size: .small, color: .secondary)
                    DSLabel(filterTitle, style: .caption1, color: .secondary)

                    Button {
                        onClearFilter()
                    } label: {
                        DSIcon("xmark.circle.fill", size: .small, color: .tertiary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityIdentifier("clear-filter-button")
                }
                .padding(.horizontal, Theme.Spacing.sm)
                .padding(.vertical, Theme.Spacing.xs)
                .background(Theme.Colors.backgroundDark)
                .cornerRadius(Theme.CornerRadius.sm)
            }
        }
        .padding(Theme.Spacing.md)
    }
}

#Preview {
    VStack(spacing: 0) {
        RecipeListHeader(
            title: "Recipes",
            hasFilter: false,
            filterIcon: nil,
            filterTitle: nil,
            onMenuTap: {},
            onClearFilter: {}
        )

        RecipeListHeader(
            title: "Recipes",
            hasFilter: true,
            filterIcon: "heart.fill",
            filterTitle: "Favorites",
            onMenuTap: {},
            onClearFilter: {}
        )
    }
}
