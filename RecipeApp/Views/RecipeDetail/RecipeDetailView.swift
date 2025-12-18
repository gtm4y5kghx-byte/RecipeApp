import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: RecipeDetailViewModel?
    @State private var showingEditSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var error: Error?
    
    let recipe: Recipe
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let viewModel = viewModel {
                    RecipeDetailHeader(
                        title: viewModel.recipe.title,
                        isFavorite: viewModel.recipe.isFavorite,
                        onFavoriteTap: {
                            viewModel.toggleFavorite()
                        }
                    )
                    
                    RecipeDetailImage(
                        imageURL: viewModel.recipe.imageURL
                    )
                    
                    RecipeDetailMetaData(
                        totalTime: viewModel.recipe.totalTime,
                        servings: viewModel.recipe.servings,
                        cuisine: viewModel.recipe.cuisine,
                        sourceURL: viewModel.recipe.sourceURL
                    )
                    
                    RecipeDetailTags(tags: viewModel.recipe.userTags)
                    
                    RecipeDetailIngredients(
                        ingredients: viewModel.recipe.ingredients
                    )
                    
                    RecipeDetailInstructions(
                        instructions: viewModel.recipe.instructions
                    )
                } else {
                    DSLoadingSpinner(message: "Loading recipe...")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel == nil {
                viewModel = RecipeDetailViewModel(
                    recipe: recipe,
                    modelContext: modelContext
                )
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, configurations: config)
    
    SampleData.loadSampleRecipes(into: container.mainContext)
    let recipes = try! container.mainContext.fetch(FetchDescriptor<Recipe>())
    
    return NavigationStack {
        RecipeDetailView(recipe: recipes[0])
    }
    .modelContainer(container)
}
