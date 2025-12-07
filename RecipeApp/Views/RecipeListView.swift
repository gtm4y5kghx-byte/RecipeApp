import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Query private var recipes: [Recipe]
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var showingAddRecipe = false
    @State private var error: Error?

    @State private var showingAISearch = false
    @State private var searchScope = SearchScope.all
    @State private var suggestions: [RecipeSuggestion] = []
    @State private var suggestionEngine = AISuggestionEngine()

    @State private var subscriptionService = UserSubscriptionService()
    @State private var showingPaywall = false

    @State private var showingFilterMenu = false
    @State private var viewModel: RecipeListViewModel
    @State private var searchTask: Task<Void, Never>?

    init() {
        // Initialize ViewModel with empty array - will be updated in onAppear
        _viewModel = State(initialValue: RecipeListViewModel(recipes: []))
    }

    private var recipeList: some View {
        List {
            forYouSection
            recipesSection
        }
    }

    @ViewBuilder
    private var forYouSection: some View {
        if subscriptionService.isPremium {
            if !suggestions.isEmpty {
                Section {
                    ForEach(suggestions) { suggestion in
                        if let recipe = recipes.first(where: { $0.id == suggestion.recipeID }) {
                            NavigationLink(value: recipe) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(recipe.title)
                                        .font(.headline)

                                    Text(suggestion.aiGeneratedReason)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("For You")
                        Spacer()
                        Button("Refresh") {
                            loadSuggestions(forceRefresh: true)
                        }
                        .font(.caption)
                        .textCase(.none)
                    }
                }
            }
        } else {
            Section {
                Button(action: {
                    showingPaywall = true
                }) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundStyle(.blue)
                            Text("Get Personalized Suggestions")
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }

                        Text("Unlock AI-powered recipe recommendations tailored to your cooking history")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            } header: {
                Text("For You")
            }
        }
    }

    private var recipesSection: some View {
        Section {
            if viewModel.displayedRecipes.isEmpty {
                ContentUnavailableView(
                    "No Recipes",
                    systemImage: "book.closed",
                    description: Text("Add your first recipe to get started")
                )
            } else {
                ForEach(viewModel.displayedRecipes) { recipe in
                    NavigationLink(value: recipe) {
                        VStack(alignment: .leading) {
                            Text(recipe.title)
                                .font(.headline)

                            Text("\(recipe.sourceType.rawValue)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteRecipes)
            }
        } header: {
            Text(viewModel.selectedSection.title)
        }
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
                // Update ViewModel when recipes change
                viewModel = RecipeListViewModel(recipes: newValue)
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
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingAddRecipe = true
                    }) {
                        Image(systemName: "plus")
                    }
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
                viewModel = RecipeListViewModel(recipes: recipes)
                checkForPendingImport()
                loadSuggestions()
            }
            .onReceive(NotificationCenter.default.publisher(
                for: UIApplication.willEnterForegroundNotification)) { _ in
                    checkForPendingImport()
                }
                .errorAlert($error)
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

    private func checkForPendingImport() {
        guard SharedDataManager.shared.hasPendingImport() else {
            return
        }

        do {
            if let importData = try SharedDataManager.shared.loadPendingImport() {
                createRecipeFromImport(importData)
                try SharedDataManager.shared.deletePendingImport()
            }
        } catch {
            self.error = error
        }
    }

    private func createRecipeFromImport(_ importData: RecipeImportData) {
        let recipe = Recipe(title: importData.title, sourceType: .web_imported)
        recipe.sourceURL = importData.sourceURL
        recipe.servings = importData.servings
        recipe.prepTime = importData.prepTime
        recipe.cookTime = importData.cookTime
        recipe.cuisine = importData.cuisine
        recipe.notes = importData.description

        for (index, ingredientText) in importData.ingredients.enumerated() {
            let ingredient = Ingredient(quantity: "", unit: nil, item: ingredientText, preparation: nil, section: nil)
            ingredient.order = index
            recipe.ingredients.append(ingredient)
        }

        for (index, instructionText) in importData.instructions.enumerated() {
            let step = Step(instruction: instructionText)
            step.order = index
            recipe.instructions.append(step)
        }

        if let nutritionData = importData.nutrition {
            let nutritionInfo = NutritionInfo(
                calories: nutritionData.calories,
                carbohydrates: nutritionData.carbohydrates,
                protein: nutritionData.protein,
                fat: nutritionData.fat,
                fiber: nutritionData.fiber,
                sodium: nutritionData.sodium,
                sugar: nutritionData.sugar
            )
            recipe.nutrition = nutritionInfo
        }

        modelContext.insert(recipe)

        do {
            try modelContext.save()
            HapticFeedback.success.trigger()
        } catch let saveError {
            error = saveError
        }
    }

    private func deleteRecipes(at offsets: IndexSet) {
        for index in offsets {
            let recipe = viewModel.displayedRecipes[index]
            modelContext.delete(recipe)
        }

        do {
            try modelContext.save()
        } catch let saveError {
            error = saveError
        }
    }

    private func loadSuggestions(forceRefresh: Bool = false) {
        Task {
            suggestions = await suggestionEngine.getSuggestions(recipes: recipes, forceRefresh: forceRefresh)
        }
    }
}
