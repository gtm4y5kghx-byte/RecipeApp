import SwiftUI

struct RecipesMenuSheet: View {
    @Environment(\.dismiss) private var dismiss

    let filterOptions: [MenuOption]
    let tagOptions: [MenuOption]
    var selectedOptionID: String? = nil
    let onSelectOption: (String) -> Void
    let onNewRecipe: () -> Void
    let onSettings: () -> Void

    var body: some View {
        NavigationStack {
            RecipesMenuList(
                filterOptions: filterOptions,
                tagOptions: tagOptions,
                selectedOptionID: selectedOptionID,
                onSelectOption: { id in
                    dismiss()
                    onSelectOption(id)
                },
                onNewRecipe: {
                    dismiss()
                    onNewRecipe()
                },
                onSettings: {
                    dismiss()
                    onSettings()
                }
            )
            .navigationTitle("Recipes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDragIndicator(.visible)
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
        selectedOptionID: "all",
        onSelectOption: { _ in },
        onNewRecipe: {},
        onSettings: {}
    )
}
