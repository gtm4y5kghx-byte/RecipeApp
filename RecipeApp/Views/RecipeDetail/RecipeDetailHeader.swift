import SwiftUI

struct RecipeDetailHeader: View {
    let title: String
    let isFavorite: Bool
    let onFavoriteTap: () -> Void
    
    var body: some View {
        DSSection {
            HStack(alignment: .top, spacing: Theme.Spacing.md) {
                DSLabel(title, style: .title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: onFavoriteTap) {
                    DSIcon(
                        isFavorite ? "heart.fill" : "heart",
                        size: .large,
                        color: isFavorite ? .error : .secondary
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.lg) {
        RecipeDetailHeader(
            title: "Spaghetti Carbonara",
            isFavorite: true,
            onFavoriteTap: {}
        )
        
        RecipeDetailHeader(
            title: "Very Long Recipe Title That Should Wrap To Multiple Lines",
            isFavorite: false,
            onFavoriteTap: {}
        )
    }
}
