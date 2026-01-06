import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Query(sort: \Recipe.createdAt, order: .reverse) private var recipes: [Recipe]
    @Environment(\.modelContext) private var modelContext

    var menuState: AppMenuState?

    @State private var viewModel: RecipeListViewModel?
    @State private var showImportBanner = false
    @State private var importedRecipe: Recipe?
    @State private var selectedRecipe: Recipe?
    @State private var searchText = ""
    @State private var searchScope: SearchScope = .all
    @State private var scrollToTopTrigger = 0
    @State private var error: Error?

    init(menuState: AppMenuState? = nil, previewViewModel: RecipeListViewModel? = nil) {
        self.menuState = menuState
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

                if let _ = viewModel { recipeContent } else {
                    DSLoadingSpinner(message: "Loading recipes...")
                }

                ScopedSearchBar(
                    searchText: $searchText,
                    searchScope: $searchScope,
                    onSubmit: {
                        viewModel?.performSearch(query: searchText, scope: searchScope)
                    }
                )
            }
            .background(Theme.Colors.background)
            .navigationTitle(viewModel?.filterTitle ?? "Recipes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if viewModel?.hasActiveFilter == true {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            viewModel?.selectedSection = .all
                        } label: {
                            HStack(spacing: Theme.Spacing.xs) {
                                Image(systemName: "chevron.left")
                                Text("Recipes")
                            }
                        }
                        .accessibilityIdentifier("clear-filter-button")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        menuState?.showingMenu = true
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
            }
            .navigationDestination(item: $selectedRecipe) { recipe in
                RecipeDetailView(recipe: recipe)
            }
        }
        .sheet(item: $importedRecipe) { recipe in
            // TODO: RecipeDetailView
            Text("Recipe Detail View Coming Soon")
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
        .onChange(of: viewModel?.selectedSection) { _, _ in
            scrollToTopTrigger += 1
        }
        .onAppear {
            handleViewAppear()
        }
    }
    
    @ViewBuilder
    private var recipeContent: some View {
        if let viewModel = viewModel {
            RecipeListContent(
                recipes: viewModel.displayedRecipes,
                isSearching: viewModel.isSearching,
                searchText: searchText,
                selectedSectionTitle: viewModel.filterTitle,
                selectedSectionIcon: viewModel.filterIcon,
                suggestionReasons: viewModel.suggestionReasons,
                scrollToTopTrigger: scrollToTopTrigger,
                onRecipeTap: { recipe in
                    selectedRecipe = recipe
                },
                onFavoriteTap: { recipe in
                    viewModel.toggleFavorite(recipe)
                },
                onDeleteTap: { recipe in
                    viewModel.deleteRecipe(recipe)
                },
                onClearSearch: {
                    searchText = ""
                },
                onAddRecipe: {
                    menuState?.newRecipe()
                }
            )
        } else {
            DSLoadingSpinner(message: "Loading recipes...")
        }
    }
    
    private func handleViewAppear() {
        if viewModel == nil {
            viewModel = RecipeListViewModel(
                recipes: recipes,
                modelContext: modelContext,
                menuState: menuState
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
        
        Task {
            await viewModel?.loadSuggestionsIfEligible()
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
