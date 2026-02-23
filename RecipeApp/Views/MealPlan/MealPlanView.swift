import SwiftUI
import SwiftData

struct MealPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.isIPad) private var isIPad
    @Query(sort: \MealPlanEntry.date) private var entries: [MealPlanEntry]

    var selectedTab: Binding<MainView.Tab>?
    var menuState: AppMenuState?

    @State private var viewModel: MealPlanViewModel?
    @State private var selectedEntry: MealPlanEntry?
    @State private var showingGeneratePlan = false
    @State private var scrollToTodayTrigger = false
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn

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
                viewModel?.updateEntries(entries)
            }
            autoSelectFirstEntryIfNeeded()
        }
        .onChange(of: entries) { _, newValue in
            viewModel?.updateEntries(newValue)
            autoSelectFirstEntryIfNeeded()
            // Clear selected entry if its recipe was deleted
            if let selected = selectedEntry, selected.recipe == nil {
                selectedEntry = nil
            }
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
            .navigationTitle(MainView.Tab.mealPlan.title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Today") {
                        scrollToTodayTrigger.toggle()
                    }
                    .accessibilityIdentifier("meal-plan-today-button")
                }
            }
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
        NavigationSplitView(columnVisibility: $columnVisibility) {
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
            .navigationTitle(MainView.Tab.mealPlan.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Today") {
                        scrollToTodayTrigger.toggle()
                    }
                    .accessibilityIdentifier("meal-plan-today-button")
                }
            }
        } detail: {
            MealPlanDetailColumn(
                entry: selectedEntry,
                columnVisibility: $columnVisibility,
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
                viewModel.updateEntries(entries)
            },
            accessibilityID: "meal-plan-error-state"
        )
    }

    private func calendarContent(viewModel: MealPlanViewModel) -> some View {
        ZStack(alignment: .bottom) {
            MealPlanCalendarContent(
                viewModel: viewModel,
                recipeToAdd: nil,
                onEntryTap: { entry in selectedEntry = entry },
                onRecipeAdded: nil,
                scrollToTodayTrigger: $scrollToTodayTrigger
            )

            DSButton(
                title: "Create Meal Plan",
                style: .primary,
                icon: "sparkles"
            ) {
                showingGeneratePlan = true
            }
            .padding()
            .accessibilityIdentifier("meal-plan-generate-button")
        }
        .fullScreenCover(isPresented: $showingGeneratePlan) {
            GeneratePlanSheet()
        }
        .onChange(of: showingGeneratePlan) { _, isShowing in
            if !isShowing {
                viewModel.updateEntries(entries)
            }
        }
    }
}

// MARK: - Detail Column

private struct MealPlanDetailColumn: View {
    let entry: MealPlanEntry?
    var columnVisibility: Binding<NavigationSplitViewVisibility>
    let onRemove: () -> Void

    var body: some View {
        if let entry = entry,
           let recipe = entry.recipe {
            RecipeDetailView(
                recipe: recipe,
                onRemoveFromContext: onRemove,
                columnVisibility: columnVisibility
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ContentUnavailableView("Select a Meal", systemImage: "fork.knife")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
