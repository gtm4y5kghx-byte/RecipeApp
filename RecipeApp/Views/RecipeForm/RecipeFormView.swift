import SwiftUI
import SwiftData

struct RecipeFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var allRecipes: [Recipe]
    
    @State private var viewModel: RecipeFormViewModel?
    @State private var showingDiscardConfirmation = false

    let recipe: Recipe?
    var onSave: ((Recipe) -> Void)?
    
    var body: some View {
        NavigationStack {
            if let viewModel = viewModel {
                @Bindable var viewModel = viewModel
                
                Form {
                    
                    RecipeFormImage(
                        selectedImageData: $viewModel.selectedImageData,
                        hasImage: viewModel.hasImage,
                        onRemove: { viewModel.removeImage() }
                    )
                    
                    
                    RecipeFormBasicInfo(
                        title: $viewModel.title,
                        servings: $viewModel.servings,
                        prepTime: $viewModel.prepTime,
                        cookTime: $viewModel.cookTime,
                        cuisine: $viewModel.cuisine
                    )
                    
                    RecipeFormTags(
                        tagInput: $viewModel.tagInput,
                        suggestions: viewModel.getTagSuggestions(allRecipes: allRecipes),
                        onSelectSuggestion: viewModel.applyTagSuggestion
                    )
                    
                    RecipeFormIngredients(
                        ingredients: $viewModel.ingredientFields,
                        onAdd: { viewModel.addIngredient() },
                        onRemove: { viewModel.removeIngredient(at: $0) }
                    )
                    
                    RecipeFormIntstructions(
                        instructions: $viewModel.instructionFields,
                        onAdd: { viewModel.addInstruction() },
                        onRemove: { viewModel.removeInstruction(at: $0) }
                    )
                    
                    RecipeFormNotes(
                        notes: $viewModel.notes
                    )

                    RecipeFormNutrition(
                        calories: $viewModel.calories,
                        protein: $viewModel.protein,
                        carbohydrates: $viewModel.carbohydrates,
                        fat: $viewModel.fat,
                        fiber: $viewModel.fiber,
                        sodium: $viewModel.sodium,
                        sugar: $viewModel.sugar
                    )
                }
                .navigationTitle(recipe == nil ? "New Recipe" : "Edit Recipe")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            if viewModel.formHasChanges {
                                showingDiscardConfirmation = true
                            } else {
                                dismiss()
                            }
                        }
                        .accessibilityIdentifier("recipe-form-cancel-button")
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            if let savedRecipe = viewModel.saveRecipe() {
                                HapticFeedback.success.trigger()
                                onSave?(savedRecipe)
                                dismiss()
                            } else {
                                HapticFeedback.error.trigger()
                            }
                        }
                        .disabled(viewModel.title.isEmpty)
                        .accessibilityIdentifier("recipe-form-save-button")
                    }
                }
                .alert(String(localized: "Discard Changes?"), isPresented: $showingDiscardConfirmation) {
                    Button(String(localized: "Discard"), role: .destructive) { dismiss() }
                    Button(String(localized: "Keep Editing"), role: .cancel) { }
                } message: {
                    Text(String(localized: "You have unsaved changes."))
                }
            } else {
                DSLoadingSpinner(message: "Loading...")
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = RecipeFormViewModel(
                    recipe: recipe,
                    importData: nil,
                    modelContext: modelContext
                )
            }
        }
    }
}

#Preview("Create Mode") {
    RecipeFormView(recipe: nil)
}

#Preview("Edit Mode") {
    RecipeFormView(recipe: SampleData.createApplePie())
}
