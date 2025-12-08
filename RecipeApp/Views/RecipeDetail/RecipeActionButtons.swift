import SwiftUI
import SwiftData

struct RecipeActionButtons: View {
    let recipe: Recipe
    let onStartCooking: () -> Void
    let onEdit: () -> Void
    let onTransform: () -> Void
    let onMarkAsCooked: () -> Void
    let onDelete: () -> Void
    let onShare: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onStartCooking) {
                Label("Start Cooking", systemImage: "flame")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("start-cooking-button")

            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("edit-recipe-button")

            Button(action: onTransform) {
                Label("Transform", systemImage: "wand.and.stars")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("transform-recipe-button")

            Button(action: onMarkAsCooked) {
                Label("I made this", systemImage: "checkmark.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("mark-cooked-action-button")

            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("delete-recipe-button")

            Button(action: onShare) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("share-recipe-button")
        }
    }
}
