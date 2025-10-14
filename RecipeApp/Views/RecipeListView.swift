import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Query private var recipes: [Recipe]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(recipes) { recipe in
                    VStack(alignment: .leading) {
                        Text(recipe.title)
                            .font(.headline)
                        
                        Text("\(recipe.sourceType.rawValue)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(Text("Recipes"))
        }
    }
}

#Preview {
    RecipeListView()
}
