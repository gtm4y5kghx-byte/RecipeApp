import SwiftUI
import SwiftData

struct MealPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.isIPad) private var isIPad
    @Query private var recipes: [Recipe]

    var selectedTab: Binding<MainView.Tab>?
    var menuState: AppMenuState?

    @State private var viewModel: MealPlanViewModel?
    @State private var selectedDate: Date?
    @State private var selectedMealType: MealType?
    @State private var selectedRecipe: Recipe?
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
                    calendarContent(viewModel: viewModel)
                } else {
                    DSLoadingSpinner(message: "Loading...")
                }
            }
            .navigationTitle("Meal Plan")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $selectedRecipe) { recipe in
                RecipeDetailView(recipe: recipe)
            }
        }
    }

    // MARK: - iPad Layout (3-column: Sidebar | Calendar | Detail)

    private var iPadLayout: some View {
        NavigationSplitView {
            RecipesMenuList(
                appSections: [.recipes, .discover, .mealPlan, .shoppingList],
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
                    calendarContent(viewModel: viewModel)
                } else {
                    DSLoadingSpinner(message: "Loading...")
                }
            }
            .navigationTitle("Meal Plan")
        } detail: {
            MealPlanDetailColumn(recipe: selectedRecipe)
        }
    }

    private func autoSelectFirstEntryIfNeeded() {
        guard isIPad, selectedRecipe == nil else { return }
        // Select recipe from first entry by date
        let sortedEntries = viewModel?.entries.sorted { $0.date < $1.date }
        selectedRecipe = sortedEntries?.first?.recipe
    }
    
    private var showingRecipePicker: Binding<Bool> {
        Binding(
            get: { selectedDate != nil && selectedMealType != nil },
            set: { if !$0 { selectedDate = nil; selectedMealType = nil } }
        )
    }
    
    private func calendarContent(viewModel: MealPlanViewModel) -> some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottomTrailing) {
                List {
                    ForEach(viewModel.dateRange, id: \.self) { date in
                        Section {
                            let entries = viewModel.entries(for: date)
                            if entries.isEmpty {
                                Text("No meals planned")
                                    .font(Theme.Typography.subheadline)
                                    .foregroundStyle(Theme.Colors.textTertiary)
                            } else {
                                ForEach(entries) { entry in
                                    MealPlanEntryRow(
                                        entry: entry,
                                        onTap: { selectedRecipe = entry.recipe },
                                        onRemove: { viewModel.removeEntry(entry) }
                                    )
                                }
                            }
                        } header: {
                            dayHeader(date: date, isToday: Calendar.current.isDateInToday(date))
                        }
                        .id(date)
                    }
                }
                .listStyle(.plain)

                VStack(spacing: Theme.Spacing.sm) {
                    DSButton(
                        title: "Generate",
                        style: .primary,
                        size: .small,
                        icon: "sparkles",
                        fullWidth: false
                    ) {
                        showingGeneratePlan = true
                    }
                    .accessibilityIdentifier("meal-plan-generate-button")

                    DSButton(
                        title: "Today",
                        style: .secondary,
                        size: .small,
                        icon: "calendar",
                        fullWidth: false
                    ) {
                        withAnimation {
                            proxy.scrollTo(viewModel.today, anchor: .top)
                        }
                    }
                    .accessibilityIdentifier("meal-plan-today-button")
                }
                .padding()
            }
            .onAppear {
                proxy.scrollTo(viewModel.today, anchor: .top)
            }
            .sheet(isPresented: showingRecipePicker) {
                RecipePickerSheet { recipe in
                    if let date = selectedDate, let mealType = selectedMealType {
                        viewModel.addEntry(date: date, mealType: mealType, recipe: recipe)
                    }
                }
            }
            .sheet(isPresented: $showingGeneratePlan) {
                GeneratePlanSheet()
            }
        }
    }

    private func dayHeader(date: Date, isToday: Bool) -> some View {
        HStack {
            DSLabel(
                date.formatted(.dateTime.weekday(.wide).month().day()),
                style: .headline,
                color: isToday ? .accent : .primary
            )
            Spacer()
            Menu {
                ForEach(MealType.allCases, id: \.self) { mealType in
                    Button(mealType.rawValue.capitalized) {
                        selectedDate = date
                        selectedMealType = mealType
                    }
                }
            } label: {
                Label("Add", systemImage: "plus")
                    .font(Theme.Typography.subheadline)
            }
        }
    }
}

// MARK: - Detail Column

private struct MealPlanDetailColumn: View {
    let recipe: Recipe?

    var body: some View {
        if let recipe = recipe {
            RecipeDetailView(recipe: recipe)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ContentUnavailableView("Select a Meal", systemImage: "fork.knife")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
