import SwiftUI

struct ShoppingListItemRow: View {
    let item: ShoppingListItem
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Button {
                onToggle()
            } label: {
                DSIcon(
                    item.isChecked ? "checkmark.circle.fill" : "circle",
                    size: .medium,
                    color: item.isChecked ? .success : .tertiary
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("shopping-list-item-\(item.id)-checkbox")

            DSLabel(
                item.displayText,
                style: .body,
                color: item.isChecked ? .tertiary : .primary
            )
            .strikethrough(item.isChecked)

            Spacer()
        }
        .padding(.vertical, Theme.Spacing.xs)
        .contentShape(Rectangle())
        .onTapGesture { onToggle() }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .accessibilityIdentifier("shopping-list-item-\(item.id)")
    }
}
