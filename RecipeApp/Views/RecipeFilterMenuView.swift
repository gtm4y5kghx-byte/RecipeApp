import SwiftUI

struct RecipeFilterMenuView: View {
    @Binding var selectedSection: RecipeListView.MenuSection
    let tags: [(String, Int)]
    let onDismiss: () -> Void
    let onNewRecipe: () -> Void
    let recipeCount: (RecipeListView.MenuSection) -> Int

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button(action: {
                        onNewRecipe()
                        onDismiss()
                    }) {
                        Label("NEW RECIPE", systemImage: "plus.circle")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }

                    Button(action: {
                        // TODO: Implement Settings
                        onDismiss()
                    }) {
                        Label("SETTINGS", systemImage: "gear")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }

                Section {
                    FilterButton(
                        title: "ALL",
                        icon: "book",
                        count: recipeCount(.all),
                        isSelected: selectedSection == .all,
                        action: {
                            selectedSection = .all
                            onDismiss()
                        }
                    )

                    FilterButton(
                        title: "RECENTLY ADDED",
                        icon: "clock.arrow.circlepath",
                        count: recipeCount(.recentlyAdded),
                        isSelected: selectedSection == .recentlyAdded,
                        action: {
                            selectedSection = .recentlyAdded
                            onDismiss()
                        }
                    )

                    FilterButton(
                        title: "RECENTLY COOKED",
                        icon: "clock",
                        count: recipeCount(.recentlyCooked),
                        isSelected: selectedSection == .recentlyCooked,
                        action: {
                            selectedSection = .recentlyCooked
                            onDismiss()
                        }
                    )

                    FilterButton(
                        title: "FAVORITES",
                        icon: "heart.fill",
                        count: recipeCount(.favorites),
                        isSelected: selectedSection == .favorites,
                        action: {
                            selectedSection = .favorites
                            onDismiss()
                        }
                    )

                    FilterButton(
                        title: "UNCATEGORIZED",
                        icon: "tray",
                        count: recipeCount(.uncategorized),
                        isSelected: selectedSection == .uncategorized,
                        action: {
                            selectedSection = .uncategorized
                            onDismiss()
                        }
                    )
                }

                if !tags.isEmpty {
                    Section {
                        ForEach(tags, id: \.0) { tag, count in
                            FilterButton(
                                title: tag.uppercased(),
                                icon: "tag",
                                count: count,
                                isSelected: selectedSection == .tag(tag),
                                action: {
                                    selectedSection = .tag(tag)
                                    onDismiss()
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle("Recipes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        onDismiss()
                    }
                }
            }
        }
    }
}

struct FilterButton: View {
    let title: String
    let icon: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.blue)
                }
            }
        }
        .foregroundStyle(isSelected ? .blue : .primary)
    }
}
