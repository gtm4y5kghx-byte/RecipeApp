import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    @Query private var allRecipes: [Recipe]
    
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
                        totalTime: viewModel.formattedTotalTime,
                        servings: viewModel.recipe.servings,
                        cuisine: viewModel.recipe.cuisine,
                        sourceURL: viewModel.recipe.sourceURL,
                        basedOnRecipe: viewModel.getBasedOnRecipe(from: allRecipes)
                    )
                    
                    RecipeDetailTags(
                        tags: viewModel.recipe.userTags
                    )
                    
                    RecipeDetailIngredients(
                        ingredients: viewModel.recipe.ingredients
                    )
                    
                    RecipeDetailInstructions(
                        instructions: viewModel.recipe.instructions
                    )
                    
                    RecipeDetailNotes(
                        notes: viewModel.recipe.notes
                    )
                    
                    RecipeDetailVariations(
                        variations: viewModel.getVariations(from: allRecipes)
                        
                    )
                    
                    RecipeDetailNutrition(
                        nutrition: viewModel.recipe.nutrition
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
    let container = try! ModelContainer(
        for: Recipe.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let applePie = SampleData.createApplePie()
    let dutchApplePie = SampleData.createDutchApplePie()
    dutchApplePie.basedOnRecipeID = applePie.id
    dutchApplePie.variationNote = "Dutch-style with streusel topping"
    
    container.mainContext.insert(applePie)
    container.mainContext.insert(dutchApplePie)
    
    return NavigationStack {
        RecipeDetailView(recipe: applePie)
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
    }
    .modelContainer(container)
}
