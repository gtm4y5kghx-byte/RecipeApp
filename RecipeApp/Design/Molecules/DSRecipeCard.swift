import SwiftUI

/// Design System Recipe Card
/// Displays recipe information in a card format for lists/grids
struct DSRecipeCard: View {

    // MARK: - Configuration

    let title: String
    let cuisine: String?
    let prepTime: Int?
    let cookTime: Int?
    let servings: Int?
    let isFavorite: Bool
    let tags: [String]
    let onFavoriteTap: () -> Void
    let suggestionReason: String?
    let onDeleteTap: () -> Void
    let accessibilityID: String

    // MARK: - Computed Properties

    private var totalTime: Int? {
        guard let prep = prepTime, let cook = cookTime else {
            return prepTime ?? cookTime
        }
        return prep + cook
    }

    // MARK: - Initializer

    init(
        title: String,
        cuisine: String? = nil,
        prepTime: Int? = nil,
        cookTime: Int? = nil,
        servings: Int? = nil,
        isFavorite: Bool = false,
        tags: [String] = [],
        onFavoriteTap: @escaping () -> Void,
        suggestionReason: String? = nil,
        onDeleteTap: @escaping () -> Void,
        accessibilityID: String
    ) {
        self.title = title
        self.cuisine = cuisine
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.servings = servings
        self.isFavorite = isFavorite
        self.tags = tags
        self.onFavoriteTap = onFavoriteTap
        self.suggestionReason = suggestionReason
        self.onDeleteTap = onDeleteTap
        self.accessibilityID = accessibilityID
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                DSLabel(title, style: .headline, color: .primary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                DSIconButton(
                    isFavorite ? "heart.fill" : "heart",
                    size: .medium,
                    color: isFavorite ? .error : .secondary,
                    accessibilityID: "\(accessibilityID)-favorite-button"
                ) {
                    HapticFeedback.light.trigger()
                    onFavoriteTap()
                }
            }
            
            // MARK: - Suggested Recipe
            if let suggestionReason = suggestionReason {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    HStack(spacing: Theme.Spacing.xs) {
                        DSIcon("sparkles", size: .small, color: .accent)
                        DSLabel("Suggested", style: .caption1, color: .accent)
                    }
                    
                    DSLabel(suggestionReason, style: .caption2, color: .secondary)
                        .lineLimit(2)
                }
            }

            // MARK: - Metadata
            if totalTime != nil || servings != nil || cuisine != nil {
                HStack(spacing: Theme.Spacing.md) {
                    if let time = totalTime {
                        HStack(spacing: Theme.Spacing.xs) {
                            DSIcon("clock", size: .small, color: .secondary)
                            DSLabel("\(time) min", style: .caption1, color: .secondary)
                        }
                    }

                    if let servings = servings {
                        HStack(spacing: Theme.Spacing.xs) {
                            DSIcon("person.2", size: .small, color: .secondary)
                            DSLabel("\(servings)", style: .caption1, color: .secondary)
                        }
                    }

                    if let cuisine = cuisine {
                        HStack(spacing: Theme.Spacing.xs) {
                            DSIcon("fork.knife", size: .small, color: .secondary)
                            DSLabel(cuisine, style: .caption1, color: .secondary)
                        }
                    }
                }
            }

            // MARK: - Tags
            if !tags.isEmpty {
                HStack(spacing: Theme.Spacing.xs) {
                    ForEach(tags.prefix(3), id: \.self) { tag in
                        DSTag(tag, style: .secondary, size: .small)
                    }

                    if tags.count > 3 {
                        DSLabel("+\(tags.count - 3)", style: .caption2, color: .tertiary)
                    }
                }
            }
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.backgroundLight)
        .cornerRadius(Theme.CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                .stroke(Theme.Colors.border, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .accessibilityIdentifier(accessibilityID)
    }
}

// MARK: - Previews

