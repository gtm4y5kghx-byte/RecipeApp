import SwiftUI
import SwiftData

struct MealPlanCalendarSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MealPlanEntry.date) private var entries: [MealPlanEntry]

    @State private var viewModel: MealPlanViewModel?
    @State private var scrollToTodayTrigger = false
    @State private var showErrorToast = false

    let recipe: Recipe
    var onRecipeAdded: (() -> Void)? = nil

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel {
                    MealPlanCalendarContent(
                        viewModel: viewModel,
                        recipeToAdd: recipe,
                        onEntryTap: nil,
                        onRecipeAdded: {
                            onRecipeAdded?()
                            dismiss()
                        },
                        scrollToTodayTrigger: $scrollToTodayTrigger
                    )
                    .frame(maxWidth: Theme.Layout.maxSheetContentWidth)
                    .frame(maxWidth: .infinity)
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
                viewModel?.updateEntries(entries)
            }
        }
        .onChange(of: entries) { _, newValue in
            viewModel?.updateEntries(newValue)
        }
        .onChange(of: viewModel?.error) { _, newError in
            if newError != nil {
                showErrorToast = true
                viewModel?.error = nil
            }
        }
        .toast(isPresented: $showErrorToast) {
            DSBanner(message: "Failed to add to Meal Plan", icon: "exclamationmark.triangle", style: .error)
        }
    }
}
