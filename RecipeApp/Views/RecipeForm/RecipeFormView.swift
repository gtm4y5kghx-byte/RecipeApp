import SwiftUI
import SwiftData

struct RecipeFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var allRecipes: [Recipe]
    
    @State private var viewModel: RecipeFormViewModel?
    @State private var showingDiscardConfirmation = false
    
    let recipe: Recipe?
    
    var body: some View {
        NavigationStack {
            if let viewModel = viewModel {
                @Bindable var viewModel = viewModel
                
                Form {
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
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            if viewModel.saveRecipe() {
                                dismiss()
                            }
                        }
                        .disabled(viewModel.title.isEmpty)
                    }
                }
                .alert("Discard Changes?", isPresented: $showingDiscardConfirmation) {
                    Button("Discard", role: .destructive) { dismiss() }
                    Button("Keep Editing", role: .cancel) { }
                } message: {
                    Text("You have unsaved changes.")
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
