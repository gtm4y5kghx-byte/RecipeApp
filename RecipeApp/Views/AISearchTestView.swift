import SwiftUI

struct AISearchTestView: View {
    let recipes: [Recipe]
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchQuery = ""
    @State private var searchResults: [Recipe] = []
    @State private var isSearching = false
    @State private var errorMessage: String?
    
    private let aiSearchService = AISearchService()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Search input
                TextField("Try: 'quick Italian recipes'", text: $searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                // Search button
                Button(action: performSearch) {
                    if isSearching {
                        ProgressView()
                    } else {
                        Text("Search with AI")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(searchQuery.isEmpty || isSearching)
                
                // Error message
                if let error = errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .padding()
                }
                
                // Results
                List(searchResults) { recipe in
                    VStack(alignment: .leading) {
                        Text(recipe.title)
                            .font(.headline)
                        
                        HStack {
                            if let cuisine = recipe.cuisine {
                                Text(cuisine)
                                    .font(.caption)
                            }
                            if let prep = recipe.prepTime, let cook = recipe.cookTime {
                                Text("\(prep + cook) min total")
                                    .font(.caption)
                            }
                            if recipe.isFavorite {
                                Image(systemName: "heart.fill")
                                    .font(.caption)
                            }
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("AI Search Test")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func performSearch() {
        Task {
            isSearching = true
            print("🔍 Starting search for: \(searchQuery)")
            errorMessage = nil
            
            do {
                // Step 1: AI parses the query
                let criteria = try await aiSearchService.parseSearchIntent(from: searchQuery)
                print("🔍 AI returned criteria: \(criteria)")
                
                // Step 2: Filter recipes using criteria
                searchResults = RecipeFilterService.filterRecipes(recipes, using: criteria)
                
            } catch {
                errorMessage = "Search failed: \(error.localizedDescription)"
                print("🔍 AI Search Error: \(error)")
                searchResults = []
            }
            
            isSearching = false
        }
    }
}
