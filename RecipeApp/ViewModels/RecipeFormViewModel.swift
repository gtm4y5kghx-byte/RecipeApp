import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
class RecipeFormViewModel {
    
    // MARK: - Form Fields

    var title: String = ""
    var servings: String = ""
    var prepTime: String = ""
    var cookTime: String = ""
    var cuisine: String = ""
    var notes: String = ""
    var ingredientFields: [String] = [""]
    var instructionFields: [String] = [""]
    var tagInput: String = ""
    var selectedImageData: Data?
    var error: Error?

    // MARK: - Nutrition fields
    var calories: String = ""
    var protein: String = ""
    var carbohydrates: String = ""
    var fat: String = ""
    var fiber: String = ""
    var sodium: String = ""
    var sugar: String = ""
    
    // MARK: - Private Properties
    
    private let recipe: Recipe?
    private let modelContext: ModelContext
    private let importData: RecipeImportData?
    private var imageRemoved: Bool = false
    private var originalHasImage: Bool = false
    
    // MARK: - Initialization
    
    init(recipe: Recipe?, importData: RecipeImportData?, modelContext: ModelContext) {
        self.recipe = recipe
        self.importData = importData
        self.modelContext = modelContext
        
        if let recipe = recipe {
            populateFromRecipe(recipe)
        } else if let importData = importData {
            populateFromImportData(importData)
        }
    }
    
    // MARK: - Computed Properties
    
    var hasImage: Bool {
        selectedImageData != nil || (originalHasImage && !imageRemoved)
    }
    
    var formHasChanges: Bool {
        if recipe == nil {
            return !title.isEmpty ||
            ingredientFields.contains(where: { !$0.isEmpty }) ||
            instructionFields.contains(where: { !$0.isEmpty }) ||
            !servings.isEmpty ||
            !prepTime.isEmpty ||
            !cookTime.isEmpty ||
            !cuisine.isEmpty ||
            !notes.isEmpty ||
            !tagInput.isEmpty ||
            selectedImageData != nil
        }
        
        guard let recipe = recipe else { return false }
        
        let ingredientsChanged = ingredientFields != recipe.sortedIngredients.map { $0.item }
        let instructionsChanged = instructionFields != recipe.sortedInstructions.map { $0.instruction }
        let tagsChanged = tagInput != recipe.userTags.joined(separator: ", ")
        let imageChanged = selectedImageData != nil || imageRemoved
        
        return title != recipe.title ||
        servings != (recipe.servings.map { String($0) } ?? "") ||
        prepTime != (recipe.prepTime.map { String($0) } ?? "") ||
        cookTime != (recipe.cookTime.map { String($0) } ?? "") ||
        cuisine != (recipe.cuisine ?? "") ||
        notes != (recipe.notes ?? "") ||
        ingredientsChanged ||
        instructionsChanged ||
        tagsChanged ||
        imageChanged
    }
    
    // MARK: - Ingredient Management
    
    func addIngredient() {
        ingredientFields.append("")
    }
    
    func removeIngredient(at index: Int) {
        ingredientFields.remove(at: index)
    }
    
    // MARK: - Instruction Management
    
    func addInstruction() {
        instructionFields.append("")
    }
    
    func removeInstruction(at index: Int) {
        instructionFields.remove(at: index)
    }
    
    // MARK: - Tag Management

    private let maxTagSuggestions = 6

