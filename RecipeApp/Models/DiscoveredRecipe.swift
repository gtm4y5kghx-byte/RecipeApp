import Foundation

struct DiscoveredRecipe: Codable, Identifiable {
    let id: Int
    let title: String
    let image: String?
    let imageType: String?
    let servings: Int?
    let readyInMinutes: Int?
    let sourceUrl: String?
    let sourceName: String?
    let cuisines: [String]?
    let dishTypes: [String]?
    let vegetarian: Bool?
    let vegan: Bool?
    let glutenFree: Bool?

    let extendedIngredients: [SpoonacularIngredient]?
    let analyzedInstructions: [SpoonacularInstruction]?
    let nutrition: SpoonacularNutrition?

    var imageURL: URL? {
        guard let image = image else { return nil }
        return URL(string: image)
    }

    var displayCuisine: String {
        cuisines?.first ?? "Unknown"
    }

    var displayTime: String {
        guard let time = readyInMinutes else { return "Time not specified" }
        if time < 60 {
            return "\(time) min"
        } else {
            let hours = time / 60
            let mins = time % 60
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
        }
    }

    func toRecipe() -> Recipe {
        let recipe = Recipe(title: title, sourceType: .web_imported)

        setBasicProperties(on: recipe)
        addIngredients(to: recipe)
        addInstructions(to: recipe)
        addNutrition(to: recipe)

        return recipe
    }

    private func setBasicProperties(on recipe: Recipe) {
        recipe.sourceURL = sourceUrl
        recipe.servings = servings
        recipe.cookTime = readyInMinutes
        recipe.cuisine = cuisines?.first
        recipe.notes = sourceName.map { "Imported from \($0)" }
    }

    private func addIngredients(to recipe: Recipe) {
        guard let spoonIngredients = extendedIngredients else { return }

        for (index, spoonIngredient) in spoonIngredients.enumerated() {
            let ingredient = Ingredient(
                quantity: String(spoonIngredient.measures.us.amount),
                unit: spoonIngredient.measures.us.unitLong.isEmpty ? nil : spoonIngredient.measures.us.unitLong,
                item: spoonIngredient.name,
                preparation: nil,
                section: nil
            )
            ingredient.order = index
            recipe.ingredients.append(ingredient)
        }
    }

    private func addInstructions(to recipe: Recipe) {
        guard let instructions = analyzedInstructions?.first?.steps else { return }

        for (index, spoonStep) in instructions.enumerated() {
            let step = Step(instruction: spoonStep.step)
            step.order = index
            recipe.instructions.append(step)
        }
    }

    private func addNutrition(to recipe: Recipe) {
        guard let nutritionData = nutrition else { return }

        let nutritionInfo = NutritionInfo(
            calories: nutritionData.nutrients.first(where: { $0.name == "Calories" }).map { Int($0.amount) },
            carbohydrates: nutritionData.nutrients.first(where: { $0.name == "Carbohydrates" })?.amount,
            protein: nutritionData.nutrients.first(where: { $0.name == "Protein" })?.amount,
            fat: nutritionData.nutrients.first(where: { $0.name == "Fat" })?.amount,
            fiber: nutritionData.nutrients.first(where: { $0.name == "Fiber" })?.amount,
            sodium: nutritionData.nutrients.first(where: { $0.name == "Sodium" })?.amount,
            sugar: nutritionData.nutrients.first(where: { $0.name == "Sugar" })?.amount
        )
        recipe.nutrition = nutritionInfo
    }
}

struct SpoonacularIngredient: Codable {
    let id: Int
    let name: String
    let original: String
    let measures: SpoonacularMeasures
}

struct SpoonacularMeasures: Codable {
    let us: SpoonacularMeasure
    let metric: SpoonacularMeasure
}

struct SpoonacularMeasure: Codable {
    let amount: Double
    let unitShort: String
    let unitLong: String
}

struct SpoonacularInstruction: Codable {
    let name: String?
    let steps: [SpoonacularStep]
}

struct SpoonacularStep: Codable {
    let number: Int
    let step: String
}

struct SpoonacularNutrition: Codable {
    let nutrients: [SpoonacularNutrient]
}

struct SpoonacularNutrient: Codable {
    let name: String
    let amount: Double
    let unit: String
    let percentOfDailyNeeds: Double?
}

struct SpoonacularSearchResponse: Codable {
    let results: [DiscoveredRecipe]
    let offset: Int
    let number: Int
    let totalResults: Int
}
