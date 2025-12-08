import SwiftUI

struct InstructionRowView: View {
    @Binding var instruction: String
    let index: Int
    let canDelete: Bool
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            Text("\(index + 1).")
                .foregroundStyle(.secondary)
                .padding(.top, 8)

            TextEditor(text: $instruction)
                .frame(minHeight: 60)
                .scrollContentBackground(.hidden)
                .accessibilityIdentifier("instruction-editor-\(index)")

            Button(action: onDelete) {
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(.red)
            }
            .disabled(!canDelete)
            .padding(.top, 8)
            .accessibilityIdentifier("delete-instruction-\(index)")
        }
    }
}
