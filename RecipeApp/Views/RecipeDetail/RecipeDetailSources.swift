import SwiftUI

struct RecipeDetailSources : View {
    let sourceURL: String?

    var body: some View {
        if let sourceURL = sourceURL {
            DSSection {
                VStack {
                    DSLabel(sourceURL, style: .subheadline, color: .secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
