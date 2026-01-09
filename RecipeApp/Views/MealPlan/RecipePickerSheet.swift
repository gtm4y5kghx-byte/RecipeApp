import SwiftUI
import SwiftData

struct RecipePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var recipes: [Recipe]

    @State private var viewModel: RecipePickerViewModel?

    let onSelect: (Recipe) -> Void

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel {
                    recipeList(viewModel: viewModel)
                } else {
                    DSLoadingSpinner(message: "Loading...")
                }
            }
            .navigationTitle("Select Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("recipe-picker-cancel-button")
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = RecipePickerViewModel(recipes: recipes)
            }
        }
        .onChange(of: recipes) { _, newValue in
            viewModel?.updateRecipes(newValue)
        }
    }

    private func recipeList(viewModel: RecipePickerViewModel) -> some View {
        VStack(spacing: 0) {
            ScopedSearchBar(
                searchText: Bindable(viewModel).searchText,
                searchScope: Bindable(viewModel).searchScope
            )

            if viewModel.filteredRecipes.isEmpty {
                Spacer()
                if viewModel.searchText.isEmpty {
                    DSEmptyState(
                        icon: "book",
                        title: "No Recipes",
                        message: "Add some recipes first to plan your meals.",
                        accessibilityID: "recipe-picker-no-recipes-empty-state"
                    )
                } else {
                    DSEmptyState(
                        icon: "magnifyingglass",
                        title: "No Results",
                        message: "No recipes match your search.",
                        accessibilityID: "recipe-picker-no-results-empty-state"
                    )
                }
                Spacer()
            } else {
                List(viewModel.filteredRecipes) { recipe in
                    Button {
                        onSelect(recipe)
                        dismiss()
                    } label: {
                        HStack(spacing: Theme.Spacing.md) {
                            if let imageURL = recipe.imageURL {
                                DSImage(url: imageURL, height: 44)
                                    .frame(width: 44)
                                    .cornerRadius(Theme.CornerRadius.sm)
                            } else {
                                RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                                    .fill(Theme.Colors.backgroundDark)
                                    .frame(width: 44, height: 44)
                            }

                            DSLabel(recipe.title, style: .body)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollDismissesKeyboard(.interactively)
            }
        }
    }
}
