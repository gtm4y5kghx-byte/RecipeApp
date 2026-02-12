import SwiftUI

struct RecipeFormNotes: View {
    @Binding var notes: String

    var body: some View {
        DSSection("Notes", titleColor: .brand, spacing: Theme.Spacing.md, titleSpacing: Theme.Spacing.xs) {
            DSFormField(
                label: "Notes",
                placeholder: "Add notes",
                text: $notes,
                accessibilityID: "recipe-form-notes-field"
            )
        }
    }
}
