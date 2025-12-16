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
    @State private var showAISearch = false
    @State private var showSettings = false
    @State private var error: Error?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if showImportBanner {
                    RecipeImportBanner {
                        importedRecipe = recipes.first
                    }
                }
                
                if let viewModel = viewModel {
                    RecipeListHeader(
                        title: "Recipes",
                        hasFilter: viewModel.selectedSection != .all,
                        filterIcon: viewModel.selectedSection != .all ? viewModel.selectedSection.icon : nil,
                        filterTitle: viewModel.selectedSection != .all ? viewModel.selectedSection.title : nil,
                        onMenuTap: { showingMenu = true },
                        onClearFilter: { viewModel.selectedSection = .all }
                    )
                    
                    RecipeListContent(
                        recipes: viewModel.displayedRecipes,
                        isSearching: viewModel.isSearching,
                        searchText: searchText,
                        selectedSectionTitle: viewModel.selectedSection != .all ? viewModel.selectedSection.title : nil,
                        selectedSectionIcon: viewModel.selectedSection != .all ? viewModel.selectedSection.icon : nil,
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
                            // TODO: Navigate to new recipe
                        }
                    )
                } else {
                    DSLoadingSpinner(message: "Loading recipes...")
                }
                
                Spacer()
                
                RecipeListSearchBar(
                    searchText: $searchText,
                    searchScope: $searchScope,
                    onSubmit: {
                        viewModel?.performSearch(query: searchText, scope: searchScope)
                    },
                    onAISearch: {
                        showAISearch = true
                    }
                )
            }
            .background(Theme.Colors.background)
            .onAppear {
                handleViewAppear()
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
            .sheet(isPresented: $showingMenu) {
                recipeMenuSheet()
            }
            .sheet(item: $importedRecipe) { recipe in
                // TODO: RecipeDetailView
                Text("Recipe Detail View Coming Soon")
            }
            .sheet(isPresented: $showAISearch) {
                if let viewModel = viewModel {
                    AISearchSheet(viewModel: viewModel)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
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
                    // TODO: Navigate to recipe form
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
        }
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
