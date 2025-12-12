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
    
    @State private var error: Error?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if showImportBanner { importBanner }
                
                headerView
                
                if viewModel != nil {
                    RecipeGrid(
                        recipes: viewModel!.displayedRecipes,
                        onRecipeTap: { recipe in
                            selectedRecipe = recipe
                        },
                        onFavoriteTap: { recipe in
                            viewModel!.toggleFavorite(recipe)
                        }
                    )
                } else {
                    DSLoadingSpinner(message: "Loading recipes...")
                }
                
                Spacer()
                
                if !searchText.isEmpty {
                    Picker("Search In", selection: $searchScope) {
                        ForEach(SearchScope.allCases, id: \.self) { scope in
                            Text(scope.rawValue).tag(scope)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.bottom, Theme.Spacing.xs)
                }
                
                SearchBar(
                    text: $searchText,
                    onSubmit: {
                        // Real-time search via onChange
                    },
                    onAISearch: {
                        // TODO: AI Search
                    }
                )
            }
            .background(Theme.Colors.background)
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
            .onChange(of: searchText) { oldValue, newValue in
                viewModel?.performSearch(query: newValue, scope: searchScope)
            }
            .onChange(of: searchScope) { oldValue, newValue in
                viewModel?.performSearch(query: searchText, scope: newValue)
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
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            HStack {
                DSLabel("Recipes", style: .largeTitle)
                Spacer()
                MenuButton {
                    showingMenu = true
                }
            }
            
            if let viewModel = viewModel, viewModel.selectedSection != .all {
                HStack(spacing: Theme.Spacing.xs) {
                    DSIcon(viewModel.selectedSection.icon, size: .small, color: .secondary)
                    DSLabel(viewModel.selectedSection.title, style: .caption1, color: .secondary)
                    
                    
                    Button {
                        viewModel.selectedSection = .all
                    } label: {
                        DSIcon("xmark.circle.fill", size: .small, color: .tertiary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, Theme.Spacing.sm)
                .padding(.vertical, Theme.Spacing.xs)
                .background(Theme.Colors.backgroundDark)
                .cornerRadius(Theme.CornerRadius.sm)
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
