import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: RecipeDetailViewModel?
    @State private var showingEditSheet = false
    @State private var showingCookingMode = false
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
                    
                    DSSection {
                        HStack(spacing: Theme.Spacing.xs) {
                            RecipeDetailMetaData(
                                totalTime: viewModel.formattedTotalTime,
                                servings: viewModel.recipe.servings,
                                cuisine: viewModel.recipe.cuisine,
                            )
                            
                            Spacer()
                            
                            VStack {
                                DSButton(
                                    title: "I Cooked This",
                                    style: .secondary,
                                    size: .small,
                                    fullWidth: false
                                ) {
                                    HapticFeedback.success.trigger()
                                    viewModel.markAsCooked()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    RecipeDetailTags(
                        tags: viewModel.recipe.userTags
                    )
                    
                    RecipeDetailSources(
                        sourceURL: viewModel.recipe.sourceURL
                    )
                    
                    RecipeDetailIngredients(
                        groupedIngredients: viewModel.groupedIngredients
                    )
                    
                    RecipeDetailInstructions(
                        instructions: viewModel.recipe.instructions
                    )
                    
                    RecipeDetailNotes(
                        notes: viewModel.recipe.notes
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Start Cooking") { showingCookingMode = true }
                    Button("Add to Shopping List") {}
                    Button("Edit") { showingEditSheet = true }
                    Button("Delete", role: .destructive) { showingDeleteConfirmation = true }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            Text("RecipeFormView goes here")
        }
        .sheet(isPresented: $showingCookingMode) {
            Text("CookingView goes here")
        }
        .alert("Delete Recipe?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                guard let viewModel = viewModel else { return }
                if viewModel.deleteRecipe() {
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) { }
        }
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
    NavigationStack {
        RecipeDetailView(recipe: SampleData.createApplePie())
    }
}
