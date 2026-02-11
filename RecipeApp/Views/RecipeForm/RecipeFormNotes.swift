import SwiftUI

struct RecipeFormNotes: View {
    @Binding var notes: String

    var body: some View {
        DSSection("Notes", titleColor: .accent, spacing: Theme.Spacing.md) {
            DSFormField(
                label: "Notes",
                placeholder: "Add notes",
                text: $notes,
                accessibilityID: "recipe-form-notes-field"
            )
        }
    }
}
