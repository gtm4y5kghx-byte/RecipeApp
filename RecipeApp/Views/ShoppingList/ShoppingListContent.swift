import SwiftUI
import SwiftData

struct ShoppingListContent: View {
    @Bindable var viewModel: ShoppingListViewModel
    @State private var newItemText = ""
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.lg) {
                if !viewModel.commonIngredientGroups.isEmpty {
                    commonIngredientsSection
                }
                
                ForEach(viewModel.recipeGroups) { group in
                    recipeSection(group)
                }
                
                if !viewModel.manualItems.isEmpty {
                    otherSection
                }
                
                addItemField
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
    
    // MARK: - Add Item
    
    private var addItemField: some View {
        HStack(spacing: Theme.Spacing.md) {
            DSIcon("plus.circle", size: .medium, color: .tertiary)
            
            TextField("Add item", text: $newItemText)
                .submitLabel(.done)
                .onSubmit {
                    guard !newItemText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    viewModel.addManualItem(item: newItemText)
                    newItemText = ""
                }
        }
        .padding(.vertical, Theme.Spacing.sm)
        .padding(.horizontal, Theme.Spacing.md)
    }
}
