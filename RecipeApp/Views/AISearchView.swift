import SwiftUI

struct AISearchView: View {
    let recipes: [Recipe]
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchQuery = ""
    @State private var searchResults: [Recipe] = []
    @State private var isSearching = false
    @State private var errorMessage: String?
    
    private let aiSearchService = AISearchService()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack {
                    TextField("Try: 'quick Italian favorites I haven't made'", text: $searchQuery)
                        .textFieldStyle(.roundedBorder)
                    
                    Button(action: {
                        Task {
                            await performSearch(query: searchQuery)
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(searchQuery.isEmpty || isSearching)
                }
                .padding()
                
                if isSearching {
                    ProgressView("Searching...")
                        .padding()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .padding()
                } else if searchResults.isEmpty && !searchQuery.isEmpty {
                    ContentUnavailableView(
                        "No Results",
                        systemImage: "magnifyingglass",
                        description: Text("Try a different search")
                    )
                } else if !searchResults.isEmpty {
                    List(searchResults) { recipe in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(recipe.title)
                                .font(.headline)
                            
                            HStack {
                                if let cuisine = recipe.cuisine {
                                    Text(cuisine)
                                        .font(.caption)
                                }
                                if let total = recipe.totalTime {
                                    Text("\(total) min")
                                        .font(.caption)
                                }
                                if recipe.isFavorite {
                                    Image(systemName: "heart.fill")
                                        .font(.caption)
                                        .foregroundStyle(.red)
                                }
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("AI Search")
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
    
    private func performSearch(query: String) async {
        isSearching = true
        errorMessage = nil
        
        do {
            searchResults = try await aiSearchService.search(query: query, recipes: recipes)
        } catch {
            errorMessage = "Search failed: \(error.localizedDescription)"
            searchResults = []
        }
        
        isSearching = false
    }
}
