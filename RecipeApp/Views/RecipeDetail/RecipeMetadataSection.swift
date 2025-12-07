import SwiftUI

struct RecipeMetadataSection: View {
    let prepTime: Int?
    let cookTime: Int?
    let servings: Int?

    var body: some View {
        HStack(spacing: 16) {
            if let prepTime = prepTime {
                Label("\(prepTime) min", systemImage: "clock")
            }

            if let cookTime = cookTime {
                Label("\(cookTime) min", systemImage: "flame")
            }

            if let servings = servings {
                Label("\(servings) servings", systemImage: "fork.knife")
            }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
}
