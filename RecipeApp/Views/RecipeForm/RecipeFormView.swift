import SwiftUI
import SwiftData

struct RecipeFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allRecipes: [Recipe]

    @State private var title = ""
    @State private var servings = ""
    @State private var prepTime = ""
    @State private var cookTime = ""
    @State private var cuisine = ""
    @State private var notes = ""
    @State private var ingredientFields: [String] = [""]
    @State private var instructionFields: [String] = [""]
    @State private var editMode: EditMode = .active
    @State private var showCancelAlert = false
    @State private var hasUnsavedChanges = false
    @State private var error: Error?

    @State private var tagInput = ""

    private var viewModel: RecipeFormViewModel {
        RecipeFormViewModel(
            recipe: recipe,
            title: title,
            ingredientFields: ingredientFields,
            instructionFields: instructionFields,
            servings: servings,
            prepTime: prepTime,
            cookTime: cookTime,
            cuisine: cuisine,
            notes: notes
        )
    }

    var tagSuggestions: [(String, Int)] {
        viewModel.getTagSuggestions(tagInput: tagInput, allRecipes: allRecipes)
    }
    
    
    let recipe: Recipe?
    let importData: RecipeImportData?
    
    init(recipe: Recipe? = nil, importData: RecipeImportData? = nil) {
        self.recipe = recipe
        self.importData = importData
        
        if let recipe = recipe {
            _title = State(initialValue: recipe.title)
            _servings = State(initialValue: recipe.servings.map { String($0)} ?? "")
            _prepTime = State(initialValue: recipe.prepTime.map { String($0)} ?? "")
            _cookTime = State(initialValue: recipe.cookTime.map { String($0)} ?? "")
            _cuisine = State(initialValue: recipe.cuisine ?? "")
            _notes = State(initialValue: recipe.notes ?? "")
            
            let sortedIngredients = recipe.sortedIngredients
            let ingredientTexts = sortedIngredients.map { $0.item }
            _ingredientFields = State(initialValue: ingredientTexts.isEmpty ? [""] : ingredientTexts )
            
            let sortedInstructions = recipe.sortedInstructions
            let instructionTexts = sortedInstructions.map { $0.instruction }
            _instructionFields = State(initialValue: instructionTexts.isEmpty ? [""] : instructionTexts )
            
            _tagInput = State(initialValue: recipe.userTags.joined(separator: ", "))
        } else if let importData = importData {
            _title = State(initialValue: importData.title)
            _servings = State(initialValue: importData.servings.map { String($0) } ?? "")
            _prepTime = State(initialValue: importData.prepTime.map { String($0) } ?? "")
            _cookTime = State(initialValue: importData.cookTime.map { String($0) } ?? "")
            _cuisine = State(initialValue: importData.cuisine ?? "")
            _notes = State(initialValue: importData.description ?? "")
            
            _ingredientFields = State(initialValue: importData.ingredients.isEmpty ? [""] : importData.ingredients)
            _instructionFields = State(initialValue: importData.instructions.isEmpty ? [""] : importData.instructions)
        }
    }
    
    private var formHasChanges: Bool {
        viewModel.formHasChanges
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Recipe Details") {
                    TextField("Title", text: $title)
                }
                
                Section("Optional Details") {
                    HStack {
                        Text("Servings")
                        TextField("8", text: $servings)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Prep Time(min)")
                        TextField("20", text: $prepTime)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Cook Time (min)")
                        TextField("45", text: $cookTime)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    TextField("Cuisine", text: $cuisine)
                        .textInputAutocapitalization(.words)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                RecipeFormTagSection(
                    tagInput: $tagInput,
                    tagSuggestions: tagSuggestions
                )

                RecipeFormIngredientsSection(ingredientFields: $ingredientFields)

                RecipeFormInstructionsSection(instructionFields: $instructionFields)
            }
            .environment(\.editMode, $editMode)
            .navigationTitle(recipe == nil ? "New Recipe" : "Edit Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if formHasChanges {
                            showCancelAlert = true
                        } else {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRecipe()
                    }
                    .disabled(title.isEmpty)
                }
                
            }
        }
        .alert("Discard Changes?", isPresented: $showCancelAlert) {
            Button("Keep Editing", role: .cancel) { }
            Button("Discard", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("You have unsaved changes. Are you sure you want to discard them?")
        }
        .errorAlert($error)
    }
    
    private func saveRecipe() {
        let recipeToSave: Recipe
        
        if let providedRecipe = recipe {
            recipeToSave = providedRecipe
            if providedRecipe.modelContext == nil {
                modelContext.insert(recipeToSave)
            }
        } else {
            recipeToSave = Recipe(
                title: title,
                sourceType: importData != nil ? .web_imported : .manual,
            )
            
            if let sourceURL = importData?.sourceURL {
                recipeToSave.sourceURL = sourceURL
            }
            
            modelContext.insert(recipeToSave)
        }
        
        recipeToSave.title = title
        recipeToSave.notes = notes.isEmpty ? nil : notes
        recipeToSave.cuisine = cuisine.isEmpty ? nil : cuisine
        
        recipeToSave.servings = Int(servings)
        recipeToSave.prepTime = Int(prepTime)
        recipeToSave.cookTime = Int(cookTime)
        let parsedTags = tagInput
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            .filter { !$0.isEmpty }
        recipeToSave.userTags = parsedTags
        
        recipeToSave.ingredients.removeAll()
        recipeToSave.instructions.removeAll()
        
        let nonEmptyIngredients = ingredientFields.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        for (index, ingredientText) in nonEmptyIngredients.enumerated() {
            let ingredient = Ingredient(quantity: "", unit: nil, item: ingredientText, preparation: nil, section: nil)
            ingredient.order = index
            recipeToSave.ingredients.append(ingredient)
        }
        
        let nonEmptyInstructions = instructionFields.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        for (index, instructionText) in nonEmptyInstructions.enumerated() {
            let step = Step(instruction: instructionText)
            step.order = index
            recipeToSave.instructions.append(step)
        }
        
        recipeToSave.lastModified = Date()
        
        do {
            try modelContext.save()
            
            if importData != nil {
                try? SharedDataManager.shared.deletePendingImport()
            }
            
            HapticFeedback.success.trigger()
            dismiss()
        } catch let saveError {
            error = saveError
        }
    }
}
