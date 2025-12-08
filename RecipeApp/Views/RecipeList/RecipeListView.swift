import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Query private var recipes: [Recipe]
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var showingAddRecipe = false
    
    @State private var showingAISearch = false
    @State private var searchScope = SearchScope.all
    
    @State private var subscriptionService = UserSubscriptionService()
    @State private var showingPaywall = false
    
    @State private var showingFilterMenu = false
    @State private var viewModel: RecipeListViewModel
    @State private var searchTask: Task<Void, Never>?
    
    init() {
        _viewModel = State(initialValue: RecipeListViewModel(
            recipes: [],
            modelContext: ModelContext(try! ModelContainer(for: Recipe.self))
        ))
    }
    
    private var recipeList: some View {
        List {
            forYouSection
            recipesSection
        }
    }
    
    @ViewBuilder
    private var forYouSection: some View {
        ForYouSection(
            isPremium: subscriptionService.isPremium,
            suggestions: viewModel.suggestions,
            recipes: recipes,
            onShowPaywall: { showingPaywall = true }
        )
    }
    
    private var recipesSection: some View {
        RecipesSection(
            displayedRecipes: viewModel.displayedRecipes,
            sectionTitle: viewModel.selectedSection.title,
            onDelete: { offsets in
                do {
                    try viewModel.deleteRecipes(at: offsets)
                } catch {
                    viewModel.error = error
                }
            }
        )
    }
    
    var body: some View {
        NavigationStack {
            recipeList
                .searchable(text: $searchText, prompt: "Search Recipes")
                .searchScopes($searchScope) {
                    ForEach(SearchScope.allCases, id: \.self) { scope in
                        Text(scope.rawValue)
                    }
                }
                .onChange(of: searchText) { oldValue, newValue in
                    performFuzzySearch(query: newValue)
                }
                .onChange(of: searchScope) { oldValue, newValue in
                    performFuzzySearch(query: searchText)
                }
                .onChange(of: recipes) { oldValue, newValue in
                    viewModel.updateRecipes(newValue)
                }
                .navigationDestination(for: Recipe.self) { recipe in
                    RecipeDetailView(recipe: recipe)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            showingFilterMenu = true
                        }) {
                            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                        }
                        .accessibilityIdentifier("filter-button")
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            showingAddRecipe = true
                        }) {
                            Image(systemName: "plus")
                        }
                        .accessibilityIdentifier("add-recipe-button")
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            subscriptionService.requiresPremium(
                                action: { showingAISearch = true },
                                showPaywall: { showingPaywall = true }
                            )
                        }) {
                            Image(systemName: "sparkles")
                        }
                        .accessibilityIdentifier("ai-search-button")
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button(action: {
                                SampleData.loadSampleRecipes(into: modelContext)
                            }) {
                                Label("Load Sample Recipes", systemImage: "tray.full")
                            }
                            
                            Button(role: .destructive, action: {
                                SampleData.clearAllData(from: modelContext)
                            }) {
                                Label("Clear All Data", systemImage: "trash")
                            }
                        } label: {
                            Label("Dev Tools", systemImage: "wrench.and.screwdriver")
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            Task {
                                await viewModel.loadSuggestionsDev()
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
                .navigationTitle(Text("Recipes"))
                .sheet(isPresented: $showingAddRecipe) {
                    RecipeFormView()
                }
                .sheet(isPresented: $showingAISearch) {
                    AISearchView(recipes: recipes)
                }
                .sheet(isPresented: $showingPaywall) {
                    PaywallView()
                }
                .sheet(isPresented: $showingFilterMenu) {
                    RecipeFilterMenuView(
                        selectedSection: $viewModel.selectedSection,
                        tags: viewModel.sortedTags,
                        onDismiss: { showingFilterMenu = false },
                        onNewRecipe: { showingAddRecipe = true },
                        recipeCount: viewModel.recipeCount
                    )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                }
                .onAppear {
                    viewModel = RecipeListViewModel(recipes: recipes, modelContext: modelContext)
                    viewModel.handlePendingImport()
                    if viewModel.justImportedRecipe {
                        HapticFeedback.success.trigger()
                    }

                    Task {
                        await viewModel.loadSuggestions()
                    }
                }
                .onReceive(NotificationCenter.default.publisher(
                    for: UIApplication.willEnterForegroundNotification)) { _ in
                        viewModel.handlePendingImport()
                        if viewModel.justImportedRecipe {
                            HapticFeedback.success.trigger()
                        }
                    }
                .errorAlert($viewModel.error)
        }
    }
    
    private func performFuzzySearch(query: String) {
        searchTask?.cancel()
        
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            
            guard !Task.isCancelled else { return }
            
            viewModel.performFuzzySearch(query: query, scope: searchScope)
        }
    }
}
