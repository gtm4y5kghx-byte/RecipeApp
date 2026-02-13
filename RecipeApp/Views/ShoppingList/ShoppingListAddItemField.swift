import SwiftUI

struct ShoppingListAddItemField: View {
    @Bindable var viewModel: ShoppingListViewModel
    @Binding var newItemText: String

    var body: some View {
        DSTextField(
            placeholder: "Add item",
            text: $newItemText,
            icon: "plus.circle.fill",
            accessibilityID: "shopping-list-add-item-field"
        )
        .submitLabel(.done)
        .onSubmit {
            guard !newItemText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            viewModel.addManualItem(item: newItemText)
            newItemText = ""
        }
    }
}
