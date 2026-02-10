import SwiftUI

struct RecipeDetailImage: View {
    let imageURL: String?

    var body: some View {
        if let imageURL = imageURL {
            DSImage(url: imageURL, height: 300)
        } else {
            ZStack {
                Rectangle()
                    .fill(Theme.Colors.backgroundDark)
                Image(systemName: "fork.knife")
                    .font(.system(size: 48))
                    .foregroundColor(Theme.Colors.textTertiary)
            }
            .frame(height: 300)
        }
    }
}
