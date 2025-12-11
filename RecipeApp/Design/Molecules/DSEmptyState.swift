import SwiftUI

/// Design System Empty State
/// Displays a helpful message when there's no content to show
struct DSEmptyState: View {

    // MARK: - Configuration

    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    // MARK: - Initializer

    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()

            // Icon
            DSIcon(icon, size: .xlarge, color: .tertiary)
                .padding(Theme.Spacing.xl)
                .background(Theme.Colors.backgroundDark)
                .clipShape(Circle())

            // Title
            DSLabel(title, style: .title2, color: .primary, alignment: .center)
                .padding(.horizontal, Theme.Spacing.xl)

            // Message
            DSLabel(message, style: .body, color: .secondary, alignment: .center)
                .padding(.horizontal, Theme.Spacing.xl)

            // Optional action button
            if let actionTitle = actionTitle, let action = action {
                DSButton(title: actionTitle, style: .primary, action: action)
                    .padding(.horizontal, Theme.Spacing.xl)
                    .padding(.top, Theme.Spacing.sm)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Previews

#Preview("Empty State - No Recipes") {
    DSEmptyState(
        icon: "fork.knife",
        title: "No Recipes Yet",
        message: "Start building your recipe collection by adding your first recipe.",
        actionTitle: "Add Recipe",
        action: {}
    )
    .background(Theme.Colors.background)
}

#Preview("Empty State - No Search Results") {
    DSEmptyState(
        icon: "magnifyingglass",
        title: "No Results Found",
        message: "We couldn't find any recipes matching your search. Try different keywords or browse all recipes.",
        actionTitle: "Clear Search",
        action: {}
    )
    .background(Theme.Colors.background)
}

#Preview("Empty State - No Favorites") {
    DSEmptyState(
        icon: "heart",
        title: "No Favorites Yet",
        message: "Mark recipes as favorites by tapping the heart icon. Your favorite recipes will appear here.",
        actionTitle: "Browse Recipes",
        action: {}
    )
    .background(Theme.Colors.background)
}

#Preview("Empty State - Without Action") {
    DSEmptyState(
        icon: "checkmark.circle",
        title: "All Caught Up",
        message: "You've reviewed all your recipes. Check back later for new suggestions."
    )
    .background(Theme.Colors.background)
}

#Preview("Empty State Variations") {
    TabView {
        DSEmptyState(
            icon: "tray",
            title: "No Items",
            message: "Your shopping list is empty. Add ingredients from recipes to get started.",
            actionTitle: "Browse Recipes",
            action: {}
        )
        .background(Theme.Colors.background)
        .tabItem { Label("Shopping List", systemImage: "cart") }

        DSEmptyState(
            icon: "clock.arrow.circlepath",
            title: "No Recent Activity",
            message: "You haven't cooked any recipes recently. Start cooking to track your history.",
            actionTitle: "Find a Recipe",
            action: {}
        )
        .background(Theme.Colors.background)
        .tabItem { Label("Recent", systemImage: "clock") }

        DSEmptyState(
            icon: "tag",
            title: "No Tags Created",
            message: "Organize your recipes by creating custom tags like 'Weeknight', 'Healthy', or 'Party'."
        )
        .background(Theme.Colors.background)
        .tabItem { Label("Tags", systemImage: "tag") }
    }
}

#Preview("Empty State in List Context") {
    VStack(spacing: 0) {
        // Header
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                DSLabel("My Favorites", style: .largeTitle)
                Spacer()
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.backgroundLight)

        // Empty state
        DSEmptyState(
            icon: "heart",
            title: "No Favorites Yet",
            message: "Start building your favorites collection by tapping the heart icon on recipes you love.",
            actionTitle: "Explore Recipes",
            action: {}
        )
        .background(Theme.Colors.background)
    }
}

#Preview("Empty State - Long Message") {
    DSEmptyState(
        icon: "exclamationmark.triangle",
        title: "Import Failed",
        message: "We couldn't import this recipe. The website may not be supported or the recipe format is incompatible. Try copying the recipe details manually or check if the URL is correct.",
        actionTitle: "Try Again",
        action: {}
    )
    .background(Theme.Colors.background)
}

#Preview("Empty State - Success State") {
    DSEmptyState(
        icon: "checkmark.circle.fill",
        title: "All Done!",
        message: "You've completed all the steps for this recipe. Enjoy your meal!",
        actionTitle: "Rate Recipe",
        action: {}
    )
    .background(Theme.Colors.background)
}

#Preview("Empty State Grid") {
    ScrollView {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.lg) {
            DSEmptyState(
                icon: "fork.knife",
                title: "No Recipes",
                message: "Add your first recipe",
                actionTitle: "Add",
                action: {}
            )
            .frame(height: 300)
            .background(Theme.Colors.backgroundLight)
            .cornerRadius(Theme.CornerRadius.md)

            DSEmptyState(
                icon: "heart",
                title: "No Favorites",
                message: "Mark recipes as favorites",
                actionTitle: "Browse",
                action: {}
            )
            .frame(height: 300)
            .background(Theme.Colors.backgroundLight)
            .cornerRadius(Theme.CornerRadius.md)
        }
        .padding()
    }
    .background(Theme.Colors.background)
}
