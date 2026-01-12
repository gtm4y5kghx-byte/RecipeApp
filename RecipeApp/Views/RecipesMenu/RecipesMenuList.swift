import SwiftUI

/// Shared menu list used by both iPad sidebar and iPhone sheet
struct RecipesMenuList: View {
    let filterOptions: [MenuOption]
    let tagOptions: [MenuOption]
    var selectedOptionID: String? = nil
    let onSelectOption: (String) -> Void
    let onNewRecipe: () -> Void
    let onSettings: () -> Void

    var body: some View {
        List {
            Section("Actions") {
                Button {
                    onNewRecipe()
                } label: {
                    Label("New Recipe", systemImage: "plus")
                }
                .accessibilityIdentifier("menu-new-recipe-button")
            }

            Section("Filters") {
                ForEach(filterOptions) { option in
                    Button {
                        onSelectOption(option.id)
                    } label: {
                        Label {
                            HStack {
                                Text(option.title)
                                Spacer()
                                if let count = option.count {
                                    Text("\(count)")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        } icon: {
                            Image(systemName: option.icon)
                        }
                    }
                    .listRowBackground(selectedOptionID == option.id ? Color.accentColor.opacity(0.15) : nil)
                    .accessibilityIdentifier("menu-filter-\(option.id)")
                }
            }

            if !tagOptions.isEmpty {
                Section("Tags") {
                    ForEach(tagOptions) { option in
                        Button {
                            onSelectOption(option.id)
                        } label: {
                            Label {
                                HStack {
                                    Text(option.title)
                                    Spacer()
                                    if let count = option.count {
                                        Text("\(count)")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            } icon: {
                                Image(systemName: option.icon)
                            }
                        }
                        .listRowBackground(selectedOptionID == option.id ? Color.accentColor.opacity(0.15) : nil)
                        .accessibilityIdentifier("menu-tag-\(option.id)")
                    }
                }
            }

            Section {
                Button {
                    onSettings()
                } label: {
                    Label("Settings", systemImage: "gear")
                }
                .accessibilityIdentifier("menu-settings-button")
            }
        }
        .listStyle(.sidebar)
    }
}

#Preview {
    RecipesMenuList(
        filterOptions: [
            MenuOption(id: "all", title: "All", icon: "book", count: 42),
            MenuOption(id: "favorites", title: "Favorites", icon: "heart.fill", count: 8),
            MenuOption(id: "recent", title: "Recently Cooked", icon: "clock", count: 5)
        ],
        tagOptions: [
            MenuOption(id: "italian", title: "Italian", icon: "tag", count: 12),
            MenuOption(id: "quick", title: "Quick", icon: "tag", count: 8)
        ],
        selectedOptionID: "all",
        onSelectOption: { _ in },
        onNewRecipe: {},
        onSettings: {}
    )
}
