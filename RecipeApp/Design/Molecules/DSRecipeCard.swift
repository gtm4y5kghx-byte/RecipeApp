import SwiftUI

enum DSRecipeCardAction {
    case favorite(isFavorite: Bool, onTap: () -> Void)
    case save(onTap: () -> Void)
}

/// Design System Recipe Card
/// Displays recipe information in a card format for lists/grids
/// Supports both saved recipes (with favorite) and generated recipes (with save button)
struct DSRecipeCard: View {

    // MARK: - Configuration

    let title: String
    let imageURL: String?
    let subtitle: String?
    let showSuggestionBadge: Bool
    let cuisine: String?
    let prepTime: Int?
    let cookTime: Int?
    let servings: Int?
    let tags: [String]
    let action: DSRecipeCardAction
    let onDeleteTap: (() -> Void)?
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
        imageURL: String? = nil,
        subtitle: String? = nil,
        showSuggestionBadge: Bool = false,
        cuisine: String? = nil,
        prepTime: Int? = nil,
        cookTime: Int? = nil,
        servings: Int? = nil,
        tags: [String] = [],
        action: DSRecipeCardAction,
        onDeleteTap: (() -> Void)? = nil,
        accessibilityID: String
    ) {
        self.title = title
        self.imageURL = imageURL
        self.subtitle = subtitle
        self.showSuggestionBadge = showSuggestionBadge
        self.cuisine = cuisine
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.servings = servings
        self.tags = tags
        self.action = action
        self.onDeleteTap = onDeleteTap
        self.accessibilityID = accessibilityID
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            if let imageURL = imageURL {
                DSImage(url: imageURL, height: 160)
                    .cornerRadius(Theme.CornerRadius.md)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                        .fill(Theme.Colors.backgroundDark)
                    Image(systemName: "fork.knife")
                        .font(.system(size: 40))
                        .foregroundColor(Theme.Colors.textTertiary)
                }
                .frame(height: 160)
            }

            headerRow

            if subtitle != nil || showSuggestionBadge {
                subtitleSection
            }

            if totalTime != nil || servings != nil || cuisine != nil {
                metadataRow
            }

            if !tags.isEmpty {
                tagsRow
            }

            if case .save(let onTap) = action {
                DSButton(title: "Save to Collection", style: .primary, action: onTap)
                    .accessibilityIdentifier("\(accessibilityID)-save-button")
            }
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.backgroundLight)
        .cornerRadius(Theme.CornerRadius.md)
        .shadow(color: .black.opacity(0.10), radius: 8, x: 0, y: 2)
        .contentShape(Rectangle())
        .accessibilityIdentifier(accessibilityID)
    }

    // MARK: - Subviews

    private var headerRow: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
            DSLabel(title, style: .headline, color: .primary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            if case .favorite(let isFavorite, let onTap) = action {
                DSIconButton(
                    isFavorite ? "heart.fill" : "heart",
                    size: .medium,
                    color: isFavorite ? .error : .secondary,
                    accessibilityID: "\(accessibilityID)-favorite-button"
                ) {
                    HapticFeedback.light.trigger()
                    onTap()
                }
            }
        }
    }

    private var subtitleSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            if showSuggestionBadge {
                HStack(spacing: Theme.Spacing.xs) {
                    DSIcon("sparkles", size: .small, color: .accent)
                    DSLabel("Suggested", style: .caption1, color: .accent)
                }
            }

            if let subtitle = subtitle {
                DSLabel(subtitle, style: .caption2, color: .secondary)
                    .lineLimit(2)
            }
        }
    }

    private var metadataRow: some View {
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

    private var tagsRow: some View {
        HStack(spacing: Theme.Spacing.xs) {
            ForEach(tags.prefix(3), id: \.self) { tag in
                DSTag(tag, style: .secondary, size: .small)
            }

            if tags.count > 3 {
                DSLabel("+\(tags.count - 3)", style: .caption2, color: .primary)
            }
        }
    }
}

// MARK: - Previews

