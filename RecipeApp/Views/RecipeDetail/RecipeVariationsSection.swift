import SwiftUI

struct RecipeVariationsSection: View {
    let variations: [Recipe]

    var body: some View {
        Group {
            if !variations.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Variations")
                        .font(.headline)

                    ForEach(variations) { variation in
                        NavigationLink(value: variation) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(variation.title)
                                        .font(.subheadline)

                                    if let note = variation.variationNote {
                                        Text(note)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
    }
}
