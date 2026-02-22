import SwiftUI

struct MealPlanCalendarContent: View {
    @Bindable var viewModel: MealPlanViewModel

    let recipeToAdd: Recipe?
    let onEntryTap: ((MealPlanEntry) -> Void)?
    let onRecipeAdded: (() -> Void)?
    @Binding var scrollToTodayTrigger: Bool

    @State private var selectedDate: Date?
    @State private var selectedMealType: MealType?

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(viewModel.dateRange, id: \.self) { date in
                    Section {
                        let entries = viewModel.entries(for: date)
                        ForEach(entries) { entry in
                            MealPlanEntryRow(
                                entry: entry,
                                onTap: { onEntryTap?(entry) },
                                onRemove: { viewModel.removeEntry(entry) }
                            )
                        }
                    } header: {
                        dayHeader(date: date, isToday: Calendar.current.isDateInToday(date))
                    }
                    .id(date)
                }
            }
            .listStyle(.plain)
            .onAppear {
                proxy.scrollTo(viewModel.today, anchor: .top)
            }
            .onChange(of: scrollToTodayTrigger) { _, _ in
                withAnimation {
                    proxy.scrollTo(viewModel.today, anchor: .top)
                }
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

    // MARK: - Recipe Picker Binding

    private var showingRecipePicker: Binding<Bool> {
        Binding(
            get: { recipeToAdd == nil && selectedDate != nil && selectedMealType != nil },
            set: { if !$0 { selectedDate = nil; selectedMealType = nil } }
        )
    }

    // MARK: - Day Header

    private func dayHeader(date: Date, isToday: Bool) -> some View {
        HStack {
            DSLabel(
                date.formatted(.dateTime.weekday(.wide).month().day()),
                style: .headline,
                color: isToday ? .adaptiveBrand : .primary
            )
            Spacer()
            Menu {
                ForEach(MealType.allCases, id: \.self) { mealType in
                    Button(mealType.rawValue.capitalized) {
                        handleMealTypeSelected(date: date, mealType: mealType)
                    }
                }
            } label: {
                DSIcon("plus", size: .small, color: .adaptiveBrand)
            }
        }
    }

    // MARK: - Actions

    private func handleMealTypeSelected(date: Date, mealType: MealType) {
        if let recipe = recipeToAdd {
            viewModel.addEntry(date: date, mealType: mealType, recipe: recipe)
            MealPlanViewModel.needsReload = true
            onRecipeAdded?()
        } else {
            selectedDate = date
            selectedMealType = mealType
        }
    }
}
