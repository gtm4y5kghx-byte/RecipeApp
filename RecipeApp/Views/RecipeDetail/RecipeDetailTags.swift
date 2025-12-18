import SwiftUI

struct RecipeDetailTags: View {
    let tags: [String]
    
    var body: some View {
        if !tags.isEmpty {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                FlowLayout(spacing: Theme.Spacing.xs) {
                    ForEach(tags, id: \.self) { tag in
                        DSTag(tag, style: .secondary, size: .medium)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Theme.Spacing.md)
        }
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.lg) {
        RecipeDetailTags(tags: ["Italian", "Pasta", "Quick", "Dinner"])
        RecipeDetailTags(tags: [])
    }
}
