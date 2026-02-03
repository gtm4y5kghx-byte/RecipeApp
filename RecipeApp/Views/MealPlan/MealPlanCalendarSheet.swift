import SwiftUI
import SwiftData

struct MealPlanCalendarSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel: MealPlanViewModel?

    let recipe: Recipe

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel {
                    MealPlanCalendarContent(
                        viewModel: viewModel,
                        recipeToAdd: recipe,
                        onEntryTap: nil,
                        onRecipeAdded: { dismiss() }
                    )
                } else {
                    DSLoadingSpinner(message: "Loading...")
                }
            }
            .navigationTitle("Add to Meal Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("meal-plan-calendar-sheet-cancel-button")
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = MealPlanViewModel(modelContext: modelContext)
                viewModel?.loadEntries()
            }
        }
    }
}
