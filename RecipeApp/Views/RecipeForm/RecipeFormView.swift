import SwiftUI
import SwiftData

struct RecipeFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allRecipes: [Recipe]

    @State private var editMode: EditMode = .active
    @State private var showCancelAlert = false
    @State private var viewModel: RecipeFormViewModel

    let recipe: Recipe?
    let importData: RecipeImportData?

    init(recipe: Recipe? = nil, importData: RecipeImportData? = nil) {
        self.recipe = recipe
        self.importData = importData

        _viewModel = State(initialValue: RecipeFormViewModel(
            recipe: recipe,
            importData: importData,
            modelContext: ModelContext(try! ModelContainer(for: Recipe.self))
        ))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Recipe Details") {
                    TextField("Title", text: $viewModel.title)
                        .accessibilityIdentifier("recipe-title-field")
                }

                Section("Optional Details") {
                    HStack {
                        Text("Servings")
                        TextField("8", text: $viewModel.servings)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .accessibilityIdentifier("recipe-servings-field")
                    }

                    HStack {
                        Text("Prep Time(min)")
                        TextField("20", text: $viewModel.prepTime)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .accessibilityIdentifier("recipe-prep-time-field")
                    }

                    HStack {
                        Text("Cook Time (min)")
                        TextField("45", text: $viewModel.cookTime)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .accessibilityIdentifier("recipe-cook-time-field")
                    }

                    TextField("Cuisine", text: $viewModel.cuisine)
                        .textInputAutocapitalization(.words)
                        .accessibilityIdentifier("recipe-cuisine-field")
                }

                Section("Notes") {
                    TextEditor(text: $viewModel.notes)
                        .frame(minHeight: 100)
                        .accessibilityIdentifier("recipe-notes-editor")
                }

                RecipeFormTagSection(
                    tagInput: $viewModel.tagInput,
                    tagSuggestions: viewModel.getTagSuggestions(allRecipes: allRecipes)
                )

                RecipeFormIngredientsSection(ingredientFields: $viewModel.ingredientFields)

                RecipeFormInstructionsSection(instructionFields: $viewModel.instructionFields)
            }
            .environment(\.editMode, $editMode)
            .navigationTitle(recipe == nil ? "New Recipe" : "Edit Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if viewModel.formHasChanges {
                            showCancelAlert = true
                        } else {
                            dismiss()
                        }
                    }
                    .accessibilityIdentifier("recipe-form-cancel-button")
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.saveRecipe() {
                            HapticFeedback.success.trigger()
                            dismiss()
                        }
                    }
                    .disabled(viewModel.title.isEmpty)
                    .accessibilityIdentifier("recipe-form-save-button")
                }

            }
        }
        .onAppear {
            viewModel = RecipeFormViewModel(
                recipe: recipe,
                importData: importData,
                modelContext: modelContext
            )
        }
        .alert("Discard Changes?", isPresented: $showCancelAlert) {
            Button("Keep Editing", role: .cancel) { }
            Button("Discard", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("You have unsaved changes. Are you sure you want to discard them?")
        }
        .errorAlert($viewModel.error)
    }
}
