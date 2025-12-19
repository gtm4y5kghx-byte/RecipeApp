import SwiftUI
import SwiftData

struct ForYouSection: View {
    let suggestions: [SuggestionDisplayData]
    let emptyStateMessage: String?
    let onRecipeTap: (Recipe) -> Void
    let onFavoriteTap: (Recipe) -> Void
    let onLearnMore: () -> Void
    
    var body: some View {
        DSSection("For You") {
            if suggestions.isEmpty, let message = emptyStateMessage {
                emptyState(message: message)
            } else {
                suggestionsScroll
            }
        }
    }
    
    @ViewBuilder
    private var suggestionsScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(suggestions) { suggestion in
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        DSRecipeCard(
                            title: suggestion.recipe.title,
                            cuisine: suggestion.recipe.cuisine,
                            prepTime: suggestion.recipe.prepTime,
                            cookTime: suggestion.recipe.cookTime,
                            servings: suggestion.recipe.servings,
                            isFavorite: suggestion.recipe.isFavorite,
                            tags: suggestion.recipe.userTags,
                            imageURL: suggestion.recipe.imageURL,
                            onTap: { onRecipeTap(suggestion.recipe) },
                            onFavoriteTap: { onFavoriteTap(suggestion.recipe) }
                        )
                        .frame(width: 320)
                        
                        DSLabel(suggestion.reason, style: .subheadline, color: .secondary)
                            .lineLimit(2)
                            .padding(.horizontal, Theme.Spacing.sm)
                    }
                }
            }
        }
        
    }
    
    @ViewBuilder
    private func emptyState(message: String) -> some View {
        DSEmptyState(
            icon: "sparkles",
            title: "No Suggestions Yet",
            message: message
        )
        .padding(.horizontal, Theme.Spacing.md)
    }
}

#Preview("With Suggestions") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, configurations: config)
    
    SampleData.loadSampleRecipes(into: container.mainContext)
    let recipes = try! container.mainContext.fetch(FetchDescriptor<Recipe>())
    
    
    return ForYouSection(
        suggestions: [
            SuggestionDisplayData(id: UUID(), recipe: recipes[0], reason: "You haven't cooked this in a while"),
            SuggestionDisplayData(id: UUID(), recipe: recipes[1], reason: "Quick weeknight dinner under 30 minutes"),
            SuggestionDisplayData(id: UUID(), recipe: recipes[2], reason: "Perfect for a cozy weekend")
        ],
        emptyStateMessage: nil,
        onRecipeTap: { _ in },
        onFavoriteTap: { _ in },
        onLearnMore: {}
    )
    .modelContainer(container)
}

#Preview("Empty State") {
    ForYouSection(
        suggestions: [],
        emptyStateMessage: "Keep cooking! We need more data to personalize suggestions for you.",
        onRecipeTap: { _ in },
        onFavoriteTap: { _ in },
        onLearnMore: {}
    )
}

