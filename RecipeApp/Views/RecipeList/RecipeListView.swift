import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Query(sort: \Recipe.createdAt, order: .reverse) private var recipes: [Recipe]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.isIPad) private var isIPad
    @Environment(\.scenePhase) private var scenePhase

    var menuState: AppMenuState?
    var selectedRecipe: Binding<Recipe?>?
    var selectedTab: Binding<MainView.Tab>?

    @State private var viewModel: RecipeListViewModel?
    @State private var showImportBanner = false
    @State private var importedRecipe: Recipe?
    @State private var searchText = ""
    @State private var searchScope: SearchScope = .all
    @State private var scrollPosition = ScrollPosition(edge: .top)
    @State private var localSelectedRecipe: Recipe?
    @State private var error: Error?
    #if DEBUG
    @State private var debugTierLabel = UserSubscriptionService.debugTierLabel
    #endif

    /// Returns the passed-in binding or falls back to local state (for previews)
    private var effectiveSelectedRecipe: Binding<Recipe?> {
        selectedRecipe ?? $localSelectedRecipe
    }

    init(
        menuState: AppMenuState? = nil,
        selectedRecipe: Binding<Recipe?>? = nil,
        selectedTab: Binding<MainView.Tab>? = nil,
        previewViewModel: RecipeListViewModel? = nil
    ) {
        self.menuState = menuState
        self.selectedRecipe = selectedRecipe
        self.selectedTab = selectedTab
        _viewModel = State(initialValue: previewViewModel)
    }
    
    var body: some View {
        Group {
            if isIPad {
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

            // Clear selection if the selected recipe was deleted
            if let selected = effectiveSelectedRecipe.wrappedValue,
               !newValue.contains(where: { $0.id == selected.id }) {
                effectiveSelectedRecipe.wrappedValue = nil
            }
        }
        .onChange(of: searchText) { oldValue, newValue in
            viewModel?.performSearch(query: newValue, scope: searchScope)
        }
        .onChange(of: searchScope) { oldValue, newValue in
            viewModel?.performSearch(query: searchText, scope: newValue)
        }
        .onChange(of: viewModel?.selectedSection) { _, _ in
            scrollPosition.scrollTo(edge: .top)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task {
                    await viewModel?.loadSuggestionsIfEligible()
                }
            }
        }
        .onAppear {
            handleViewAppear()
        }
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
                .navigationDestination(item: effectiveSelectedRecipe) { recipe in
                    RecipeDetailView(recipe: recipe)
                }
        }
    }
    
    // MARK: - iPad Layout (3-column: Sidebar | Recipe List | Detail)

    private var iPadLayout: some View {
        NavigationSplitView {
            RecipesMenuList(
                appSections: [.recipes, .mealPlan, .shoppingList],
                selectedAppSection: .recipes,
                onSelectAppSection: { tab in
                    selectedTab?.wrappedValue = tab
                },
                filterOptions: menuState?.filterOptions ?? [],
                tagOptions: menuState?.tagOptions ?? [],
                selectedOptionID: nil,
                onSelectOption: { optionId in
                    menuState?.selectOption(optionId)
                },
                onNewRecipe: {
                    menuState?.newRecipe()
                },
                onSettings: {
                    menuState?.settings()
                }
            )
            .navigationTitle("Menu")
        } content: {
            recipeContent
                .navigationTitle(viewModel?.filterTitle ?? "Recipes")
                .navigationBarTitleDisplayMode(.large)
                .safeAreaInset(edge: .bottom) {
                    ScopedSearchBar(
                        searchText: $searchText,
                        searchScope: $searchScope,
                        onSubmit: {
                            viewModel?.performSearch(query: searchText, scope: searchScope)
                        }
                    )
                }
                .overlay(alignment: .top) {
                    if showImportBanner {
                        RecipeImportBanner {
                            importedRecipe = recipes.first
                        }
                    }
                }
                .background(Theme.Colors.background)
        } detail: {
            if let recipe = effectiveSelectedRecipe.wrappedValue {
                RecipeDetailView(recipe: recipe)
            } else {
                ContentUnavailableView("Select a Recipe", systemImage: "fork.knife")
            }
        }
#if DEBUG
        .overlay(alignment: .bottomTrailing) {
            Menu {
                Button("Tier: \(UserSubscriptionService.debugTierLabel)") {
                    UserSubscriptionService.cycleDebugTier()
                }
                Button("Load Suggestions") {
                    Task { await viewModel?.loadSuggestionsDev() }
                }
                Button("Load Sample Data") {
                    SampleData.loadSampleRecipes(into: modelContext)
                }
                Button("Invalidate AI Cache") {
                    AICache.invalidateAll()
                }
            } label: {
                Image(systemName: "hammer.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color.orange)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding()
        }
#endif
    }
    
    @ViewBuilder
    private var recipeContent: some View {
        if let viewModel = viewModel {
            RecipeListContent(
                items: viewModel.displayedItems,
                isSearching: viewModel.isSearching,
                searchText: searchText,
                selectedSectionTitle: viewModel.filterTitle,
                selectedSectionIcon: viewModel.filterIcon,
                scrollPosition: $scrollPosition,
                selectedRecipe: selectedRecipe,
                onFavoriteTap: { recipe in
                    viewModel.toggleFavorite(recipe)
                },
                onDeleteTap: { recipe in
                    viewModel.deleteRecipe(recipe)
                },
                onSaveGeneratedRecipe: { generatedRecipe in
                    if let savedRecipe = viewModel.saveGeneratedRecipe(generatedRecipe) {
                        effectiveSelectedRecipe.wrappedValue = savedRecipe
                    }
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

#if DEBUG
    private var devToolsMenu: some View {
        Menu {
            Button("Tier: \(debugTierLabel)") {
                debugTierLabel = UserSubscriptionService.cycleDebugTier()
            }
            Button("Load Suggestions") {
                Task { await viewModel?.loadSuggestionsDev() }
            }
            Button("Load Sample Data") {
                SampleData.loadSampleRecipes(into: modelContext)
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

    let _ = SampleData.loadSampleRecipes(into: container.mainContext)
    let recipes = try! container.mainContext.fetch(FetchDescriptor<Recipe>())

    let mockViewModel = RecipeListViewModel(recipes: recipes, modelContext: container.mainContext)
    let _ = mockViewModel.suggestions = [
        .fromCollection(RecipeSuggestion(recipeID: recipes[0].id, aiGeneratedReason: "You haven't cooked this in a while")),
        .fromCollection(RecipeSuggestion(recipeID: recipes[1].id, aiGeneratedReason: "Quick weeknight dinner")),
        .fromCollection(RecipeSuggestion(recipeID: recipes[2].id, aiGeneratedReason: "Quick weekend dinner"))
    ]

    RecipeListView(previewViewModel: mockViewModel)
        .modelContainer(container)
}
