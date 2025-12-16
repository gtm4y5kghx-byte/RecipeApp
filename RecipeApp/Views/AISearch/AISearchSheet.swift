import SwiftUI

struct AISearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var query: String = ""
    
    let viewModel: RecipeListViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchInputSection
                
                if viewModel.isAISearching {
                    loadingState
                } else if let error = viewModel.aiSearchError {
                    errorState(error)
                } else if !viewModel.aiSearchResults.isEmpty {
                    resultsSection
                } else if !query.isEmpty
                            && viewModel.hasAISearched
                            && viewModel.aiSearchResults.isEmpty {
                    noResultsState
                } else {
                    examplesSection
                }
            }
            .background(Theme.Colors.background)
            .navigationTitle("AI Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { // TODO: may be worth making this a molecule? Similar UI in the RecipeMenuSheet
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        viewModel.clearAISearch()
                        dismiss()
                    } label: {
                        DSIcon("xmark", size: .medium, color: .accent)
                    }
                }
            }
        }
    }
    
    private var searchInputSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            DSLabel("Ask me anything about your recipes", style: .caption1, color: .secondary)
            
            HStack(spacing: Theme.Spacing.sm) {
                TextField("e.g., Quick dinners under 30 minutes", text: $query)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.search)
                    .onSubmit {
                        performSearch()
                    }
                
                DSButton(
                    title: "Search",
                    style: .primary,
                    size: .small
                ) {
                    performSearch()
                }
                .disabled(query.isEmpty || viewModel.isAISearching)
            }
        }
        .padding(Theme.Spacing.md)
    }
    
    private var loadingState: some View {
        VStack(spacing: Theme.Spacing.md) {
            Spacer()
            DSLoadingSpinner(message: "Searching your recipes...")
            Spacer()
        }
    }
    
    private func errorState(_ error: SearchError) -> some View {
        VStack(spacing: Theme.Spacing.md) {
            Spacer()
            DSEmptyState(
                icon: "exclamationmark.triangle",
                title: error.title,
                message: error.message,
                actionTitle: "Try Again",
                action: { performSearch() }
            )
            Spacer()
        }
    }
    
    private var noResultsState: some View {
        VStack(spacing: Theme.Spacing.md) {
            Spacer()
            DSEmptyState(
                icon: "magnifyingglass",
                title: "No Recipes Found",
                message: "Try adjusting your search or browse all recipes.",
                actionTitle: "Clear Search",
                action: {
                    query = ""
                    viewModel.clearAISearch()
                }
            )
            Spacer()
        }
    }
    
    private var resultsSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                HStack {
                    DSLabel(
                        "\(viewModel.aiSearchResults.count) recipe\(viewModel.aiSearchResults.count == 1 ? "" : "s") found",
                        style: .caption1,
                        color: .secondary
                    )
                    Spacer()
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.top, Theme.Spacing.md)
                
                RecipeGrid(
                    recipes: viewModel.aiSearchResults,
                    onRecipeTap: { recipe in
                        // TODO: Navigate to recipe detail
                    },
                    onFavoriteTap: { recipe in
                        viewModel.toggleFavorite(recipe)
                    }
                )
            }
        }
    }
    
    private var examplesSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                DSLabel("Try asking:", style: .headline)
                    .padding(.horizontal, Theme.Spacing.md)
                
                exampleQuery("What can I make for dinner tonight?")
                exampleQuery("Quick breakfast recipes")
                exampleQuery("Italian dishes under 45 minutes")
                exampleQuery("Recipes I haven't made in a while")
                exampleQuery("My favorite pasta dishes")
                
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    DSLabel("Tips:", style: .subheadline, color: .secondary)
                    DSLabel("• Be conversational and natural", style: .caption1, color: .tertiary)
                    DSLabel("• Include time constraints, cuisines, or preferences", style: .caption1, color: .tertiary)
                    DSLabel("• Reference favorites or recently cooked", style: .caption1, color: .tertiary)
                }
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.backgroundDark)
                .cornerRadius(Theme.CornerRadius.md)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.top, Theme.Spacing.md)
            }
            .padding(.vertical, Theme.Spacing.lg)
        }
    }
    
    private func exampleQuery(_ text: String) -> some View {
        Button {
            query = text
            performSearch()
        } label: {
            HStack {
                DSIcon("sparkles", size: .small, color: .accent)
                DSLabel(text, style: .body, color: .primary)
                Spacer()
                DSIcon("arrow.right", size: .small, color: .tertiary)
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.backgroundLight)
            .cornerRadius(Theme.CornerRadius.md)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, Theme.Spacing.md)
    }
    
    private func performSearch() {
        Task {
            await viewModel.performAISearch(query: query)
        }
    }
}