    func getTagSuggestions(allRecipes: [Recipe]) -> [(String, Int)] {
        let currentTag = tagInput
            .split(separator: ",")
            .last?
            .trimmingCharacters(in: .whitespaces)
            .lowercased() ?? ""

        // Hide suggestions after selecting a tag (input ends with ", ")
        // Show only when: empty input (discovery) or actively typing a partial
        if currentTag.isEmpty && !tagInput.isEmpty {
            return []
        }

        // Tags already entered (to exclude from suggestions)
        let enteredTags = Set(
            tagInput
                .split(separator: ",")
                .dropLast()  // Don't exclude the partial being typed
                .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
        )

        let allTags = allRecipes.flatMap { $0.userTags }
        let tagCounts = Dictionary(grouping: allTags, by: { $0.lowercased() })
            .mapValues { $0.count }
            .filter { !enteredTags.contains($0.key) }  // Exclude already entered

        let results: [(String, Int)]

        if currentTag.isEmpty {
            // No input at all - return top tags by count (discovery mode)
            results = tagCounts
                .map { ($0.key, $0.value) }
                .sorted { $0.1 > $1.1 }
        } else {
            // Has partial - prioritize prefix matches over contains matches
            let prefixMatches = tagCounts.filter { tag, _ in
                tag.hasPrefix(currentTag) && tag != currentTag
            }
            let containsMatches = tagCounts.filter { tag, _ in
                tag.contains(currentTag) && !tag.hasPrefix(currentTag) && tag != currentTag
            }

            let sortedPrefix = prefixMatches.map { ($0.key, $0.value) }.sorted { $0.1 > $1.1 }
            let sortedContains = containsMatches.map { ($0.key, $0.value) }.sorted { $0.1 > $1.1 }

            results = sortedPrefix + sortedContains
        }

        return Array(results.prefix(maxTagSuggestions))
    }
    
    func applyTagSuggestion(_ tag: String) {
        var tags = tagInput.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
        if !tags.isEmpty { tags.removeLast() }
        tags.append(tag)
        tagInput = tags.joined(separator: ", ") + ", "
    }
    
    // MARK: - Image Management
    
    func setImage(_ data: Data?) {
        selectedImageData = data
        imageRemoved = false
    }
    
    func removeImage() {
        selectedImageData = nil
        imageRemoved = true
    }
    
