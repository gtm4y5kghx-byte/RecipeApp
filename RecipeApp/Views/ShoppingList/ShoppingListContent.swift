import SwiftUI
import SwiftData

struct ShoppingListContent: View {
    @Bindable var viewModel: ShoppingListViewModel
    @Binding var newItemText: String
    @State private var showingClearAllConfirmation = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.lg) {
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
        .scrollDismissesKeyboard(.interactively)
        .background(Theme.Colors.background)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    if viewModel.hasCheckedItems {
                        Button("Clear Checked") {
                            viewModel.clearCheckedItems()
                        }
                        .accessibilityIdentifier("shopping-list-clear-checked-button")
                    }
                    Button("Clear All", role: .destructive) {
                        showingClearAllConfirmation = true
                    }
                    .accessibilityIdentifier("shopping-list-clear-all-button")
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .disabled(!viewModel.hasItems)
                .accessibilityIdentifier("shopping-list-menu-button")
            }
        }
        .alert(String(localized: "Clear Shopping List?"), isPresented: $showingClearAllConfirmation) {
            Button(String(localized: "Clear All"), role: .destructive) {
                viewModel.clearAllItems()
            }
            Button(String(localized: "Cancel"), role: .cancel) { }
        } message: {
            Text(String(localized: "This will remove all items from your shopping list."))
        }
    }
    
    // MARK: - Sections

    private func recipeSection(_ group: RecipeItemGroup) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            DSLabel(group.recipeName, style: .title3, color: .adaptiveBrand)
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
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            DSLabel("Other", style: .title3, color: .adaptiveBrand)
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
        ShoppingListAddItemField(viewModel: viewModel, newItemText: $newItemText)
    }
}
