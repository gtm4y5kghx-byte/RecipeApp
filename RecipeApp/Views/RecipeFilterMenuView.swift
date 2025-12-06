import SwiftUI

struct RecipeFilterMenuView: View {
    @Binding var selectedSection: RecipeListView.MenuSection
    let tags: [(String, Int)]
    let onDismiss: () -> Void
    let onNewRecipe: () -> Void

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
                }

                Section {
                    FilterButton(
                        title: "ALL",
                        icon: "book",
                        isSelected: selectedSection == .all,
                        action: {
                            selectedSection = .all
                            onDismiss()
                        }
                    )

                    FilterButton(
                        title: "RECENTLY COOKED",
                        icon: "clock",
                        isSelected: selectedSection == .recentlyCooked,
                        action: {
                            selectedSection = .recentlyCooked
                            onDismiss()
                        }
                    )

                    FilterButton(
                        title: "FAVORITES",
                        icon: "heart.fill",
                        isSelected: selectedSection == .favorites,
                        action: {
                            selectedSection = .favorites
                            onDismiss()
                        }
                    )

                    FilterButton(
                        title: "UNCATEGORIZED",
                        icon: "tray",
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
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.blue)
                }
            }
        }
        .foregroundStyle(isSelected ? .blue : .primary)
    }
}
