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
                        .searchable(text: Bindable(viewModel).searchText, placement: .navigationBarDrawer(displayMode: .always))
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
            if !viewModel.searchText.isEmpty {
                SearchScopePicker(selectedScope: Bindable(viewModel).searchScope)
            }

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
                                DSImage(url: imageURL, height: 60)
                                    .frame(width: 60)
                                    .cornerRadius(Theme.CornerRadius.sm)
                            } else {
                                DSImagePlaceholder(height: 60, cornerRadius: Theme.CornerRadius.sm)
                                    .frame(width: 60)
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
