import SwiftUI

struct MealPlanEntryRow: View {
    let entry: MealPlanEntry
    let onTap: () -> Void
    let onRemove: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: mealTypeIcon)
                    .foregroundStyle(Theme.Colors.textSecondary)

                DSLabel(entry.recipe?.title ?? "Unknown Recipe", style: .body)

                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onRemove()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .accessibilityIdentifier("meal-plan-entry-\(entry.id)")
    }

     private var mealTypeIcon: String {
         switch entry.mealType {
         case .breakfast: return "sunrise"
         case .lunch: return "sun.max"
         case .dinner: return "moon.stars"
         }
     }
 }
