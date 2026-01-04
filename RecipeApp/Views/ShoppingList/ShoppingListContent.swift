import SwiftUI
import SwiftData

struct ShoppingListContent: View {
    @Bindable var viewModel: ShoppingListViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                if !viewModel.commonIngredientGroups.isEmpty {
                    commonIngredientsSection
                }
                
                ForEach(viewModel.recipeGroups) { group in
                    recipeSection(group)
                }

                if !viewModel.manualItems.isEmpty {
                    otherSection
                }
            }
            .padding(Theme.Spacing.md)
        }
        .background(Theme.Colors.background)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if viewModel.hasCheckedItems {
                    Button("Clear Checked") {
                        viewModel.clearCheckedItems()
                    }
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var commonIngredientsSection: some View {
        DSSection("Common Ingredients") {
            ForEach(viewModel.commonIngredientGroups.sorted(by: { $0.key < $1.key }), id: \.key) { _, items in
                ForEach(items) { item in
                    ShoppingListItemRow(
                        item: item,
                        onToggle: { viewModel.toggleChecked(item) },
                        onDelete: { viewModel.removeItem(item) }
                    )
                }
            }
        }
    }
    
    private func recipeSection(_ group: RecipeItemGroup) -> some View {
        DSSection(group.recipeName) {
            ForEach(group.items) { item in
                ShoppingListItemRow(
                    item: item,
                    onToggle: { viewModel.toggleChecked(item) },
                    onDelete: { viewModel.removeItem(item) }
                )
            }
        }
    }
    
    private var otherSection: some View {
        DSSection("Other") {
            ForEach(viewModel.manualItems) { item in
                ShoppingListItemRow(
                    item: item,
                    onToggle: { viewModel.toggleChecked(item) },
                    onDelete: { viewModel.removeItem(item) }
                )
            }
        }
    }
}
