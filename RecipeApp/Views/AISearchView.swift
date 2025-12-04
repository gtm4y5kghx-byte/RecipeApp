import SwiftUI
import NaturalLanguage

struct AISearchView: View {
    let recipes: [Recipe]
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchQuery = ""
    @State private var searchResults: [Recipe] = []
    @State private var isSearching = false
    @State private var hasSearched = false
    @State private var errorMessage: String?
    
    private let aiSearchService = AISearchService()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack {
                    TextField("Try: 'quick favorites I haven't made'", text: $searchQuery)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: searchQuery) {_, _ in
                            hasSearched = false
                        }
                    
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
                } else {
                    if let error = errorMessage {
                        Text(error)
                            .foregroundStyle(.orange)
                            .font(.caption)
                            .padding()
                    }
                    
                    if searchResults.isEmpty && hasSearched {
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
            searchResults = fallbackSearch(query: query)
            errorMessage = "AI search unavailable. Showing basic results."
        }
        
        hasSearched = true
        isSearching = false
    }
    
    private func filterStopWords(from query: String) -> [String] {
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = query
        
        var words: [String] = []
        tagger.enumerateTags(in: query.startIndex..<query.endIndex,
                             unit: .word,
                             scheme: .lexicalClass) { tag, tokenRange in
            let word = String(query[tokenRange])
            
            // Keep nouns, verbs, adjectives (skip articles, prepositions, etc.)
            if let tag = tag,
               [.noun, .verb, .adjective].contains(tag) || word.count > 2 {
                words.append(word.lowercased())
            }
            return true
        }
        
        return words
    }
    
    private func fallbackSearch(query: String) -> [Recipe] {
        print("🔧 [Fallback] Starting fallback search for: \"\(query)\"")
        
        let words = filterStopWords(from: query)
        print("🔧 [Fallback] Filtered words: \(words)")
        
        guard !words.isEmpty else {
            print("🔧 [Fallback] No words after filtering, returning empty")
            return []
        }
        
        let results = recipes.filter { recipe in
            for word in words {
                if FuzzySearchService.fuzzyMatch(query: word, in: recipe.title) {
                    return true
                }
                
                if let cuisine = recipe.cuisine,
                   FuzzySearchService.fuzzyMatch(query: word, in: cuisine) {
                    return true
                }
                
                for ingredient in recipe.ingredients {
                    if FuzzySearchService.fuzzyMatch(query: word, in: ingredient.item) {
                        return true
                    }
                }
                
                for step in recipe.instructions {
                    if FuzzySearchService.fuzzyMatch(query: word, in: step.instruction) {
                        return true
                    }
                }
                
                if let notes = recipe.notes,
                   FuzzySearchService.fuzzyMatch(query: word, in: notes) {
                    return true
                }
            }
            return false
        }
        
        print("🔧 [Fallback] Found \(results.count) results")
        return results
    }
}
