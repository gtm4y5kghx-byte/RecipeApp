import SwiftUI

struct RecipeDetailImage: View {
    let imageURL: String?

    var body: some View {
        if let imageURL = imageURL {
            DSImage(url: imageURL, height: 300)
        } else {
            DSImagePlaceholder(height: 300, cornerRadius: 0)
        }
    }
}
