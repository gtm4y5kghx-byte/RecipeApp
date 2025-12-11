import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Query(sort: \Recipe.createdAt, order: .reverse) private var recipes: [Recipe]
    @Environment(\.modelContext) private var modelContext
    
    @State private var viewModel: RecipeListViewModel?
    @State private var showingMenu = false
    @State private var showImportBanner = false
    @State private var importedRecipe: Recipe?
    @State private var selectedRecipe: Recipe?
    
    @State private var searchText = ""
    @State private var showingAISearch = false
    
    @State private var error: Error?
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    if showImportBanner { importBanner }
                    
                    headerView
                    
                    if let viewModel = viewModel {
                        RecipeGrid(
                            recipes: recipes,
                            onRecipeTap: { recipe in
                                selectedRecipe = recipe
                            },
                            onFavoriteTap: { recipe in
                                viewModel.toggleFavorite(recipe)
                            }
                        )
                    } else {
                        DSLoadingSpinner(message: "Loading recipes...")
                    }
                }
                .background(Theme.Colors.background)
                
                SearchBar(
                    text: $searchText,
                    onSubmit: {
                        // TODO: Handle basic search submission
                    },
                    onAISearch: {
                        showingAISearch = true
                    }
                )
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = RecipeListViewModel(
                        recipes: recipes,
                        modelContext: modelContext
                    )
                }
                
                viewModel?.handlePendingImport()
                
                if viewModel?.justImportedRecipe == true {
                    showImportBanner = true
                    HapticFeedback.success.trigger()
                    
                    Task {
                        try? await Task.sleep(for: .seconds(3))
                        withAnimation {
                            showImportBanner = false
                        }
                        viewModel?.justImportedRecipe = false
                    }
                }
            }
            .onChange(of: recipes) { oldValue, newValue in
                viewModel?.updateRecipes(newValue)
            }
            .sheet(isPresented: $showingMenu) {
                if let viewModel = viewModel {
                    RecipesMenuSheet(
                        viewModel: viewModel,
                        onNewRecipe: {
                            // TODO: Navigate to recipe form
                        },
                        onSettings: {
                            // TODO: Navigate to settings
                        }
                    )
                }
            }
            .sheet(item: $importedRecipe) { recipe in
                // TODO: RecipeDetailView
                Text("Recipe Detail View Coming Soon")
            }
            .sheet(isPresented: $showingAISearch) {
                // TODO: AI Search Modal
                Text("AI Search Coming Soon")
            }
        }
    }
    
    private var importBanner: some View {
        HStack(spacing: Theme.Spacing.sm) {
            DSIcon("checkmark.circle.fill", size: .medium, color: .success)
            DSLabel("Recipe imported successfully!", style: .body, color: .success)
            Spacer()
            DSButton(title: "View", style: .secondary, size: .small) {
                importedRecipe = recipes.first
            }
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.success.opacity(0.1))
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    
    private var headerView: some View {
        HStack {
            DSLabel("Recipes", style: .largeTitle)
            Spacer()
            MenuButton {
                showingMenu = true
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.backgroundLight)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Recipe.self,
        configurations: config
    )
    
    SampleData.loadSampleRecipes(into: container.mainContext)
    
    return RecipeListView()
        .modelContainer(container)
}