#Preview("Recipe Card - Favorite Action") {
    VStack(spacing: Theme.Spacing.md) {
        DSRecipeCard(
            title: "Spaghetti Carbonara",
            cuisine: "Italian",
            prepTime: 10,
            cookTime: 20,
            servings: 4,
            tags: ["Mediterranean Fusion Cuisine", "Mediterranean Fusion Cuisine", "Dinner", "Tag", "Tag2"],
            action: .favorite(isFavorite: false, onTap: {}),
            accessibilityID: "preview-card-1"
        )

        DSRecipeCard(
            title: "Chicken Tikka Masala",
            imageURL: "https://placehold.co/400x300",
            cuisine: "Indian",
            prepTime: 30,
            cookTime: 45,
            servings: 6,
            tags: ["Spicy", "Comfort Food", "Main Course"],
            action: .favorite(isFavorite: true, onTap: {}),
            accessibilityID: "preview-card-2"
        )
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Recipe Card - Save Action (Generated)") {
    VStack(spacing: Theme.Spacing.md) {
        DSRecipeCard(
            title: "Mediterranean Chickpea Bowl",
            subtitle: "A healthy grain bowl with roasted chickpeas, fresh vegetables, and tahini dressing.",
            cuisine: "Mediterranean",
            prepTime: 15,
            cookTime: 20,
            servings: 4,
            tags: ["Healthy", "Vegetarian", "Quick"],
            action: .save(onTap: {}),
            accessibilityID: "preview-generated-1"
        )

        DSRecipeCard(
            title: "Spicy Korean Beef Tacos",
            subtitle: "Fusion tacos with gochujang-marinated beef, pickled vegetables, and sriracha mayo.",
            cuisine: "Korean-Mexican",
            prepTime: 20,
            cookTime: 25,
            servings: 6,
            tags: ["Spicy", "Fusion"],
            action: .save(onTap: {}),
            accessibilityID: "preview-generated-2"
        )
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Recipe Card - With Suggestion Badge") {
    VStack(spacing: Theme.Spacing.md) {
        DSRecipeCard(
            title: "Spaghetti Carbonara",
            subtitle: "You haven't cooked this in a while",
            showSuggestionBadge: true,
            cuisine: "Italian",
            prepTime: 10,
            cookTime: 20,
            servings: 4,
            tags: ["Pasta", "Quick", "Dinner"],
            action: .favorite(isFavorite: false, onTap: {}),
            accessibilityID: "preview-suggestion-1"
        )

        DSRecipeCard(
            title: "Regular Recipe",
            cuisine: "American",
            prepTime: 15,
            cookTime: 25,
            servings: 4,
            tags: ["Easy"],
            action: .favorite(isFavorite: false, onTap: {}),
            accessibilityID: "preview-suggestion-2"
        )
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Recipe Card - With Image") {
    VStack(spacing: Theme.Spacing.md) {
        DSRecipeCard(
            title: "Mediterranean Chickpea Bowl",
            imageURL: "https://placehold.co/400x300",
            subtitle: "A healthy grain bowl with roasted chickpeas.",
            cuisine: "Mediterranean",
            prepTime: 15,
            cookTime: 20,
            servings: 4,
            tags: ["Healthy", "Vegetarian"],
            action: .save(onTap: {}),
            accessibilityID: "preview-with-image"
        )
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Recipe Card - Minimal") {
    VStack(spacing: Theme.Spacing.md) {
        DSRecipeCard(
            title: "Simple Pasta",
            action: .favorite(isFavorite: false, onTap: {}),
            accessibilityID: "preview-minimal-1"
        )

        DSRecipeCard(
            title: "Quick Recipe",
            action: .save(onTap: {}),
            accessibilityID: "preview-minimal-2"
        )
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Recipe Card - Interactive") {
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
            tags: ["Pasta", "Quick", "Dinner"],
            action: .favorite(isFavorite: isFavorite, onTap: {
                isFavorite.toggle()
            }),
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

#Preview("Dark: Recipe Card") {
    VStack(spacing: Theme.Spacing.md) {
        DSRecipeCard(
            title: "Chicken Tikka Masala",
            cuisine: "Indian",
            prepTime: 15,
            cookTime: 30,
            servings: 4,
            tags: ["Spicy", "Dinner"],
            action: .favorite(isFavorite: true, onTap: {}),
            accessibilityID: "dark-preview-1"
        )

        DSRecipeCard(
            title: "AI Generated Recipe",
            subtitle: "Made for you based on your preferences",
            cuisine: "Mediterranean",
            prepTime: 10,
            cookTime: 20,
            servings: 2,
            tags: ["Healthy", "Quick"],
            action: .save(onTap: {}),
            accessibilityID: "dark-preview-2"
        )
    }
    .padding()
    .background(Theme.Colors.background)
    .preferredColorScheme(.dark)
}
