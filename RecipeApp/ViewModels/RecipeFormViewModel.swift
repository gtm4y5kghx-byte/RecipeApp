import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
class RecipeFormViewModel {
    var title: String = ""
    var servings: String = ""
    var prepTime: String = ""
    var cookTime: String = ""
    var cuisine: String = ""
    var notes: String = ""
    var ingredientFields: [String] = [""]
    var instructionFields: [String] = [""]
    var tagInput: String = ""
    var error: Error?

    private let recipe: Recipe?
    private let modelContext: ModelContext
    private let importData: RecipeImportData?

    init(recipe: Recipe?, importData: RecipeImportData?, modelContext: ModelContext) {
        self.recipe = recipe
        self.importData = importData
        self.modelContext = modelContext

        if let recipe = recipe {
            self.title = recipe.title
            self.servings = recipe.servings.map { String($0) } ?? ""
            self.prepTime = recipe.prepTime.map { String($0) } ?? ""
            self.cookTime = recipe.cookTime.map { String($0) } ?? ""
            self.cuisine = recipe.cuisine ?? ""
            self.notes = recipe.notes ?? ""

            let sortedIngredients = recipe.sortedIngredients
            let ingredientTexts = sortedIngredients.map { $0.item }
            self.ingredientFields = ingredientTexts.isEmpty ? [""] : ingredientTexts

            let sortedInstructions = recipe.sortedInstructions
            let instructionTexts = sortedInstructions.map { $0.instruction }
            self.instructionFields = instructionTexts.isEmpty ? [""] : instructionTexts

            self.tagInput = recipe.userTags.joined(separator: ", ")
        } else if let importData = importData {
            self.title = importData.title
            self.servings = importData.servings.map { String($0) } ?? ""
            self.prepTime = importData.prepTime.map { String($0) } ?? ""
            self.cookTime = importData.cookTime.map { String($0) } ?? ""
            self.cuisine = importData.cuisine ?? ""
            self.notes = importData.description ?? ""

            self.ingredientFields = importData.ingredients.isEmpty ? [""] : importData.ingredients
            self.instructionFields = importData.instructions.isEmpty ? [""] : importData.instructions
        }
    }

    var formHasChanges: Bool {
        if recipe == nil {
            return !title.isEmpty ||
            ingredientFields.contains(where: { !$0.isEmpty }) ||
            instructionFields.contains(where: { !$0.isEmpty }) ||
            !servings.isEmpty || !prepTime.isEmpty || !cookTime.isEmpty || !cuisine.isEmpty || !notes.isEmpty ||
            !tagInput.isEmpty
        }

        guard let recipe = recipe else { return false }

        let ingredientsChanged = ingredientFields != recipe.sortedIngredients.map { $0.item }
        let instructionsChanged = instructionFields != recipe.sortedInstructions.map { $0.instruction }
        let tagsChanged = tagInput != recipe.userTags.joined(separator: ", ")

        return title != recipe.title ||
        servings != (recipe.servings.map { String($0) } ?? "") ||
        prepTime != (recipe.prepTime.map { String($0) } ?? "") ||
        cookTime != (recipe.cookTime.map { String($0) } ?? "") ||
        cuisine != (recipe.cuisine ?? "") ||
        notes != (recipe.notes ?? "") ||
        ingredientsChanged ||
        instructionsChanged ||
        tagsChanged
    }

    func getTagSuggestions(allRecipes: [Recipe]) -> [(String, Int)] {
        let currentTag = tagInput
            .split(separator: ",")
            .last?
            .trimmingCharacters(in: .whitespaces)
            .lowercased() ?? ""

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

    func saveRecipe() -> Bool {
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

        return saveToContext()
    }

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

    private func saveToContext() -> Bool {
        do {
            try modelContext.save()

            if importData != nil {
                try? SharedDataManager.shared.deletePendingImport()
            }

            return true
        } catch {
            self.error = error
            return false
        }
    }
}
