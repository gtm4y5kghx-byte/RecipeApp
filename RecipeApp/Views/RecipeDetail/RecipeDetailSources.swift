import SwiftUI

struct RecipeDetailSources : View {
    let sourceURL: String?

    var body: some View {
        if let sourceURL = sourceURL {
            DSSection {
                HStack(spacing: Theme.Spacing.xs) {
                    DSLabel("Source:", style: .subheadline, color: .primary)
                    DSLabel(sourceURL, style: .subheadline, color: .adaptiveBrand)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
