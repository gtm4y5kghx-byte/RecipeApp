import SwiftUI

struct GeneratePlanResultsView: View {
    @Bindable var viewModel: GeneratePlanViewModel
    let onDone: () -> Void

    @State private var swapTarget: MealPlanGenerationResult?

    var body: some View {
        VStack(spacing: 0) {
            resultsList
            Divider()
            footerActions
        }
        .sheet(item: $swapTarget) { target in
            RecipePickerSheet { recipe in
                viewModel.swapRecipe(for: target, with: recipe)
            }
        }
    }

    // MARK: - Results List

    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.sm) {
                ForEach(viewModel.results) { result in
                    GeneratedPlanCard(
                        result: result,
                        isAdded: viewModel.isAdded(result),
                        onAdd: { viewModel.addResult(result) },
                        onSwap: { swapTarget = result }
                    )
                }
            }
            .padding()
        }
    }

    // MARK: - Footer Actions

    private var footerActions: some View {
        HStack(spacing: Theme.Spacing.md) {
            if viewModel.allResultsAdded {
                DSButton(title: "Done", style: .primary, fullWidth: true) {
                    onDone()
                }
            } else {
                DSButton(
                    title: "Add All (\(viewModel.remainingResults.count))",
                    style: .primary,
                    fullWidth: true
                ) {
                    viewModel.addAllRemaining()
                }
            }
        }
        .padding()
    }
}
