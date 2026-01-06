import SwiftUI

struct MealPlanDayRow: View {
    let date: Date
    let entries: [MealPlanEntry]
    let onAddTapped: (MealType) -> Void
    let onEntryTapped: (MealPlanEntry) -> Void
    let onRemoveEntry: (MealPlanEntry) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                dateHeader
                Spacer()
                Menu {
                    ForEach(MealType.allCases, id: \.self) { mealType in
                        Button(mealType.rawValue.capitalized) {
                            onAddTapped(mealType)
                        }
                    }
                } label: {
                    Label("Add", systemImage: "plus")
                        .font(Theme.Typography.subheadline)
                }
            }
            
            ForEach(MealType.allCases, id: \.self) { mealType in
                mealSlot(for: mealType)
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.md)
    }
    
    private var dateHeader: some View {
        DSLabel(
            date.formatted(.dateTime.weekday(.wide).month().day()),
            style: .headline,
            color: isToday ? .accent : .primary
        )
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private func mealSlot(for mealType: MealType) -> some View {
        let slotEntries = entries.filter { $0.mealType == mealType }
        
        if slotEntries.isEmpty {
            return AnyView(EmptyView())
        }
        
        return AnyView(
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                ForEach(slotEntries) { entry in
                    MealPlanEntryRow(
                        entry: entry,
                        onTap: { onEntryTapped(entry) },
                        onRemove: { onRemoveEntry(entry) }
                    )
                }
            }
        )
    }
}
