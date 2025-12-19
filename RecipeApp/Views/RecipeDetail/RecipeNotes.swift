import SwiftUI


struct RecipeDetailNotes: View {
    let notes: String?
    
    var body: some View {
        if let notes = notes {
            DSSection("Notes") {
                DSLabel(notes)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
