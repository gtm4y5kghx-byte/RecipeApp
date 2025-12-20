import SwiftUI

struct RecipeDetailVariations: View {
    let variations: [Recipe]
    
    var body: some View {
        if !variations.isEmpty {
            DSSection("Variations") {
                ForEach(variations) { variation in
                    NavigationLink(value: variation) {
                        DSLabel(variation.title)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}
