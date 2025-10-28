import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Query private var recipes: [Recipe]
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var showingAddRecipe = false
    
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
                
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        createTestRecipe()
                    }) {
                        Label("Test", systemImage: "wrench.and.screwdriver")
                    }
                }
            }
            .navigationTitle(Text("Recipes"))
            .sheet(isPresented: $showingAddRecipe) {
                RecipeFormView()
            }
        }
    }
    
    private func deleteRecipes(at offsets: IndexSet) {
        for index in offsets {
            let recipe = filteredRecipes[index]
            modelContext.delete(recipe)
        }
        try? modelContext.save()
    }
    
    private func createTestRecipe() {
        let recipe = Recipe(title: "Grandma's Apple Pie", sourceType: .photo_card)
        recipe.servings = 8
        recipe.prepTime = 20
        recipe.cookTime = 45
        recipe.notes = "Use Granny Smith apples for best results. Mom's favorite!"
        
        // Add ingredients
        let flour = Ingredient(quantity: "2", unit: "cups", item: "all-purpose flour", preparation: nil, section: nil)
        flour.order = 0
        
        let sugar = Ingredient(quantity: "1", unit: "cup", item: "sugar", preparation: nil, section: nil)
        sugar.order = 1
        
        let apples = Ingredient(quantity: "6", unit: nil, item: "apples", preparation: "sliced", section: nil)
        apples.order = 2
        
        recipe.ingredients = [flour, sugar, apples]
        
        // Add instructions
        let step1 = Step(instruction: "Preheat oven to 350°F")
        step1.order = 0
        
        let step2 = Step(instruction: "Mix flour and sugar in a large bowl")
        step2.order = 1
        
        let step3 = Step(instruction: "Arrange sliced apples in pie dish and cover with flour mixture")
        step3.order = 2
        
        recipe.instructions = [step1, step2, step3]
        
        modelContext.insert(recipe)
        try? modelContext.save()
    }
}

#Preview {
    RecipeListView()
}
