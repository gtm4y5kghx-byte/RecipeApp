import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Query private var recipes: [Recipe]
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var showingAddRecipe = false
    @State private var showingVoiceRecording = false
    @State private var error: Error?
    
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
                
            }
            .navigationTitle(Text("Recipes"))
            .sheet(isPresented: $showingAddRecipe) {
                RecipeFormView()
            }
            .sheet(isPresented: $showingVoiceRecording) {
                VoiceRecordingView()
            }
            .errorAlert($error)
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
