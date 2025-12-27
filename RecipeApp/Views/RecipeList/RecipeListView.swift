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
    @State private var searchScope: SearchScope = .all
    @State private var showSettings = false
    @State private var showingNewRecipe = false
    @State private var error: Error?
    
    init(previewViewModel: RecipeListViewModel? = nil) {
        _viewModel = State(initialValue: previewViewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if showImportBanner {
                    RecipeImportBanner {
                        importedRecipe = recipes.first
                    }
                }
                
                ScrollView {
                    if let viewModel = viewModel {
                        RecipeListHeader(
                            title: "Recipes",
                            hasFilter: viewModel.hasActiveFilter,
                            filterIcon: viewModel.filterIcon,
                            filterTitle: viewModel.filterTitle,
                            onMenuTap: { showingMenu = true },
                            onClearFilter: { viewModel.selectedSection = .all }
                        )
                        
                        RecipeListContent(
                            recipes: viewModel.displayedRecipes,
                            isSearching: viewModel.isSearching,
                            searchText: searchText,
                            selectedSectionTitle: viewModel.filterTitle,
                            selectedSectionIcon: viewModel.filterIcon,
                            onRecipeTap: { recipe in
                                selectedRecipe = recipe
                            },
                            onFavoriteTap: { recipe in
                                viewModel.toggleFavorite(recipe)
                            },
                            onClearSearch: {
                                searchText = ""
                            },
                            onAddRecipe: {
                                showingNewRecipe = true
                            }
                        )
                    } else {
                        DSLoadingSpinner(message: "Loading recipes...")
                    }
                }
                
                Spacer()
                
                RecipeListSearchBar(
                    searchText: $searchText,
                    searchScope: $searchScope,
                    onSubmit: {
                        viewModel?.performSearch(query: searchText, scope: searchScope)
                    },
                )
            }
            .background(Theme.Colors.background)
            .navigationDestination(item: $selectedRecipe) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .sheet(isPresented: $showingMenu) {
                recipeMenuSheet()
            }
            .sheet(item: $importedRecipe) { recipe in
                // TODO: RecipeDetailView
                Text("Recipe Detail View Coming Soon")
            }
            .sheet(isPresented: $showingNewRecipe) {
                RecipeFormView(recipe: nil)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .onChange(of: recipes) { oldValue, newValue in
                viewModel?.updateRecipes(newValue)
            }
            .onChange(of: searchText) { oldValue, newValue in
                viewModel?.performSearch(query: newValue, scope: searchScope)
            }
            .onChange(of: searchScope) { oldValue, newValue in
                viewModel?.performSearch(query: searchText, scope: newValue)
            }
            .onAppear {
                handleViewAppear()
            }
        }
    }
    
    @ViewBuilder
    private func recipeMenuSheet() -> some View {
        if let viewModel = viewModel {
            RecipesMenuSheet(
                filterOptions: viewModel.filterMenuOptions,
                tagOptions: viewModel.tagMenuOptions,
                onSelectOption: { optionId in
                    viewModel.selectMenuOption(optionId)
                },
                onNewRecipe: {
                    showingNewRecipe = true
                },
                onSettings: {
                    showSettings = true
                }
            )
        }
    }
    
    private func handleViewAppear() {
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
            
            Task {
                await viewModel?.loadSuggestions()
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, configurations: config)
    
    SampleData.loadSampleRecipes(into: container.mainContext)
    let recipes = try! container.mainContext.fetch(FetchDescriptor<Recipe>())
    
    let mockViewModel = RecipeListViewModel(recipes: recipes, modelContext: container.mainContext)
    mockViewModel.suggestions = [
        RecipeSuggestion(recipeID: recipes[0].id, aiGeneratedReason: "You haven't cooked this in a while"),
        RecipeSuggestion(recipeID: recipes[1].id, aiGeneratedReason: "Quick weeknight dinner"),
        RecipeSuggestion(recipeID: recipes[2].id, aiGeneratedReason: "Quick weekend dinner")
    ]
    
    return RecipeListView(previewViewModel: mockViewModel)
        .modelContainer(container)
}
