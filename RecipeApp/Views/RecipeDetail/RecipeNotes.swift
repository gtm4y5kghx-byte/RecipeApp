import SwiftUI


struct RecipeDetailNotes: View {
    let notes: String?
    
    var body: some View {
        if let notes = notes {
            DSSection("Notes", titleColor: .accent, verticalPadding: Theme.Spacing.md) {
                DSLabel(notes)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
