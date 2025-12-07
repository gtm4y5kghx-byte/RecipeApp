import SwiftUI

struct RecipeRow: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading) {
            Text(recipe.title)
                .font(.headline)

            Text("\(recipe.sourceType.rawValue)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
