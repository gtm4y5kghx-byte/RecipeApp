import SwiftUI

struct SharePreviewView: View {
    var viewModel: ShareViewModel

    var body: some View {
        NavigationStack {
            contentForState
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Theme.Colors.background)
                .navigationTitle("Import Recipe")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { viewModel.cancel() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        addButton
                    }
                }
        }
    }

    // MARK: - State Router

    @ViewBuilder
    private var contentForState: some View {
        switch viewModel.state {
        case .loading(let message):
            loadingView(message: message)
        case .error(let title, let message):
            errorView(title: title, message: message)
        case .preview(let recipe, _):
            previewContent(recipe: recipe)
        }
    }

    // MARK: - Loading

    private func loadingView(message: String) -> some View {
        VStack {
            Spacer()
            DSLoadingSpinner(message: message, size: .large)
            Spacer()
        }
    }

    // MARK: - Error

    private func errorView(title: String, message: String) -> some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()

            DSIcon("exclamationmark.triangle.fill", size: .xlarge, color: .error)

            VStack(spacing: Theme.Spacing.sm) {
                DSLabel(title, style: .title3, alignment: .center)
                DSLabel(message, style: .body, color: .secondary, alignment: .center)
            }
            .padding(.horizontal, Theme.Spacing.xl)

            Spacer()
        }
    }

    // MARK: - Preview

    private func previewContent(recipe: RecipeImportData) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                recipeImage(recipe: recipe)

                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    DSLabel(recipe.title, style: .title2)

                    if let description = recipe.description {
                        DSLabel(description, style: .body, color: .secondary)
                    }

                    if let author = recipe.author {
                        HStack(spacing: Theme.Spacing.xs) {
                            DSIcon("person", size: .small, color: .secondary)
                            DSLabel(author, style: .caption1, color: .secondary)
                        }
                    }

                    metadataRow(recipe: recipe)

                    DSDivider(thickness: .thin, color: .prominent, spacing: .compact)

                    summarySection(recipe: recipe)

                    if case .preview(_, true) = viewModel.state {
                        alreadyImportedBanner
                    }
                }
                .padding(.horizontal, Theme.Spacing.screenEdge)
            }
            .padding(.bottom, Theme.Spacing.lg)
        }
    }

    // MARK: - Recipe Image

    @ViewBuilder
    private func recipeImage(recipe: RecipeImportData) -> some View {
        if recipe.imageURL != nil {
            DSImage(url: recipe.imageURL, height: 200, aspectRatio: .fill)
                .clipped()
        }
    }

    // MARK: - Metadata Row

    private func metadataRow(recipe: RecipeImportData) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            if let prepTime = viewModel.formattedPrepTime {
                metadataItem(icon: "clock", label: "Prep", text: prepTime)
            }
            if let cookTime = viewModel.formattedCookTime {
                metadataItem(icon: "flame", label: "Cook", text: cookTime)
            }
            if let servings = recipe.servings {
                metadataItem(icon: "person.2", label: "Serves", text: "\(servings)")
            }
        }
    }

    private func metadataItem(icon: String, label: String, text: String) -> some View {
        VStack(spacing: Theme.Spacing.xs) {
            DSIcon(icon, size: .small, color: .secondary)
            DSLabel(text, style: .caption1, color: .primary)
            DSLabel(label, style: .caption2, color: .tertiary)
        }
        .frame(minWidth: 60)
    }

    // MARK: - Summary Section

    private func summarySection(recipe: RecipeImportData) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            summaryRow(icon: "list.bullet", text: "\(recipe.ingredients.count) ingredients")
            summaryRow(icon: "text.justify.leading", text: "\(recipe.instructions.count) steps")
            if let cuisine = recipe.cuisine {
                summaryRow(icon: "fork.knife", text: cuisine)
            }
            if let category = recipe.category {
                summaryRow(icon: "tag", text: category)
            }
            if recipe.nutrition != nil {
                summaryRow(icon: "chart.bar", text: "Nutrition info included")
            }
        }
    }

    private func summaryRow(icon: String, text: String) -> some View {
        HStack(spacing: Theme.Spacing.sm) {
            DSIcon(icon, size: .small, color: .secondary)
            DSLabel(text, style: .body, color: .primary)
        }
    }

    // MARK: - Already Imported Banner

    private var alreadyImportedBanner: some View {
        HStack(spacing: Theme.Spacing.sm) {
            DSIcon("checkmark.circle.fill", size: .medium, color: .success)
            DSLabel("Already in your collection", style: .subheadline, color: .success)
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.success.opacity(0.12))
        .cornerRadius(Theme.CornerRadius.md)
    }

    // MARK: - Add Button

    @ViewBuilder
    private var addButton: some View {
        if case .preview(_, let alreadyImported) = viewModel.state {
            if alreadyImported {
                DSLabel("Imported", style: .body, color: .tertiary)
            } else {
                Button("Add") { viewModel.addRecipe() }
                    .bold()
            }
        }
    }
}

// MARK: - Previews

@MainActor
private func makePreviewViewModel(state: ShareViewModel.ViewState) -> ShareViewModel {
    let vm = ShareViewModel(dismiss: {}, complete: {})
    vm.state = state
    return vm
}

private let mockRecipe = RecipeImportData(
    title: "Classic Margherita Pizza",
    description: "A simple and delicious Italian pizza with fresh mozzarella, tomatoes, and basil.",
    sourceURL: "https://example.com/margherita-pizza",
    imageURL: nil,
    prepTime: 30,
    cookTime: 15,
    totalTime: 45,
    servings: 4,
    cuisine: "Italian",
    category: "Dinner",
    ingredients: [
        "2 cups flour",
        "1 cup warm water",
        "Fresh mozzarella",
        "San Marzano tomatoes",
        "Fresh basil",
        "Olive oil",
        "Salt"
    ],
    instructions: [
        "Make the dough",
        "Let it rise for 1 hour",
        "Stretch the dough",
        "Add toppings",
        "Bake at 475°F for 12-15 minutes"
    ],
    nutrition: NutritionImportData(
        calories: 266,
        carbohydrates: 33,
        protein: 12,
        fat: 10,
        fiber: 2,
        sodium: nil,
        sugar: nil
    ),
    author: "Serious Eats"
)

#Preview("Recipe") {
    SharePreviewView(viewModel: makePreviewViewModel(
        state: .preview(recipe: mockRecipe, alreadyImported: false)
    ))
}

#Preview("Already Imported") {
    SharePreviewView(viewModel: makePreviewViewModel(
        state: .preview(recipe: mockRecipe, alreadyImported: true)
    ))
}

#Preview("Loading") {
    SharePreviewView(viewModel: makePreviewViewModel(
        state: .loading(message: "Fetching recipe...")
    ))
}

#Preview("Error") {
    SharePreviewView(viewModel: makePreviewViewModel(
        state: .error(title: "No Recipe Found", message: "This page doesn't contain structured recipe data.")
    ))
}
