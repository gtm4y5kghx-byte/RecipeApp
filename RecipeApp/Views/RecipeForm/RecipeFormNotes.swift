import SwiftUI

struct RecipeFormNotes: View {
    @Binding var notes: String

    var body: some View {
        DSSection("Notes") {
            DSFormField(
                label: "Notes",
                placeholder: "Add notes",
                text: $notes,
                accessibilityID: "recipe-form-notes-field"
            )
        }
    }
}
