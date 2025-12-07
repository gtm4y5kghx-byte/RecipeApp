import SwiftUI

struct RecipeTagsSection: View {
    let tags: [String]

    var body: some View {
        Group {
            if !tags.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(tags.sorted(), id: \.self) { tag in
                        Text(tag)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundStyle(.blue)
                            .cornerRadius(16)
                    }
                }
            }
        }
    }
}
