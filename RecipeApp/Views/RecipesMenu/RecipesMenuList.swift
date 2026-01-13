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
                Section("Sections") {
                    ForEach(appSections, id: \.self) { tab in
                        Button {
                            onSelectAppSection?(tab)
                        } label: {
                            Label(tab.title, systemImage: tab.icon)
                        }
                        .listRowBackground(selectedAppSection == tab ? Color.accentColor.opacity(0.15) : nil)
                        .accessibilityIdentifier("menu-section-\(tab.title.lowercased().replacingOccurrences(of: " ", with: "-"))")
                    }
                }
            }
            
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
