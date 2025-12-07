import SwiftUI
import SwiftData

struct InstructionRowView: View {
    @Binding var instruction: String
    let index: Int
    let canDelete: Bool
    let onDelete: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            Text("\(index + 1).")
                .foregroundStyle(.secondary)
                .padding(.top, 8)
            
            TextEditor(text: $instruction)
                .frame(minHeight: 60)
                .scrollContentBackground(.hidden)
            
            Button(action: onDelete) {
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(.red)
            }
            .disabled(!canDelete)
            .padding(.top, 8)
        }
    }
}

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
    
    var tagSuggestions: [(String, Int)] {
        // Get the current tag being typed (after last comma)
        let currentTag = tagInput
            .split(separator: ",")
            .last?
            .trimmingCharacters(in: .whitespaces)
            .lowercased() ?? ""

        // Only show suggestions if actively typing (current tag is not empty but incomplete)
        guard !currentTag.isEmpty else { return [] }

        let allTags = allRecipes.flatMap { $0.userTags }
        let tagCounts = Dictionary(grouping: allTags, by: { $0.lowercased() })
            .mapValues { $0.count }

        let filtered = tagCounts.filter { tag, _ in
            tag.contains(currentTag) && tag != currentTag
        }

        return filtered
            .map { ($0.key, $0.value) }
            .sorted { $0.1 > $1.1 }
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
        if recipe == nil {
            return !title.isEmpty ||
            ingredientFields.contains(where: { !$0.isEmpty }) ||
            instructionFields.contains(where: { !$0.isEmpty }) ||
            !servings.isEmpty || !prepTime.isEmpty || !cookTime.isEmpty || !cuisine.isEmpty || !notes.isEmpty
        }
        
        guard let recipe = recipe else { return false }
        
        let ingredientsChanged = ingredientFields != recipe.ingredients.sorted(by: { $0.order < $1.order}).map { $0.item }
        let instructionsChanged = instructionFields != recipe.instructions.sorted(by: { $0.order < $1.order}).map { $0.instruction }
        
        
        return title != recipe.title ||
        servings != (recipe.servings.map { String($0) } ?? "") ||
        prepTime != (recipe.prepTime.map { String($0) } ?? "") ||
        cookTime != (recipe.cookTime.map { String($0) } ?? "") ||
        cuisine != (recipe.cuisine ?? "") ||
        notes != (recipe.notes ?? "") ||
        ingredientsChanged ||
        instructionsChanged
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
                
                Section("Tags") {
                    TextField("Add tags (comma-separated)...", text: $tagInput)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    // Autocomplete suggestions
                    if !tagInput.isEmpty && !tagSuggestions.isEmpty {
                        ForEach(tagSuggestions.prefix(5), id: \.0) { tag, count in
                            Button(action: {
                                // Get existing tags (excluding the one being typed)
                                var tags = tagInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces).lowercased() }

                                // Check if tag already exists (excluding the last incomplete one)
                                let existingTags = tags.dropLast()
                                if existingTags.contains(tag.lowercased()) {
                                    // Tag already exists - just remove the incomplete input
                                    tags = Array(tags.dropLast())
                                } else {
                                    // Tag doesn't exist - replace incomplete tag with selected suggestion
                                    if !tags.isEmpty {
                                        tags[tags.count - 1] = tag.lowercased()
                                    } else {
                                        tags.append(tag.lowercased())
                                    }
                                }

                                tagInput = tags.joined(separator: ", ")
                            }) {
                                HStack {
                                    Text(tag)
                                    Spacer()
                                    Text("\(count)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                
                Section("Ingredients") {
                    ForEach(ingredientFields.indices, id: \.self) { index in
                        HStack {
                            TextField("e.g., 2 cups flour", text: $ingredientFields[index])
                            
                            Button(action: {
                                ingredientFields.remove(at: index)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red)
                            }
                            .disabled(ingredientFields.count == 1)
                        }
                    }
                    .onMove {source, destination in
                        ingredientFields.move(fromOffsets: source, toOffset: destination)
                    }
                    
                    Button(action: {
                        ingredientFields.append("")
                    }) {
                        Label("Add Ingredient", systemImage: "plus.circle.fill")
                    }
                }
                
                Section("Instructions") {
                    ForEach(instructionFields.indices, id: \.self) { index in
                        InstructionRowView(
                            instruction: $instructionFields[index],
                            index: index,
                            canDelete: instructionFields.count > 1,
                            onDelete: {
                                instructionFields.remove(at: index)
                            }
                        )
                    }
                    .onMove {source, destination in
                        instructionFields.move(fromOffsets: source, toOffset: destination)
                    }
                    
                    Button(action: {
                        instructionFields.append("")
                    }) {
                        Label("Add Step", systemImage: "plus.circle.fill")
                    }
                }
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
