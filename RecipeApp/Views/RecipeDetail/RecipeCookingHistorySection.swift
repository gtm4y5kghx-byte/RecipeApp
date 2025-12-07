import SwiftUI

struct RecipeCookingHistorySection: View {
    let timesCooked: Int
    let lastMade: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cooking History")
                .font(.headline)

            if timesCooked == 0 {
                Text("Never cooked")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                HStack(spacing: 8) {
                    Text("Cooked \(timesCooked) \(timesCooked == 1 ? "time" : "times")")

                    if let lastMade = lastMade {
                        Text("·")
                        Text("Last made \(lastMade.relativeDescription())")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
    }
}
