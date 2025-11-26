import SwiftUI
import SwiftData

struct RecipeTransformationView: View {
    let recipe: Recipe
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var transformationPrompt = ""
    @State private var isProcessing = false
    @State private var error: Error?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("How would you like to transform this recipe?")
                    .font(.headline)
                    .padding(.top)
                
                TextField("E.g., Make it vegan, Double the recipe, Convert to air fryer", text: $transformationPrompt, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Transform Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Transform") {
                        transformRecipe()
                    }
                    .disabled(transformationPrompt.isEmpty)
                }
            }
        }
        .overlay {
            if isProcessing {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        
                        Text("Transforming recipe...")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    .padding(32)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
            }
        }
        .errorAlert($error)
    }
    
    private func transformRecipe() {
        isProcessing = true
        
        Task {
            do {
                let service = FoundationModelsService()
                let transformation = try await service.transformRecipe(recipe: recipe, transformation: transformationPrompt)
                
                await MainActor.run {
                    createVariation(from: transformation)
                    isProcessing = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    isProcessing = false
                }
            }
        }
    }
    
    private func createVariation(from transformation: RecipeTransformation) {
        let variation = Recipe(title: transformation.title, sourceType: recipe.sourceType)
        
        variation.parentRecipeID = recipe.id
        variation.variationNote = transformation.variationNote
        
        variation.servings = transformation.servings
        variation.prepTime = transformation.prepTime
        variation.cookTime = transformation.cookTime
        variation.cuisine = transformation.cuisine
        variation.notes = transformation.notes
        
        if let prep = transformation.prepTime, let cook = transformation.cookTime {
            variation.totalTime = prep + cook
        }
        
        variation.ingredients = transformation.ingredients.enumerated().map { index, transformedIngredient in
            let ingredient = Ingredient(
                quantity: "",
                unit: nil,
                item: transformedIngredient.text,
                preparation: nil,
                section: nil
            )
            ingredient.order = index
            return ingredient
        }
        
        variation.instructions = transformation.instructions.enumerated().map { index, transformedInstruction in
            let step = Step(instruction: transformedInstruction.text)
            step.order = index
            return step
        }
        
        modelContext.insert(variation)
        
        do {
            try modelContext.save()
            HapticFeedback.success.trigger()
        } catch {
            self.error = error
        }
    }
}
