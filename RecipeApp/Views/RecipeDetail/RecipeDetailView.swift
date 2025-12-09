import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingTransformSheet = false
    @State private var transformationPrompt = ""
    @State private var showDeleteAlert = false
    @State private var showingEditSheet = false
    @Query private var allRecipes: [Recipe]
    @State private var showingCookingMode = false
    @State private var viewModel: RecipeDetailViewModel

    init(recipe: Recipe) {
        self.recipe = recipe
        _viewModel = State(initialValue: RecipeDetailViewModel(
            recipe: recipe,
            modelContext: ModelContext(try! ModelContainer(for: Recipe.self))
        ))
    }

    private var recipeVariations: [Recipe] {
        viewModel.getVariations(from: allRecipes)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                titleSection
                sourceSection
                metadataSection
                tagsSection
                cookingHistorySection
                ingredientsSection
                instructionsSection
                notesSection
                variationsSection
                favoriteSection
                actionButtonSection
            }
            .padding()
        }
        .navigationTitle("Recipe Details")
        .toolbar{
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    viewModel.markAsCooked()
                    HapticFeedback.success.trigger()
                }) {
                    Label("I Cooked This", systemImage: "checkmark.circle")
                }
                .accessibilityIdentifier("mark-cooked-button")
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            RecipeFormView(recipe: recipe)
        }
        .sheet(isPresented: $showingTransformSheet) {
            RecipeTransformationView(recipe: recipe)
        }
        .sheet(isPresented: $showingCookingMode) {
            NavigationStack {
                CookingModeView(recipe: recipe)
            }
        }
        .onAppear {
            viewModel = RecipeDetailViewModel(recipe: recipe, modelContext: modelContext)
        }
        .errorAlert($viewModel.error)
    }
    
    private var titleSection: some View {
        Text(recipe.title).font(.largeTitle)
    }
    
    private var sourceSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(recipe.sourceType.displayName, systemImage: recipe.sourceType.icon)
            
            if let sourceURL = recipe.sourceURL,
               !sourceURL.isEmpty,
               let url = URL(string: sourceURL),
               let host = url.host {
                let displayHost = host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
                Link(destination: url) {
                    Text(displayHost)
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
        }
    }
    
    
    private var metadataSection: some View {
        RecipeMetadataSection(
            prepTime: recipe.prepTime,
            cookTime: recipe.cookTime,
            servings: recipe.servings,
            cuisine: recipe.cuisine
        )
    }
    
    private var tagsSection: some View {
        RecipeTagsSection(tags: recipe.userTags)
    }
    
    private var cookingHistorySection: some View {
        RecipeCookingHistorySection(
            timesCooked: recipe.timesCooked,
            lastMade: recipe.lastMade
        )
    }
    
    private var ingredientsSection: some View {
        RecipeIngredientsSection(ingredients: recipe.sortedIngredients)
    }
    
    private var instructionsSection: some View {
        RecipeInstructionsSection(instructions: recipe.sortedInstructions)
    }
    
    private var notesSection: some View {
        RecipeNotesSection(notes: recipe.notes)
    }
    
    private var variationsSection: some View {
        RecipeVariationsSection(variations: recipeVariations)
    }
    
    private var favoriteSection: some View {
        Button(action: {
            viewModel.toggleFavorite()
            HapticFeedback.light.trigger()
        }) {
            Label(
                recipe.isFavorite ? "Favorited" : "Favorite",
                systemImage: recipe.isFavorite ? "heart.fill" : "heart"
            )
            .foregroundStyle(recipe.isFavorite ? .red : .gray)
        }
    }
    
    private var actionButtonSection: some View {
        RecipeActionButtons(
            recipe: recipe,
            onStartCooking: { showingCookingMode = true },
            onEdit: { showingEditSheet = true },
            onTransform: { showingTransformSheet = true },
            onMarkAsCooked: {
                viewModel.markAsCooked()
                HapticFeedback.success.trigger()
            },
            onDelete: { showDeleteAlert = true },
            onShare: {
                // TODO: Implement share
            }
        )
        .alert("Delete Recipe", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if viewModel.deleteRecipe() {
                    HapticFeedback.warning.trigger()
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete '\(recipe.title)'? This action cannot be undone.")
        }
    }
}
