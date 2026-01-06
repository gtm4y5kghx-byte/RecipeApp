import SwiftUI
import SwiftData

struct MealPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var recipes: [Recipe]
    @State private var viewModel: MealPlanViewModel?
    
    @State private var selectedDate: Date?
    @State private var selectedMealType: MealType?
    @State private var selectedRecipe: Recipe?
    
    var body: some View {
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
        .onAppear {
            if viewModel == nil {
                viewModel = MealPlanViewModel(modelContext: modelContext)
                viewModel?.loadEntries()
            }
        }
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
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.dateRange, id: \.self) { date in
                            MealPlanDayRow(
                                date: date,
                                entries: viewModel.entries(for: date),
                                onAddTapped: { mealType in
                                    selectedDate = date
                                    selectedMealType = mealType
                                },
                                onEntryTapped: { entry in
                                    selectedRecipe = entry.recipe
                                },
                                onRemoveEntry: { entry in
                                    viewModel.removeEntry(entry)
                                }
                            )
                            .id(date)
                        }
                    }
                }

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
        }
    }
}