#Preview("Recipe Card Basic") {
    VStack(spacing: Theme.Spacing.md) {
        DSRecipeCard(
            title: "Spaghetti Carbonara",
            cuisine: "Italian",
            prepTime: 10,
            cookTime: 20,
            servings: 4,
            isFavorite: false,
            tags: ["Pasta", "Quick", "Dinner"],
            onFavoriteTap: {},
            onDeleteTap: {},
            accessibilityID: "preview-card-1"
        )

        DSRecipeCard(
            title: "Chicken Tikka Masala",
            cuisine: "Indian",
            prepTime: 30,
            cookTime: 45,
            servings: 6,
            isFavorite: true,
            tags: ["Spicy", "Comfort Food", "Main Course"],
            onFavoriteTap: {},
            onDeleteTap: {},
            accessibilityID: "preview-card-2"
        )
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Recipe Card Variations") {
    VStack(spacing: Theme.Spacing.md) {
        DSRecipeCard(
            title: "Simple Pasta",
            isFavorite: false,
            onFavoriteTap: {},
            onDeleteTap: {},
            accessibilityID: "preview-variation-1"
        )

        DSRecipeCard(
            title: "Quick Breakfast Omelette",
            prepTime: 5,
            cookTime: 10,
            isFavorite: false,
            tags: ["Breakfast", "Quick", "Easy", "Protein", "Vegetarian"],
            onFavoriteTap: {},
            onDeleteTap: {},
            accessibilityID: "preview-variation-2"
        )

        DSRecipeCard(
            title: "Very Long Recipe Title That Should Wrap To Multiple Lines Demonstrating Line Limit",
            cuisine: "International",
            prepTime: 45,
            cookTime: 60,
            servings: 8,
            isFavorite: true,
            tags: ["Complex"],
            onFavoriteTap: {},
            onDeleteTap: {},
            accessibilityID: "preview-variation-3"
        )
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Recipe Card List") {
    ScrollView {
        VStack(spacing: Theme.Spacing.md) {
            DSLabel("My Recipes", style: .largeTitle)

            DSDivider(spacing: .compact)

            ForEach(0..<10, id: \.self) { index in
                DSRecipeCard(
                    title: index % 2 == 0 ? "Spaghetti Carbonara" : "Chicken Tikka Masala",
                    cuisine: index % 2 == 0 ? "Italian" : "Indian",
                    prepTime: 10 + (index * 5),
                    cookTime: 20 + (index * 10),
                    servings: 4,
                    isFavorite: index % 3 == 0,
                    tags: index % 2 == 0 ? ["Pasta", "Quick"] : ["Spicy", "Comfort Food"],
                    onFavoriteTap: {},
                    onDeleteTap: {},
                    accessibilityID: "preview-list-\(index)"
                )
            }
        }
        .padding()
    }
    .background(Theme.Colors.background)
}

#Preview("Recipe Card Interactive") {
    @Previewable @State var isFavorite = false

    VStack(spacing: Theme.Spacing.lg) {
        DSLabel("Tap heart to favorite", style: .caption1, color: .secondary)
            .multilineTextAlignment(.center)

        DSRecipeCard(
            title: "Spaghetti Carbonara",
            cuisine: "Italian",
            prepTime: 10,
            cookTime: 20,
            servings: 4,
            isFavorite: isFavorite,
            tags: ["Pasta", "Quick", "Dinner"],
            onFavoriteTap: {
                isFavorite.toggle()
            },
            onDeleteTap: {
                print("Delete tapped!")
            },
            accessibilityID: "preview-interactive"
        )

        if isFavorite {
            HStack(spacing: Theme.Spacing.sm) {
                DSIcon("checkmark.circle.fill", size: .medium, color: .success)
                DSLabel("Added to favorites!", style: .body, color: .success)
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.success.opacity(0.1))
            .cornerRadius(Theme.CornerRadius.md)
        }
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Recipe Card Grid") {
    ScrollView {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            DSLabel("Recipe Collection", style: .largeTitle)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.md) {
                ForEach(0..<6, id: \.self) { index in
                    DSRecipeCard(
                        title: ["Pasta", "Pizza", "Salad", "Soup", "Curry", "Stir Fry"][index],
                        cuisine: ["Italian", "Italian", "Greek", "French", "Indian", "Asian"][index],
                        prepTime: 10,
                        cookTime: 20,
                        servings: 4,
                        isFavorite: index % 2 == 0,
                        tags: ["Quick"],
                        onFavoriteTap: {},
                        onDeleteTap: {},
                        accessibilityID: "preview-grid-\(index)"
                    )
                }
            }
        }
        .padding()
    }
    .background(Theme.Colors.background)
}

#Preview("Recipe Card with Suggestions") {
    VStack(spacing: Theme.Spacing.md) {
        DSRecipeCard(
            title: "Spaghetti Carbonara",
            cuisine: "Italian",
            prepTime: 10,
            cookTime: 20,
            servings: 4,
            isFavorite: false,
            tags: ["Pasta", "Quick", "Dinner"],
            onFavoriteTap: {},
            suggestionReason: "You haven't cooked this in a while",
            onDeleteTap: {},
            accessibilityID: "preview-suggestion-1"
        )

        DSRecipeCard(
            title: "Regular Recipe",
            cuisine: "American",
            prepTime: 15,
            cookTime: 25,
            servings: 4,
            isFavorite: false,
            tags: ["Easy"],
            onFavoriteTap: {},
            onDeleteTap: {},
            accessibilityID: "preview-suggestion-2"
        )
    }
    .padding()
    .background(Theme.Colors.background)
}

// MARK: - Dark Mode Previews

#Preview("Dark: Recipe Card") {
    VStack(spacing: Theme.Spacing.md) {
        DSRecipeCard(
            title: "Chicken Tikka Masala",
            cuisine: "Indian",
            prepTime: 15,
            cookTime: 30,
            servings: 4,
            isFavorite: true,
            tags: ["Spicy", "Dinner"],
            onFavoriteTap: {},
            onDeleteTap: {},
            accessibilityID: "dark-preview-1"
        )

        DSRecipeCard(
            title: "Quick Salad",
            cuisine: "Mediterranean",
            prepTime: 10,
            cookTime: 0,
            servings: 2,
            isFavorite: false,
            tags: ["Healthy", "Quick"],
            onFavoriteTap: {},
            suggestionReason: "Perfect for tonight",
            onDeleteTap: {},
            accessibilityID: "dark-preview-2"
        )
    }
    .padding()
    .background(Theme.Colors.background)
    .preferredColorScheme(.dark)
}
