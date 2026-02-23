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
        self.accessibilityID = accessibilityID
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            HStack(alignment: .top, spacing: Theme.Spacing.md) {
                thumbnail

                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        DSLabel(title, style: .headline, color: .primary)
                            .lineLimit(1)

                        if let subtitle = subtitle {
                            if showSuggestionBadge {
                                suggestionSubtitle(reason: subtitle)
                            } else {
                                DSLabel(subtitle, style: .caption1, color: .secondary)
                                    .lineLimit(1)
                            }
                        }
                    }

                    if totalTime != nil {
                        timeRow
                    }

                    if !tags.isEmpty {
                        tagsRow
                    }
                }

                Spacer(minLength: 0)

                if case .favorite(let isFavorite, let onTap) = action {
                    DSIconButton(
                        isFavorite ? "heart.fill" : "heart",
                        size: .medium,
                        color: isFavorite ? .error : .secondary,
                        bounceValue: isFavorite,
                        accessibilityID: "\(accessibilityID)-favorite-button"
                    ) {
                        HapticFeedback.light.trigger()
                        onTap()
                    }
                }
            }

            if case .save(let onTap) = action {
                DSButton(title: "Save to Collection", style: .primary, action: onTap)
                    .accessibilityIdentifier("\(accessibilityID)-save-button")
            }
        }
        .padding(Theme.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .accessibilityIdentifier(accessibilityID)
    }

    // MARK: - Subviews

    private var thumbnail: some View {
        Group {
            if let imageURL = imageURL {
                DSImage(url: imageURL, height: 80)
            } else {
                DSImagePlaceholder(height: 80)
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.sm))
    }

    private func suggestionSubtitle(reason: String) -> some View {
        HStack(spacing: Theme.Spacing.xs) {
            Image(systemName: "sparkles")
                .font(.system(size: 10))
                .foregroundColor(Theme.Colors.accent)

            Text(suggestionBadgeText(reason: reason))
                .font(Theme.Typography.caption1)
                .lineLimit(1)
        }
    }

    private func suggestionBadgeText(reason: String) -> AttributedString {
        var forYou = AttributedString("For You: ")
        forYou.foregroundColor = Theme.Colors.accent
        forYou.inlinePresentationIntent = .stronglyEmphasized

        var reasonText = AttributedString(reason)
        reasonText.foregroundColor = Theme.Colors.textSecondary

        return forYou + reasonText
    }

    private var timeRow: some View {
        HStack(spacing: Theme.Spacing.xs) {
            DSIcon("clock", size: .small, color: .secondary)
            DSLabel("\(totalTime!) min", style: .caption1, color: .secondary)
        }
    }

    private var tagsRow: some View {
        HStack(spacing: Theme.Spacing.xs) {
            ForEach(tags.prefix(2), id: \.self) { tag in
                DSTag(tag, style: .secondary, size: .small)
            }

            if tags.count > 2 {
                DSLabel("+\(tags.count - 2)", style: .caption2, color: .secondary)
            }
        }
    }
}

// MARK: - Previews

#Preview("Recipe Card - List") {
    ScrollView {
        LazyVStack(spacing: 0) {
            DSRecipeCard(
                title: "Spaghetti Carbonara",
                imageURL: "https://placehold.co/200x200",
                prepTime: 10,
                cookTime: 20,
                tags: ["Pasta", "Quick", "Dinner"],
                action: .favorite(isFavorite: false, onTap: {}),
                accessibilityID: "preview-1"
            )
            DSDivider(thickness: .thin, color: .subtle, spacing: .none)

            DSRecipeCard(
                title: "Chicken Tikka Masala with Extra Long Title That Wraps",
                imageURL: "https://placehold.co/200x200",
                prepTime: 30,
                cookTime: 45,
                tags: ["Spicy", "Comfort Food", "Main Course"],
                action: .favorite(isFavorite: true, onTap: {}),
                accessibilityID: "preview-2"
            )
            DSDivider(thickness: .thin, color: .subtle, spacing: .none)

            DSRecipeCard(
                title: "Simple Pasta",
                action: .favorite(isFavorite: false, onTap: {}),
                accessibilityID: "preview-3"
            )
            DSDivider(thickness: .thin, color: .subtle, spacing: .none)

            DSRecipeCard(
                title: "Beef & Broccoli",
                imageURL: "https://placehold.co/200x200",
                cookTime: 25,
                tags: ["Wok"],
                action: .favorite(isFavorite: false, onTap: {}),
                accessibilityID: "preview-4"
            )
        }
        .padding(.horizontal, Theme.Spacing.md)
    }
    .background(Theme.Colors.background)
}

