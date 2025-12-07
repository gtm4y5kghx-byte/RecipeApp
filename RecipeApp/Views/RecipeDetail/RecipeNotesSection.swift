import SwiftUI

struct RecipeNotesSection: View {
    let notes: String?

    var body: some View {
        Group {
            if let notes = notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.headline)

                    Text(notes)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
