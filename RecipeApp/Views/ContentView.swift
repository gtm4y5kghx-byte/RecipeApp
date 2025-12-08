import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        RecipeListView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Recipe.self, inMemory: true)
}