#Preview("Dark: Recipe Card - List") {
    ScrollView {
        LazyVStack(spacing: 0) {
            DSRecipeCard(
                title: "Spaghetti Carbonara",
                imageURL: "https://placehold.co/200x200",
                prepTime: 10,
                cookTime: 20,
                tags: ["Pasta", "Quick", "Dinner"],
                action: .favorite(isFavorite: false, onTap: {}),
                accessibilityID: "preview-1"
            )
            DSDivider(thickness: .thin, color: .subtle, spacing: .none)

            DSRecipeCard(
                title: "Chicken Tikka Masala with Extra Long Title That Wraps",
                imageURL: "https://placehold.co/200x200",
                prepTime: 30,
                cookTime: 45,
                tags: ["Spicy", "Comfort Food", "Main Course"],
                action: .favorite(isFavorite: true, onTap: {}),
                accessibilityID: "preview-2"
            )
            DSDivider(thickness: .thin, color: .subtle, spacing: .none)

            DSRecipeCard(
                title: "Simple Pasta",
                action: .favorite(isFavorite: false, onTap: {}),
                accessibilityID: "preview-3"
            )
            DSDivider(thickness: .thin, color: .subtle, spacing: .none)

            DSRecipeCard(
                title: "Beef & Broccoli",
                imageURL: "https://placehold.co/200x200",
                cookTime: 25,
                tags: ["Wok"],
                action: .favorite(isFavorite: false, onTap: {}),
                accessibilityID: "preview-4"
            )
        }
        .padding(.horizontal, Theme.Spacing.md)
    }
    .background(Theme.Colors.background)
    .preferredColorScheme(.dark)
}

#Preview("Recipe Card - Suggestions") {
    VStack(spacing: Theme.Spacing.sm) {
        DSRecipeCard(
            title: "Spaghetti Carbonara",
            imageURL: "https://placehold.co/200x200",
            subtitle: "You haven't cooked this in a while",
            showSuggestionBadge: true,
            prepTime: 10,
            cookTime: 20,
            tags: ["Pasta", "Quick"],
            action: .favorite(isFavorite: false, onTap: {}),
            accessibilityID: "preview-suggestion-1"
        )

        DSRecipeCard(
            title: "Thai Green Curry",
            subtitle: "Quick weeknight dinner",
            showSuggestionBadge: true,
            cookTime: 30,
            tags: ["Spicy", "Thai"],
            action: .favorite(isFavorite: false, onTap: {}),
            accessibilityID: "preview-suggestion-2"
        )
    }
    .padding(.horizontal, Theme.Spacing.md)
    .background(Theme.Colors.background)
}

#Preview("Recipe Card - Generated") {
    VStack(spacing: Theme.Spacing.sm) {
        DSRecipeCard(
            title: "Mediterranean Chickpea Bowl",
            subtitle: "A healthy grain bowl with roasted chickpeas.",
            showSuggestionBadge: true,
            prepTime: 15,
            cookTime: 20,
            tags: ["Healthy", "Vegetarian"],
            action: .save(onTap: {}),
            accessibilityID: "preview-generated-1"
        )
    }
    .padding(.horizontal, Theme.Spacing.md)
    .background(Theme.Colors.background)
}

#Preview("Recipe Card - Interactive") {
    @Previewable @State var isFavorite = false

    DSRecipeCard(
        title: "Spaghetti Carbonara",
        imageURL: "https://placehold.co/200x200",
        prepTime: 10,
        cookTime: 20,
        tags: ["Pasta", "Quick", "Dinner"],
        action: .favorite(isFavorite: isFavorite, onTap: {
            isFavorite.toggle()
        }),
        accessibilityID: "preview-interactive"
    )
    .padding(.horizontal, Theme.Spacing.md)
    .background(Theme.Colors.background)
}

#Preview("Dark: Recipe Card") {
    ScrollView {
        VStack(spacing: Theme.Spacing.sm) {
            DSRecipeCard(
                title: "Chicken Tikka Masala",
                imageURL: "https://placehold.co/200x200",
                prepTime: 15,
                cookTime: 30,
                tags: ["Spicy", "Dinner"],
                action: .favorite(isFavorite: true, onTap: {}),
                accessibilityID: "dark-1"
            )

            DSRecipeCard(
                title: "AI Generated Recipe",
                subtitle: "Made for you based on your preferences",
                prepTime: 10,
                cookTime: 20,
                tags: ["Healthy", "Quick"],
                action: .save(onTap: {}),
                accessibilityID: "dark-2"
            )

            DSRecipeCard(
                title: "French Lemon Tart",
                subtitle: "You haven't made this in a while",
                showSuggestionBadge: true,
                prepTime: 30,
                cookTime: 45,
                tags: ["Dessert", "Baking"],
                action: .favorite(isFavorite: false, onTap: {}),
                accessibilityID: "dark-3"
            )
        }
        .padding(.horizontal, Theme.Spacing.md)
    }
    .background(Theme.Colors.background)
    .preferredColorScheme(.dark)
}
