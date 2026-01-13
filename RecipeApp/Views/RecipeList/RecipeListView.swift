import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Query(sort: \Recipe.createdAt, order: .reverse) private var recipes: [Recipe]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var menuState: AppMenuState?
    
    @State private var viewModel: RecipeListViewModel?
    @State private var showImportBanner = false
    @State private var importedRecipe: Recipe?
    @State private var searchText = ""
    @State private var searchScope: SearchScope = .all
    @State private var scrollToTopTrigger = 0
    @State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly
    @State private var error: Error?
    
    init(menuState: AppMenuState? = nil, previewViewModel: RecipeListViewModel? = nil) {
        self.menuState = menuState
        _viewModel = State(initialValue: previewViewModel)
    }
    
    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
        .sheet(item: $importedRecipe) { recipe in
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
        .onChange(of: viewModel?.displayedRecipes) { _, _ in
            viewModel?.autoSelectFirstRecipeIfNeeded(
                isRegularSizeClass: horizontalSizeClass == .regular
            )
        }
        .onAppear {
            handleViewAppear()
        }
    }
    
    private var selectedRecipeBinding: Binding<Recipe?> {
        Binding(
            get: { viewModel?.selectedRecipe },
            set: { viewModel?.selectedRecipe = $0 }
        )
    }
    
    // MARK: - Shared Content
    
    private var recipeListColumn: some View {
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
    }
    
    // MARK: - iPhone Layout
    
    private var iPhoneLayout: some View {
        NavigationStack {
            recipeListColumn
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
                        .accessibilityIdentifier("recipe-list-menu-button")
                    }
                    
#if DEBUG
                    ToolbarItem(placement: .topBarLeading) {
                        devToolsMenu
                    }
#endif
                }
                .navigationDestination(item: selectedRecipeBinding) { recipe in
                    RecipeDetailView(recipe: recipe)
                }
        }
    }
    
    // MARK: - iPad Layout
    
    private var iPadLayout: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            RecipesMenuList(
                filterOptions: viewModel?.filterMenuOptions ?? [],
                tagOptions: viewModel?.tagMenuOptions ?? [],
                selectedOptionID: viewModel?.selectedSection.id,
                onSelectOption: { id in
                    viewModel?.selectMenuOption(id)
                },
                onNewRecipe: {
                    menuState?.newRecipe()
                },
                onSettings: {
                    menuState?.settings()
                }
            )
            .navigationTitle("Recipes")
        } detail: {
            HStack(spacing: 0) {
                recipeListColumn
                    .frame(width: 350)
#if DEBUG
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            devToolsMenu
                        }
                    }
#endif
                
                Divider()
                
                RecipeDetailColumn(recipe: viewModel?.selectedRecipe)
            }
        }
        .navigationSplitViewStyle(.balanced)
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
                    print("[DEBUG] onRecipeTap called for: \(recipe.title)")
                    viewModel.selectedRecipe = recipe
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
        
        viewModel?.autoSelectFirstRecipeIfNeeded(
            isRegularSizeClass: horizontalSizeClass == .regular
        )
    }
    
#if DEBUG
    private var devToolsMenu: some View {
        Menu {
            Button("Load Suggestions") {
                Task { await viewModel?.loadSuggestionsDev() }
            }
            Button("Invalidate AI Cache") {
                AICache.invalidateAll()
            }
        } label: {
            Label("Dev Tools", systemImage: "hammer.fill")
        }
    }
#endif
}

// MARK: - Detail Column

private struct RecipeDetailColumn: View {
    let recipe: Recipe?

    var body: some View {
        let _ = print("[DEBUG] RecipeDetailColumn body called, recipe: \(recipe?.title ?? "nil")")
        if let recipe = recipe {
            RecipeDetailView(recipe: recipe)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ContentUnavailableView("Select a Recipe", systemImage: "fork.knife")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
