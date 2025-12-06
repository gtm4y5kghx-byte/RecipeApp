import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Query private var recipes: [Recipe]
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var showingAddRecipe = false
    @State private var error: Error?
    
    @State private var showingAISearch = false
    @State private var searchQuery = ""
    @State private var filteredResults: [Recipe] = []
    @State private var searchTask: Task<Void, Never>?
    @State private var isSearching = false
    @State private var searchScope: SearchScope = .all
    @State private var suggestions: [RecipeSuggestion] = []
    @State private var suggestionEngine = AISuggestionEngine()
    
    @State private var subscriptionService = UserSubscriptionService()
    @State private var showingPaywall = false

    @State private var showingFilterMenu = false
    @State private var selectedSection: MenuSection = .all

    enum SearchScope: String, CaseIterable {
        case all = "All"
        case title = "Title"
        case ingredients = "Ingredients"
        case instructions = "Instructions"
        case notes = "Notes"
    }

    enum MenuSection: Hashable, Identifiable {
        case all
        case recentlyAdded
        case recentlyCooked
        case favorites
        case uncategorized
        case tag(String)

        var id: String {
            switch self {
            case .all: return "all"
            case .recentlyAdded: return "recently-added"
            case .recentlyCooked: return "recently-cooked"
            case .favorites: return "favorites"
            case .uncategorized: return "uncategorized"
            case .tag(let name): return "tag-\(name)"
            }
        }

        var title: String {
            switch self {
            case .all: return "All"
            case .recentlyAdded: return "Recently Added"
            case .recentlyCooked: return "Recently Cooked"
            case .favorites: return "Favorites"
            case .uncategorized: return "Uncategorized"
            case .tag(let name): return name
            }
        }

        var icon: String {
            switch self {
            case .all: return "book"
            case .recentlyAdded: return "clock.arrow.circlepath"
            case .recentlyCooked: return "clock"
            case .favorites: return "heart.fill"
            case .uncategorized: return "tray"
            case .tag: return "tag"
            }
        }
    }

    var filteredRecipes: [Recipe] {
        searchText.isEmpty ? recipes : filteredResults
    }

    var displayedRecipes: [Recipe] {
        let filtered = searchText.isEmpty ? recipes : filteredResults

        switch selectedSection {
        case .all:
            return filtered
        case .recentlyAdded:
            return filtered.sorted { ($0.dateAdded ?? .distantPast) > ($1.dateAdded ?? .distantPast) }
        case .recentlyCooked:
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            return filtered
                .filter { recipe in
                    guard let lastMade = recipe.lastMade else { return false }
                    return lastMade >= thirtyDaysAgo
                }
                .sorted { ($0.lastMade ?? .distantPast) > ($1.lastMade ?? .distantPast) }
        case .favorites:
            return filtered.filter { $0.isFavorite }
        case .uncategorized:
            return filtered.filter { $0.userTags.isEmpty }
        case .tag(let tagName):
            return filtered.filter { $0.userTags.contains(tagName) }
        }
    }

    var sortedTags: [(String, Int)] {
        let allTags = recipes.flatMap { $0.userTags }
        let tagCounts = Dictionary(grouping: allTags, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        return tagCounts
    }

    func recipeCount(for section: MenuSection) -> Int {
        switch section {
        case .all:
            return recipes.count
        case .recentlyAdded:
            return recipes.count
        case .recentlyCooked:
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            return recipes.filter { recipe in
                guard let lastMade = recipe.lastMade else { return false }
                return lastMade >= thirtyDaysAgo
            }.count
        case .favorites:
            return recipes.filter { $0.isFavorite }.count
        case .uncategorized:
            return recipes.filter { $0.userTags.isEmpty }.count
        case .tag(let tagName):
            return recipes.filter { $0.userTags.contains(tagName) }.count
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // For You section
                if subscriptionService.isPremium {
                    // Premium: Show AI suggestions
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
                    // Free tier: Show upgrade prompt
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
                
                Section {
                    if displayedRecipes.isEmpty {
                        ContentUnavailableView(
                            "No Recipes",
                            systemImage: "book.closed",
                            description: Text("Add your first recipe to get started")
                        )
                    } else {
                        ForEach(displayedRecipes) { recipe in
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
                    Text(selectedSection.title)
                }
            }
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
                    selectedSection: $selectedSection,
                    tags: sortedTags,
                    onDismiss: { showingFilterMenu = false },
                    onNewRecipe: { showingAddRecipe = true },
                    recipeCount: recipeCount
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .onAppear {
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
            
            filteredResults = fuzzyFilter(query: query)
        }
    }
    
    private func fuzzyFilter(query: String) -> [Recipe] {
        guard !query.isEmpty else { return recipes }
        
        return recipes.filter { recipe in
            switch searchScope {
            case .all:
                return matchesAnyField(recipe: recipe, query: query)
            case .title:
                return FuzzySearchService.fuzzyMatch(query: query, in: recipe.title)
            case .ingredients:
                return matchesIngredients(recipe: recipe, query: query)
            case .instructions:
                return matchesInstructions(recipe: recipe, query: query)
            case .notes:
                return matchesNotes(recipe: recipe, query: query)
            }
        }
    }
    
    private func matchesAnyField(recipe: Recipe, query: String) -> Bool {
        if FuzzySearchService.fuzzyMatch(query: query, in: recipe.title) {
            return true
        }
        
        if matchesIngredients(recipe: recipe, query: query) {
            return true
        }
        
        if matchesInstructions(recipe: recipe, query: query) {
            return true
        }
        
        if matchesNotes(recipe: recipe, query: query) {
            return true
        }
        
        return false
    }
    
    private func matchesIngredients(recipe: Recipe, query: String) -> Bool {
        for ingredient in recipe.ingredients {
            if FuzzySearchService.fuzzyMatch(query: query, in: ingredient.item) {
                return true
            }
        }
        return false
    }
    
    private func matchesInstructions(recipe: Recipe, query: String) -> Bool {
        for step in recipe.instructions {
            if FuzzySearchService.fuzzyMatch(query: query, in: step.instruction) {
                return true
            }
        }
        return false
    }
    
    private func matchesNotes(recipe: Recipe, query: String) -> Bool {
        if let notes = recipe.notes {
            return FuzzySearchService.fuzzyMatch(query: query, in: notes)
        }
        return false
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
            let recipe = displayedRecipes[index]
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
