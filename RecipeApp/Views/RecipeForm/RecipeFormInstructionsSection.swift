import SwiftUI

struct RecipeFormInstructionsSection: View {
    @Binding var instructionFields: [String]

    var body: some View {
        Section("Instructions") {
            ForEach(instructionFields.indices, id: \.self) { index in
                InstructionRowView(
                    instruction: $instructionFields[index],
                    index: index,
                    canDelete: instructionFields.count > 1,
                    onDelete: {
                        instructionFields.remove(at: index)
                    }
                )
                .accessibilityIdentifier("instruction-row-\(index)")
            }
            .onMove { source, destination in
                instructionFields.move(fromOffsets: source, toOffset: destination)
            }

            Button(action: {
                instructionFields.append("")
            }) {
                Label("Add Step", systemImage: "plus.circle.fill")
            }
            .accessibilityIdentifier("add-step-button")
        }
    }
}
