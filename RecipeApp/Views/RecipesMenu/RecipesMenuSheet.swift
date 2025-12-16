import SwiftUI

struct RecipesMenuSheet: View {

    @Environment(\.dismiss) private var dismiss

    let filterOptions: [MenuOption]
    let tagOptions: [MenuOption]
    let onSelectOption: (String) -> Void
    let onNewRecipe: () -> Void
    let onSettings: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    actionSection

                    DSDivider(spacing: .standard)

                    filtersSection

                    if !tagOptions.isEmpty {
                        DSDivider(spacing: .standard)
                        tagsSection
                    }

                    DSDivider(spacing: .standard)

                    settingsSection
                }
                .padding(.vertical, Theme.Spacing.md)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Recipes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        DSIcon("xmark", size: .medium, color: .accent)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityIdentifier("recipes-menu-close-button")
                }
            }
        }
    }

    private var actionSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            DSLabel("ACTIONS", style: .caption1, color: .secondary)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.xs)

            DSButton(
                title: "New Recipe",
                style: .primary,
                icon: "plus"
            ) {
                dismiss()
                onNewRecipe()
            }
            .accessibilityIdentifier("new-recipe-button")
            .padding(.horizontal, Theme.Spacing.md)
        }
    }

    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            DSLabel("FILTERS", style: .caption1, color: .secondary)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.xs)

            ForEach(filterOptions) { option in
                FilterRow(
                    title: option.title,
                    icon: option.icon,
                    count: option.count
                ) {
                    dismiss()
                    onSelectOption(option.id)
                }
            }
        }
    }

    private var tagsSection: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            DSLabel("TAGS", style: .caption1, color: .secondary)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.xs)

            ForEach(tagOptions) { option in
                FilterRow(
                    title: option.title,
                    icon: option.icon,
                    count: option.count
                ) {
                    dismiss()
                    onSelectOption(option.id)
                }
            }
        }
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            FilterRow(
                title: "Settings",
                icon: "gear",
                accessibilityId: "settings-row"
            ) {
                dismiss()
                onSettings()
            }
        }
    }
}

#Preview {
    RecipesMenuSheet(
        filterOptions: [
            MenuOption(id: "all", title: "All", icon: "book", count: 42),
            MenuOption(id: "favorites", title: "Favorites", icon: "heart.fill", count: 8),
            MenuOption(id: "recent", title: "Recently Cooked", icon: "clock", count: 5)
        ],
        tagOptions: [
            MenuOption(id: "italian", title: "Italian", icon: "tag", count: 12),
            MenuOption(id: "quick", title: "Quick", icon: "tag", count: 8)
        ],
        onSelectOption: { _ in },
        onNewRecipe: {},
        onSettings: {}
    )
}
