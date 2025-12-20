import SwiftUI

struct RecipeDetailSources : View {
    let basedOnRecipe: Recipe?
    let sourceURL: String?
    
    var body: some View {
        DSSection {
            if let basedOnRecipe = basedOnRecipe {
                HStack(spacing: Theme.Spacing.xs) {
                    DSLabel("Based on:", style: .footnote, color: .secondary)
                    NavigationLink(value: basedOnRecipe) {
                        DSLabel(basedOnRecipe.title, style: .footnote)
                    }
                }
            }
            
            if let sourceURL = sourceURL {
                VStack {
                    DSLabel(sourceURL, style: .subheadline, color: .secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
