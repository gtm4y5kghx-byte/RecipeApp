import SwiftUI

struct CookingStepDisplay: View {
    let progressText: String
    let stepInstruction: String

    var body: some View {
        VStack(spacing: 12) {
            Text(progressText)
                .font(.headline)
                .foregroundStyle(.secondary)

            ScrollView {
                Text(stepInstruction)
                    .font(.title2)
                    .padding()
            }
        }
    }
}
