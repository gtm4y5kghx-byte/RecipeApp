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
            errorMessage = nil
            
            do {
                print("🔍 Starting search for: \(searchQuery)")
                searchResults = try await aiSearchService.search(query: searchQuery, recipes: recipes)
                print("🔍 Found \(searchResults.count) results")
            } catch {
                errorMessage = "Search failed: \(error.localizedDescription)"
                searchResults = []
            }
            
            isSearching = false
        }
    }
}
