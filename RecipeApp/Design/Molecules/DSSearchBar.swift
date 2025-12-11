import SwiftUI

/// Design System Search Bar
/// Combines text field with search icon and optional clear button
struct DSSearchBar: View {

    // MARK: - Configuration

    let placeholder: String
    let onSubmit: (() -> Void)?

    @Binding var text: String
    @FocusState private var isFocused: Bool

    // MARK: - Initializer

    init(
        placeholder: String = "Search",
        text: Binding<String>,
        onSubmit: (() -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.onSubmit = onSubmit
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            DSIcon("magnifyingglass", size: .medium, color: .secondary)

            TextField(placeholder, text: $text)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textPrimary)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .focused($isFocused)
                .submitLabel(.search)
                .onSubmit {
                    onSubmit?()
                }

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    DSIcon("xmark.circle.fill", size: .medium, color: .tertiary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.sm + 4)
        .background(Theme.Colors.backgroundLight)
        .cornerRadius(Theme.CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                .stroke(isFocused ? Theme.Colors.primary : Theme.Colors.border, lineWidth: isFocused ? 2 : 1)
        )
    }
}

// MARK: - Previews

#Preview("Search Bar States") {
    @Previewable @State var emptySearch = ""
    @Previewable @State var activeSearch = "pasta"

    VStack(spacing: Theme.Spacing.lg) {
        DSLabel("Empty State", style: .caption1, color: .secondary)
        DSSearchBar(text: $emptySearch)

        DSLabel("With Text (shows clear button)", style: .caption1, color: .secondary)
        DSSearchBar(text: $activeSearch)

        DSLabel("Custom Placeholder", style: .caption1, color: .secondary)
        DSSearchBar(placeholder: "Search recipes...", text: $emptySearch)
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Search Bar in Context") {
    @Previewable @State var searchText = ""

    VStack(spacing: 0) {
        // Header with search
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                DSLabel("My Recipes", style: .largeTitle)
                Spacer()
                DSIcon("line.3.horizontal.decrease.circle", size: .large, color: .primary)
            }

            DSSearchBar(placeholder: "Search recipes, ingredients...", text: $searchText)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.backgroundLight)

        // Content area
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                if searchText.isEmpty {
                    DSLabel("All Recipes", style: .headline)
                    DSLabel("47 recipes", style: .caption1, color: .secondary)
                } else {
                    DSLabel("Search Results for '\(searchText)'", style: .headline)
                    DSLabel("12 recipes found", style: .caption1, color: .secondary)
                }

                DSDivider(spacing: .compact)

                // Mock recipe list
                ForEach(0..<5, id: \.self) { _ in
                    HStack {
                        DSLabel("Spaghetti Carbonara", style: .body)
                        Spacer()
                        DSIcon("chevron.right", size: .small, color: .tertiary)
                    }
                    .padding(Theme.Spacing.md)
                    .background(Theme.Colors.backgroundLight)
                    .cornerRadius(Theme.CornerRadius.md)
                }
            }
            .padding(Theme.Spacing.md)
        }
    }
    .background(Theme.Colors.background)
}

#Preview("Search with Submit Action") {
    @Previewable @State var searchText = ""
    @Previewable @State var submittedQuery = ""

    VStack(spacing: Theme.Spacing.lg) {
        DSSearchBar(
            placeholder: "Search recipes...",
            text: $searchText,
            onSubmit: {
                submittedQuery = searchText
            }
        )

        if !submittedQuery.isEmpty {
            HStack(spacing: Theme.Spacing.sm) {
                DSIcon("checkmark.circle.fill", size: .medium, color: .success)
                DSLabel("Searched for: '\(submittedQuery)'", style: .body, color: .success)
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.success.opacity(0.1))
            .cornerRadius(Theme.CornerRadius.md)
        }

        DSLabel("Tap 'Search' on keyboard to submit", style: .caption1, color: .secondary)
            .multilineTextAlignment(.center)
    }
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Search Bar Focus States") {
    @Previewable @State var searchText = ""

    VStack(spacing: Theme.Spacing.lg) {
        DSLabel("Tap to see focus state", style: .caption1, color: .secondary)

        DSSearchBar(placeholder: "Search recipes...", text: $searchText)

        DSLabel("Border changes to burgundy (2pt) when focused", style: .caption2, color: .tertiary)
            .multilineTextAlignment(.center)
    }
    .padding()
    .background(Theme.Colors.background)
}
