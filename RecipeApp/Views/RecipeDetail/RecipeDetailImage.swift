import SwiftUI

struct RecipeDetailImage: View {
    let imageURL: String?
    
    var body: some View {
        if let imageURL = imageURL {
            DSImage(url: imageURL, height: 300)
        } else {
            DSImage(url: "https://placehold.co/400x300", height: 300)
        }
    }
}
