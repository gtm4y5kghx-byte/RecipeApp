import SwiftUI

struct CookingReferenceSheet: View {
    let recipe: Recipe
    let sortedSteps: [Step]
    let currentStepIndex: Int
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            List {
                Section("Ingredients") {
                    ForEach(recipe.sortedIngredients) { ingredient in
                        Text(IngredientFormatter.format(ingredient))
                    }
                }

                Section {
                    DisclosureGroup("All Steps (\(sortedSteps.count))") {
                        ForEach(Array(sortedSteps.enumerated()), id: \.element.id) { index, step in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1).")
                                    .fontWeight(index == currentStepIndex ? .bold : .regular)

                                Text(step.instruction)

                                if index == currentStepIndex {
                                    Spacer()
                                    Image(systemName: "arrow.left.circle.fill")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Quick Reference")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
