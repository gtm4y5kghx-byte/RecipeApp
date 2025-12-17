import SwiftUI

struct ForYouSection: View {
    let suggestions: [SuggestionDisplayData]
    let emptyStateMessage: String?
    let onRecipeTap: (Recipe) -> Void
    let onFavoriteTap: (Recipe) -> Void
    let onLearnMore: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                DSLabel("For You", style: .title1)
            }
            .padding(.horizontal, Theme.Spacing.md)
            
            if suggestions.isEmpty, let message = emptyStateMessage {
                emptyState(message: message)
            } else {
                suggestionsScroll
            }
        }
        .padding(.vertical, Theme.Spacing.md)
    }
    
    @ViewBuilder
    private var suggestionsScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: Theme.Spacing.md) {
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
                        
                        DSLabel(suggestion.reason, style: .subheadline, color: .secondary)
                            .lineLimit(2)
                            .padding(.horizontal, Theme.Spacing.sm)
                    }
                    .frame(width: 320)
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


struct SuggestionCard: View {
    let title: String
    let reason: String
    let imageURL: String?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Rectangle()
                    .fill(Theme.Colors.backgroundDark)
                    .frame(width: 280, height: 160)
                    .cornerRadius(Theme.CornerRadius.md)
                    .overlay(
                        DSIcon("fork.knife", size: .large, color: .tertiary)
                    )
                
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    DSLabel(title, style: .headline, color: .primary)
                        .lineLimit(1)
                    
                    DSLabel(reason, style: .footnote, color: .secondary)
                        .lineLimit(2)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview("With Suggestions") {
    ForYouSection(
        suggestions: [
            SuggestionDisplayData(
                id: UUID(),
                recipe: Recipe(title: "Spaghetti Carbonara", sourceType: .manual),
                reason: "You haven't cooked this in a while"
            ),
            SuggestionDisplayData(
                id: UUID(),
                recipe: Recipe(title: "Thai Green Curry", sourceType: .manual),
                reason: "Quick weeknight dinner under 30 minutes"
            ),
            SuggestionDisplayData(
                id: UUID(),
                recipe: Recipe(title: "Chicken Tikka Masala", sourceType: .manual),
                reason: "Perfect for a cozy weekend"
            )
        ],
        emptyStateMessage: nil,
        onRecipeTap: { _ in },
        onFavoriteTap: { _ in },
        onLearnMore: {}
    )
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

