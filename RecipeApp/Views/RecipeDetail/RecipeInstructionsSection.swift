import SwiftUI

struct RecipeInstructionsSection: View {
    let instructions: [Step]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Instructions")
                .font(.headline)

            ForEach(Array(instructions.enumerated()), id: \.element.id) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1).")
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)

                    Text(step.instruction)
                }
            }
        }
    }
}
