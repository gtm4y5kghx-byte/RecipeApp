import SwiftUI
import SwiftData

struct CookingModeView: View {
    let recipe: Recipe
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CookingModeViewModel

    init(recipe: Recipe) {
        self.recipe = recipe
        _viewModel = State(initialValue: CookingModeViewModel(
            recipe: recipe,
            modelContext: ModelContext(try! ModelContainer(for: Recipe.self))
        ))
    }

    var body: some View {
        VStack(spacing: 20) {
            CookingStepDisplay(
                progressText: viewModel.progressText,
                stepInstruction: viewModel.currentStep.instruction
            )

            Spacer()

            CookingNavigationButtons(
                isOnFinalStep: viewModel.isOnFinalStep,
                canGoToPrevious: viewModel.canGoToPrevious,
                canGoToNext: viewModel.canGoToNext,
                onPrevious: { viewModel.goToPreviousStep() },
                onNext: { viewModel.goToNextStep() },
                onMarkAsCooked: {
                    if viewModel.markAsCooked() {
                        HapticFeedback.success.trigger()
                        dismiss()
                    }
                }
            )
        }
        .padding()
        .navigationTitle("Cooking: \(recipe.title)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Exit") {
                    dismiss()
                }
                .accessibilityIdentifier("exit-cooking-mode-button")
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Reference") {
                    viewModel.showReference.toggle()
                }
                .accessibilityIdentifier("reference-button")
            }
        }
        .sheet(isPresented: $viewModel.showReference) {
            CookingReferenceSheet(
                recipe: recipe,
                sortedSteps: viewModel.sortedSteps,
                currentStepIndex: viewModel.currentStepIndex,
                isPresented: $viewModel.showReference
            )
        }
        .onAppear {
            viewModel = CookingModeViewModel(recipe: recipe, modelContext: modelContext)
        }
    }
}
