import SwiftUI

struct ForYouSection: View {
    let suggestions: [SuggestionDisplayData]
    let emptyStateMessage: String?
    let onRecipeTap: (UUID) -> Void
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
                suggestionsScroll()
            }
        }
        .padding(.vertical, Theme.Spacing.md)
        .background(Theme.Colors.backgroundLight)
    }
    
    @ViewBuilder
    private func suggestionsScroll() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: Theme.Spacing.md) {
                ForEach(suggestions) { suggestion in
                    SuggestionCard(
                        title: suggestion.recipeTitle,
                        reason: suggestion.reason,
                        imageURL: suggestion.imageURL,
                        onTap: {
                            onRecipeTap(suggestion.recipeID)
                        }
                    )
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
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
                .frame(width: 280, alignment: .leading)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ForYouSection(
        suggestions: [
            SuggestionDisplayData(
                id: UUID(),
                recipeID: UUID(),
                recipeTitle: "Spaghetti Carbonara",
                reason: "You haven't cooked this in a while",
                imageURL: nil
            ),
            SuggestionDisplayData(
                id: UUID(),
                recipeID: UUID(),
                recipeTitle: "Thai Green Curry",
                reason: "Quick weeknight dinner under 30 minutes",
                imageURL: nil
            ),
            SuggestionDisplayData(
                id: UUID(),
                recipeID: UUID(),
                recipeTitle: "Chocolate Chip Cookies",
                reason: "One of your favorites",
                imageURL: nil
            )
        ],
        emptyStateMessage: nil,
        onRecipeTap: { _ in },
        onLearnMore: {}
    )
}

#Preview("Empty State") {
    ForYouSection(
        suggestions: [],
        emptyStateMessage: "Keep cooking! We need more data to personalize suggestions for you.",
        onRecipeTap: { _ in },
        onLearnMore: {}
    )
}