    private func saveImageToDisk(_ data: Data) -> String? {
        let fileManager = FileManager.default
        
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let imagesDirectory = documentsURL.appendingPathComponent("recipe-images")
        
        try? fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        
        let filename = UUID().uuidString + ".jpg"
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            return fileURL.absoluteString
        } catch {
            return nil
        }
    }
    
    private func updateRecipeImage(_ recipe: Recipe) {
        if let imageData = selectedImageData {
            deleteImageFromDisk(recipe.imageURL)
            recipe.imageURL = saveImageToDisk(imageData)
        } else if imageRemoved {
            deleteImageFromDisk(recipe.imageURL)
            recipe.imageURL = nil
        }
    }
    
    private func deleteImageFromDisk(_ urlString: String?) {
        guard let urlString = urlString,
              let url = URL(string: urlString) else { return }
        try? FileManager.default.removeItem(at: url)
    }
    
    // MARK: - Save Recipe
    
    func saveRecipe() -> Recipe? {
        let recipeToSave: Recipe

        if let existingRecipe = recipe {
            recipeToSave = existingRecipe
        } else {
            recipeToSave = createNewRecipe()
            modelContext.insert(recipeToSave)
        }

        updateRecipeProperties(recipeToSave)
        updateRecipeTags(recipeToSave)
        updateRecipeIngredients(recipeToSave)
        updateRecipeInstructions(recipeToSave)
        updateRecipeImage(recipeToSave)
        updateRecipeNutrition(recipeToSave)

        return saveToContext() ? recipeToSave : nil
    }
    
    // MARK: - Private Helpers (Population)
    
    private func populateFromRecipe(_ recipe: Recipe) {
        self.title = recipe.title
        self.servings = recipe.servings.map { String($0) } ?? ""
        self.prepTime = recipe.prepTime.map { String($0) } ?? ""
        self.cookTime = recipe.cookTime.map { String($0) } ?? ""
        self.cuisine = recipe.cuisine ?? ""
        self.notes = recipe.notes ?? ""

        let ingredientTexts = recipe.sortedIngredients.map { $0.item }
        self.ingredientFields = ingredientTexts.isEmpty ? [""] : ingredientTexts

        let instructionTexts = recipe.sortedInstructions.map { $0.instruction }
        self.instructionFields = instructionTexts.isEmpty ? [""] : instructionTexts

        self.tagInput = recipe.userTags.joined(separator: ", ")
        self.originalHasImage = recipe.imageURL != nil

        if let nutrition = recipe.nutrition {
            self.calories = nutrition.calories.map { String($0) } ?? ""
            self.protein = nutrition.protein.map { String(Int($0)) } ?? ""
            self.carbohydrates = nutrition.carbohydrates.map { String(Int($0)) } ?? ""
            self.fat = nutrition.fat.map { String(Int($0)) } ?? ""
            self.fiber = nutrition.fiber.map { String(Int($0)) } ?? ""
            self.sodium = nutrition.sodium.map { String(Int($0)) } ?? ""
            self.sugar = nutrition.sugar.map { String(Int($0)) } ?? ""
        }
    }
    
    private func populateFromImportData(_ importData: RecipeImportData) {
        self.title = importData.title
        self.servings = importData.servings.map { String($0) } ?? ""
        self.prepTime = importData.prepTime.map { String($0) } ?? ""
        self.cookTime = importData.cookTime.map { String($0) } ?? ""
        self.cuisine = importData.cuisine ?? ""
        self.notes = importData.description ?? ""
        
        self.ingredientFields = importData.ingredients.isEmpty ? [""] : importData.ingredients
        self.instructionFields = importData.instructions.isEmpty ? [""] : importData.instructions
    }
    
    // MARK: - Private Helpers (Save)
    
    private func createNewRecipe() -> Recipe {
        let newRecipe = Recipe(
            title: title,
            sourceType: importData != nil ? .web_imported : .manual
        )
        
        if let sourceURL = importData?.sourceURL {
            newRecipe.sourceURL = sourceURL
        }
        
        return newRecipe
    }
    
    private func updateRecipeProperties(_ recipe: Recipe) {
        recipe.title = title
        recipe.notes = notes.isEmpty ? nil : notes
        recipe.cuisine = cuisine.isEmpty ? nil : cuisine
        recipe.servings = Int(servings)
        recipe.prepTime = Int(prepTime)
        recipe.cookTime = Int(cookTime)
        recipe.lastModified = Date()
    }
    
    private func updateRecipeTags(_ recipe: Recipe) {
        let parsedTags = tagInput
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            .filter { !$0.isEmpty }
        recipe.userTags = parsedTags
    }
    
    private func updateRecipeIngredients(_ recipe: Recipe) {
        recipe.ingredients.removeAll()
        
        let nonEmptyIngredients = ingredientFields.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        for (index, ingredientText) in nonEmptyIngredients.enumerated() {
            let ingredient = Ingredient(quantity: "", unit: nil, item: ingredientText, preparation: nil, section: nil)
            ingredient.order = index
            recipe.ingredients.append(ingredient)
        }
    }
    
    private func updateRecipeInstructions(_ recipe: Recipe) {
        recipe.instructions.removeAll()

        let nonEmptyInstructions = instructionFields.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        for (index, instructionText) in nonEmptyInstructions.enumerated() {
            let step = Step(instruction: instructionText)
            step.order = index
            recipe.instructions.append(step)
        }
    }

    private func updateRecipeNutrition(_ recipe: Recipe) {
        let hasAnyNutrition = !calories.isEmpty || !protein.isEmpty || !carbohydrates.isEmpty ||
                              !fat.isEmpty || !fiber.isEmpty || !sodium.isEmpty || !sugar.isEmpty

        if hasAnyNutrition {
            let nutrition = recipe.nutrition ?? NutritionInfo()
            nutrition.calories = Int(calories)
            nutrition.protein = Double(protein)
            nutrition.carbohydrates = Double(carbohydrates)
            nutrition.fat = Double(fat)
            nutrition.fiber = Double(fiber)
            nutrition.sodium = Double(sodium)
            nutrition.sugar = Double(sugar)
            recipe.nutrition = nutrition
        } else {
            recipe.nutrition = nil
        }
    }
    
    private func saveToContext() -> Bool {
        do {
            try modelContext.save()
            return true
        } catch {
            self.error = error
            return false
        }
    }
}
