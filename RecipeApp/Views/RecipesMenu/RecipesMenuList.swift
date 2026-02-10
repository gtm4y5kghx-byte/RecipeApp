import SwiftUI

/// Shared menu list used by both iPad sidebar and iPhone sheet
struct RecipesMenuList: View {
    // Optional app sections (iPad only)
    var appSections: [MainView.Tab]? = nil
    var selectedAppSection: MainView.Tab? = nil
    var onSelectAppSection: ((MainView.Tab) -> Void)? = nil
    
    let filterOptions: [MenuOption]
    let tagOptions: [MenuOption]
    var selectedOptionID: String? = nil
    let onSelectOption: (String) -> Void
    let onNewRecipe: () -> Void
    let onSettings: () -> Void
    
    var body: some View {
        List {
            if let appSections = appSections {
                Section {
                    ForEach(appSections, id: \.self) { tab in
                        let isSelected = selectedAppSection == tab
                        Button {
                            onSelectAppSection?(tab)
                        } label: {
                            Label(tab.title, systemImage: tab.icon)
                                .fontWeight(isSelected ? .semibold : .regular)
                        }
                        .foregroundColor(Theme.Colors.backgroundLight)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .accessibilityIdentifier("menu-section-\(tab.title.lowercased().replacingOccurrences(of: " ", with: "-"))")
                    }
                }
            }
            
            Section {
                Button {
                    onNewRecipe()
                } label: {
                    Label("New Recipe", systemImage: "plus")
                }
                .foregroundColor(Theme.Colors.backgroundLight)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .accessibilityIdentifier("menu-new-recipe-button")

                DSDivider(color: .prominent, spacing: .none)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: Theme.Spacing.sm, bottom: 0, trailing: Theme.Spacing.sm))
            }

            Section {
                ForEach(filterOptions) { option in
                    let isSelected = selectedOptionID == option.id
                    Button {
                        onSelectOption(option.id)
                    } label: {
                        Label {
                            HStack {
                                Text(option.title)
                                    .fontWeight(isSelected ? .semibold : .regular)
                                Spacer()
                                if let count = option.count {
                                    Text("\(count)")
                                        .foregroundStyle(Theme.Colors.backgroundLight.opacity(0.7))
                                }
                            }
                        } icon: {
                            Image(systemName: option.icon)
                        }
                    }
                    .foregroundColor(Theme.Colors.backgroundLight)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .accessibilityIdentifier("menu-filter-\(option.id)")
                }

                DSDivider(color: .prominent, spacing: .none)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: Theme.Spacing.sm, bottom: 0, trailing: Theme.Spacing.sm))
            }

            if !tagOptions.isEmpty {
                Section {
                    ForEach(tagOptions) { option in
                        let isSelected = selectedOptionID == option.id
                        Button {
                            onSelectOption(option.id)
                        } label: {
                            Label {
                                HStack {
                                    Text(option.title)
                                        .fontWeight(isSelected ? .semibold : .regular)
                                    Spacer()
                                    if let count = option.count {
                                        Text("\(count)")
                                            .foregroundStyle(Theme.Colors.backgroundLight.opacity(0.7))
                                    }
                                }
                            } icon: {
                                Image(systemName: option.icon)
                            }
                        }
                        .foregroundColor(Theme.Colors.backgroundLight)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .accessibilityIdentifier("menu-tag-\(option.id)")
                    }

                    DSDivider(color: .prominent, spacing: .none)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: Theme.Spacing.sm, bottom: 0, trailing: Theme.Spacing.sm))
                }
            }

            Section {
                Button {
                    onSettings()
                } label: {
                    Label("Settings", systemImage: "gear")
                }
                .foregroundColor(Theme.Colors.backgroundLight)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .accessibilityIdentifier("menu-settings-button")
            }
        }
        .listStyle(.plain)
        .listSectionSpacing(0)
        .environment(\.defaultMinListRowHeight, 40)
        .scrollContentBackground(.hidden)
        .background(Theme.Colors.primary)
        .tint(Theme.Colors.accent)
        .environment(\.colorScheme, .light)
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
