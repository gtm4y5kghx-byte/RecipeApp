import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Query private var recipes: [Recipe]
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var showingAddRecipe = false
    @State private var showingVoiceRecording = false
    @State private var error: Error?
    
    @State private var testingFoundationModels = false
    @State private var testResult: VoiceRecipe?
    @State private var testError: Error?
    
    var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return recipes
        } else {
            return recipes.filter { recipe in
                recipe.title.localizedCaseInsensitiveContains(searchText)
            }
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
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        testFoundationModels()
                    }) {
                        Label("Test AI", systemImage: "wand.and.stars")
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
            .onAppear {
                checkForPendingImport()
            }
            .onReceive(NotificationCenter.default.publisher(
                for: UIApplication.willEnterForegroundNotification)) { _ in
                    checkForPendingImport()
                }
                .errorAlert($error)
                .overlay {
                    if testingFoundationModels {
                        ZStack {
                            Color.black.opacity(0.3)
                                .ignoresSafeArea()
                            
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                Text("Testing Foundation Models...")
                                    .font(.headline)
                            }
                            .padding(32)
                            .background(.regularMaterial)
                            .cornerRadius(16)
                        }
                    }
                }
        }
    }
    
    private func testFoundationModels() {
        let sampleTranscript = """
          I want to make spaghetti carbonara. You'll need 400 grams of spaghetti,
          200 grams of guanciale or pancetta, 4 egg yolks, 100 grams of pecorino romano,
          and black pepper. First, cook the pasta in salted boiling water.
          While that's cooking, cut the guanciale into small pieces and fry until crispy.
          Beat the egg yolks with grated cheese. When pasta is done, drain it and mix
          with the guanciale. Remove from heat and stir in the egg mixture quickly.
          Season with black pepper and serve immediately. Takes about 20 minutes total,
          serves 4 people. It's an Italian classic.
          """
        
        testingFoundationModels = true
        testError = nil
        testResult = nil
        
        Task {
            do {
                let service = FoundationModelsService()
                let result = try await service.structureRecipe(from: sampleTranscript)
                
                await MainActor.run {
                    testResult = result
                    testingFoundationModels = false
                    
                    // Print to console for verification
                    print("✅ Foundation Models Test Success!")
                    print("Title: \(result.title)")
                    print("Prep Time: \(result.prepTime ?? 0) mins")
                    print("Cook Time: \(result.cookTime ?? 0) mins")
                    print("Servings: \(result.servings ?? 0)")
                    print("Cuisine: \(result.cuisine ?? "nil")")
                    print("Ingredients: \(result.ingredients.count)")
                    print("Instructions: \(result.instructions.count)")
                }
            } catch {
                await MainActor.run {
                    testError = error
                    testingFoundationModels = false
                    print("❌ Foundation Models Test Failed: \(error)")
                }
            }
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
