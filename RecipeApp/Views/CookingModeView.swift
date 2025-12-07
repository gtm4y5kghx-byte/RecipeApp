import SwiftUI

struct CookingModeView: View {
    let recipe: Recipe
    @Environment(\.dismiss) private var dismiss
    @State private var currentStepIndex = 0
    @State private var showReference = false
    
    private var currentStep: Step {
        recipe.instructions.sorted(by: { $0.order < $1.order })[currentStepIndex]
    }
    
    private var sortedSteps: [Step] {
        recipe.instructions.sorted(by: { $0.order < $1.order })
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress indicator
            Text("Step \(currentStepIndex + 1) of \(sortedSteps.count)")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            // Current step text (large and readable)
            ScrollView {
                Text(currentStep.instruction)
                    .font(.title2)
                    .padding()
            }
            
            Spacer()
            
            
            HStack(spacing: 20) {
                if currentStepIndex < sortedSteps.count - 1 {
                    // Not on final step - show navigation
                    Button("Previous") {
                        if currentStepIndex > 0 {
                            currentStepIndex -= 1
                        }
                    }
                    .disabled(currentStepIndex == 0)
                    
                    Button("Next") {
                        currentStepIndex += 1
                    }
                } else {
                    // Final step - show Mark as Cooked
                    Button("Mark as Cooked") {
                        markAsCooked()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
            .buttonStyle(.borderedProminent)
            .font(.title3)
        }
        .padding()
        .navigationTitle("Cooking: \(recipe.title)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Exit") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Reference") {
                    showReference.toggle()
                }
            }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .sheet(isPresented: $showReference) {
            NavigationStack {
                List {
                    Section("Ingredients") {
                        ForEach(recipe.ingredients.sorted(by: { $0.order < $1.order })) { ingredient in
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
                            showReference = false
                        }
                    }
                }
            }
        }
    }
    
    private func markAsCooked() {
        recipe.timesCooked += 1
        recipe.lastMade = Date()
        HapticFeedback.success.trigger()
        dismiss()
    }
}
