import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Query private var recipes: [Recipe]
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var showingAddRecipe = false
    @State private var showingVoiceRecording = false
    @State private var error: Error?
    
    @State private var showingAISearch = false
    @State private var searchQuery = ""
    @State private var aiSearchResults: [Recipe] = []
    @State private var isSearching = false

    var filteredRecipes: [Recipe] {
        guard !searchText.isEmpty else { return recipes }

        return recipes.filter { recipe in
            recipe.title.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if filteredRecipes.isEmpty {
                    ContentUnavailableView(
                        "No Recipes",
                        systemImage: "book.closed",
                        description: Text("Add your first recipe to get started")
                    )
                } else {
                    ForEach(filteredRecipes) { recipe in
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
            }
            .searchable(text: $searchText, prompt: "Search Recipes")
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingAddRecipe = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingVoiceRecording = true
                    }) {
                        Image(systemName: "mic.fill")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingAISearch = true
                    }) {
                        Image(systemName: "sparkles")
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
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
            .sheet(isPresented: $showingVoiceRecording) {
                VoiceRecordingView()
            }
            .sheet(isPresented: $showingAISearch) {
                AISearchTestView(recipes: recipes)
            }
            .onAppear {
                checkForPendingImport()
            }
            .onReceive(NotificationCenter.default.publisher(
                for: UIApplication.willEnterForegroundNotification)) { _ in
                    checkForPendingImport()
                }
                .errorAlert($error)
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
            let recipe = filteredRecipes[index]
            modelContext.delete(recipe)
        }
        
        do {
            try modelContext.save()
        } catch let saveError {
            error = saveError
        }
    }
}

#Preview {
    RecipeListView()
}
