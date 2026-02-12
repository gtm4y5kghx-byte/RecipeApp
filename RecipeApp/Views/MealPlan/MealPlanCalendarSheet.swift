import SwiftUI
import SwiftData

struct MealPlanCalendarSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel: MealPlanViewModel?
    @State private var scrollToTodayTrigger = false

    let recipe: Recipe

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel {
                    MealPlanCalendarContent(
                        viewModel: viewModel,
                        recipeToAdd: recipe,
                        onEntryTap: nil,
                        onRecipeAdded: { dismiss() },
                        scrollToTodayTrigger: $scrollToTodayTrigger
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Today") {
                        scrollToTodayTrigger.toggle()
                    }
                    .accessibilityIdentifier("meal-plan-calendar-sheet-today-button")
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
