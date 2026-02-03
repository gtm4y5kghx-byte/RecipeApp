import SwiftUI
import SwiftData

struct MealPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.isIPad) private var isIPad
    @Query private var recipes: [Recipe]

    var selectedTab: Binding<MainView.Tab>?
    var menuState: AppMenuState?

    @State private var viewModel: MealPlanViewModel?
    @State private var selectedEntry: MealPlanEntry?
    @State private var showingGeneratePlan = false

    var body: some View {
        Group {
            if isIPad {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = MealPlanViewModel(modelContext: modelContext)
                viewModel?.loadEntries()
            } else if MealPlanViewModel.needsReload {
                viewModel?.loadEntries()
                MealPlanViewModel.needsReload = false
            }
            autoSelectFirstEntryIfNeeded()
        }
        .onChange(of: viewModel?.entries) { _, _ in
            autoSelectFirstEntryIfNeeded()
        }
    }

    // MARK: - iPhone Layout

    private var iPhoneLayout: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel {
                    if let error = viewModel.error {
                        loadErrorState(error, viewModel: viewModel)
                    } else {
                        calendarContent(viewModel: viewModel)
                    }
                } else {
                    DSLoadingSpinner(message: "Loading...")
                }
            }
            .navigationTitle("Meal Plan")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $selectedEntry) { entry in
                if let recipe = entry.recipe {
                    RecipeDetailView(
                        recipe: recipe,
                        onRemoveFromContext: {
                            viewModel?.removeEntry(entry)
                            selectedEntry = nil
                        }
                    )
                }
            }
        }
    }

    // MARK: - iPad Layout (3-column: Sidebar | Calendar | Detail)

    private var iPadLayout: some View {
        NavigationSplitView {
            RecipesMenuList(
                appSections: [.recipes, .mealPlan, .shoppingList],
                selectedAppSection: .mealPlan,
                onSelectAppSection: { tab in
                    selectedTab?.wrappedValue = tab
                },
                filterOptions: menuState?.filterOptions ?? [],
                tagOptions: menuState?.tagOptions ?? [],
                selectedOptionID: nil,
                onSelectOption: { optionId in
                    menuState?.selectOption(optionId)
                    selectedTab?.wrappedValue = .recipes
                },
                onNewRecipe: {
                    menuState?.newRecipe()
                },
                onSettings: {
                    menuState?.settings()
                }
            )
            .navigationTitle("Menu")
        } content: {
            Group {
                if let viewModel = viewModel {
                    if let error = viewModel.error {
                        loadErrorState(error, viewModel: viewModel)
                    } else {
                        calendarContent(viewModel: viewModel)
                    }
                } else {
                    DSLoadingSpinner(message: "Loading...")
                }
            }
            .navigationTitle("Meal Plan")
        } detail: {
            MealPlanDetailColumn(
                entry: selectedEntry,
                onRemove: {
                    if let entry = selectedEntry {
                        viewModel?.removeEntry(entry)
                        selectedEntry = nil
                    }
                }
            )
        }
    }

    private func autoSelectFirstEntryIfNeeded() {
        guard isIPad, selectedEntry == nil else { return }
        // Select first entry by date
        let sortedEntries = viewModel?.entries.sorted { $0.date < $1.date }
        selectedEntry = sortedEntries?.first
    }
    
    private func loadErrorState(_ error: MealPlanError, viewModel: MealPlanViewModel) -> some View {
        DSEmptyState(
            icon: "exclamationmark.triangle",
            title: error.title,
            message: error.message,
            actionTitle: "Try Again",
            action: {
                viewModel.error = nil
                viewModel.loadEntries()
            },
            accessibilityID: "meal-plan-error-state"
        )
    }

    private func calendarContent(viewModel: MealPlanViewModel) -> some View {
        ZStack(alignment: .bottomTrailing) {
            MealPlanCalendarContent(
                viewModel: viewModel,
                recipeToAdd: nil,
                onEntryTap: { entry in selectedEntry = entry },
                onRecipeAdded: nil
            )

            DSButton(
                title: "Generate",
                style: .primary,
                size: .small,
                icon: "sparkles",
                fullWidth: false
            ) {
                showingGeneratePlan = true
            }
            .padding()
            .accessibilityIdentifier("meal-plan-generate-button")
        }
        .sheet(isPresented: $showingGeneratePlan) {
            GeneratePlanSheet()
        }
    }
}

// MARK: - Detail Column

private struct MealPlanDetailColumn: View {
    let entry: MealPlanEntry?
    let onRemove: () -> Void

    var body: some View {
        if let entry = entry,
           let recipe = entry.recipe {
            RecipeDetailView(
                recipe: recipe,
                onRemoveFromContext: onRemove
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ContentUnavailableView("Select a Meal", systemImage: "fork.knife")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
