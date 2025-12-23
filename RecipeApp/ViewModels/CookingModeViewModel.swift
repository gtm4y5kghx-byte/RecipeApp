import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
class CookingModeViewModel {
    var currentStepIndex: Int = 0

    private let recipe: Recipe
    private let modelContext: ModelContext

    init(recipe: Recipe, modelContext: ModelContext) {
        self.recipe = recipe
        self.modelContext = modelContext
    }
    
    struct StepItem: Identifiable {
        let id: Int
        let step: Step
        var label: String { "Step \(id + 1) of \(totalSteps)" }
        let totalSteps: Int
    }

    // MARK: - Computed Properties
    
    var currentStep: Step {
        sortedSteps[currentStepIndex]
    }

    var sortedSteps: [Step] {
        recipe.sortedInstructions
    }

    var progressText: String {
        "Step \(currentStepIndex + 1) of \(sortedSteps.count)"
    }
    
    var stepItems: [StepItem] {
        sortedSteps.enumerated().map { index, step in
            StepItem(id: index, step: step, totalSteps: sortedSteps.count)
        }
    }


    var isOnFinalStep: Bool {
        currentStepIndex == sortedSteps.count - 1
    }
    
    var ingredients: [Ingredient] {
         recipe.sortedIngredients
     }

     var recipeTitle: String {
         recipe.title
     }

    // MARK: - Navigation Actions

    func jumpToStep(_ index: Int) {
        currentStepIndex = max(0, min(index, sortedSteps.count - 1))
    }

    // MARK: - Mark as Cooked

    func markAsCooked() -> Bool {
        recipe.timesCooked += 1
        recipe.lastMade = Date()

        do {
            try modelContext.save()
            return true
        } catch {
            return false
        }
    }
}
