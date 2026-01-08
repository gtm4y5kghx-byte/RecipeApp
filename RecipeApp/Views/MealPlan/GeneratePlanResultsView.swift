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
        List {
            if let message = viewModel.resultCountMessage {
                HStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(Theme.Colors.accent)
                    DSLabel(message, style: .subheadline, color: .secondary)
                }
                .padding(Theme.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.Colors.backgroundLight)
                .cornerRadius(Theme.CornerRadius.sm)
                .listRowInsets(EdgeInsets(
                    top: Theme.Spacing.sm,
                    leading: Theme.Spacing.md,
                    bottom: Theme.Spacing.sm,
                    trailing: Theme.Spacing.md
                ))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            ForEach(viewModel.results) { result in
                GeneratedPlanCard(
                    result: result,
                    isAdded: viewModel.isAdded(result),
                    onAdd: { viewModel.addResult(result) },
                    onRemove: { viewModel.removeResult(result) },
                    onSwap: { swapTarget = result },
                    accessibilityID: "generated-plan-card-\(result.id)"
                )
                .listRowInsets(EdgeInsets(
                    top: Theme.Spacing.xs,
                    leading: Theme.Spacing.md,
                    bottom: Theme.Spacing.xs,
                    trailing: Theme.Spacing.md
                ))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        viewModel.deleteResult(result)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Footer Actions

    private var footerActions: some View {
        HStack(spacing: Theme.Spacing.md) {
            if viewModel.allResultsAdded {
                DSButton(title: "Done", style: .primary, fullWidth: true) {
                    onDone()
                }
                .accessibilityIdentifier("generate-plan-done-button")
            } else {
                DSButton(
                    title: "Add All (\(viewModel.remainingResults.count))",
                    style: .primary,
                    fullWidth: true
                ) {
                    viewModel.addAllRemaining()
                }
                .accessibilityIdentifier("generate-plan-add-all-button")
            }
        }
        .padding()
    }
}
