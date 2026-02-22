import Foundation
import SwiftData

@MainActor
@Observable
class ShareViewModel {

    // MARK: - State

    enum ViewState {
        case loading(message: String)
        case error(title: String, message: String)
        case preview(recipe: RecipeImportData, alreadyImported: Bool)
    }

    var state: ViewState = .loading(message: "Loading recipe...")

    // MARK: - Dependencies

    private let extensionDismiss: () -> Void
    private let extensionComplete: () -> Void
    private var modelContainer: ModelContainer?

    // MARK: - Init

    init(
        dismiss: @escaping () -> Void,
        complete: @escaping () -> Void,
        modelContainer: ModelContainer? = nil
    ) {
        self.extensionDismiss = dismiss
        self.extensionComplete = complete
        self.modelContainer = modelContainer
        if modelContainer == nil {
            setupModelContainer()
        }
    }

    // MARK: - Public Actions

    func loadRecipe(from url: URL) async {
        state = .loading(message: "Fetching recipe...")

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            guard let html = String(data: data, encoding: .utf8) else {
                state = .error(
                    title: "Import Failed",
                    message: "Could not read the page content."
                )
                return
            }

            state = .loading(message: "Parsing recipe...")

            guard let recipe = RecipeHTMLParser.parseRecipe(from: html, sourceURL: url) else {
                state = .error(
                    title: "No Recipe Found",
                    message: "This page doesn't contain structured recipe data."
                )
                return
            }

            let alreadyImported = checkIfRecipeExists(url: url)
            state = .preview(recipe: recipe, alreadyImported: alreadyImported)

        } catch {
            state = .error(
                title: "Import Failed",
                message: error.localizedDescription
            )
        }
    }

    func addRecipe() {
        guard case .preview(let importData, _) = state else { return }
        guard let container = modelContainer else {
            state = .error(title: "Save Failed", message: "Database not available.")
            return
        }

        let context = container.mainContext
        let recipe = Recipe(title: importData.title, sourceType: .web_imported)
        recipe.sourceURL = importData.sourceURL
        recipe.imageURL = importData.imageURL
        recipe.servings = importData.servings
        recipe.prepTime = importData.prepTime
        recipe.cookTime = importData.cookTime
        recipe.cuisine = importData.cuisine
        recipe.notes = importData.description

        for (index, ingredientText) in importData.ingredients.enumerated() {
            let ingredient = Ingredient(quantity: "", unit: nil, item: ingredientText, preparation: nil, section: nil)
            ingredient.order = index
            recipe.ingredients.append(ingredient)
        }

        for (index, instructionText) in importData.instructions.enumerated() {
            let step = Step(instruction: instructionText)
            step.order = index
            recipe.instructions.append(step)
        }

        if let nutritionData = importData.nutrition {
            recipe.nutrition = NutritionInfo(
                calories: nutritionData.calories,
                carbohydrates: nutritionData.carbohydrates,
                protein: nutritionData.protein,
                fat: nutritionData.fat,
                fiber: nutritionData.fiber,
                sodium: nutritionData.sodium,
                sugar: nutritionData.sugar
            )
        }

        context.insert(recipe)
        do {
            try context.save()
            extensionComplete()
        } catch {
            state = .error(title: "Save Failed", message: error.localizedDescription)
        }
    }

    func cancel() {
        extensionDismiss()
    }

    // MARK: - Computed Properties

    var formattedPrepTime: String? {
        guard case .preview(let recipe, _) = state,
              let mins = recipe.prepTime else { return nil }
        return formatMinutes(mins)
    }

    var formattedCookTime: String? {
        guard case .preview(let recipe, _) = state,
              let mins = recipe.cookTime else { return nil }
        return formatMinutes(mins)
    }

    var formattedTotalTime: String? {
        guard case .preview(let recipe, _) = state,
              let mins = recipe.totalTime else { return nil }
        return formatMinutes(mins)
    }

    // MARK: - Private Helpers

    private func formatMinutes(_ totalMinutes: Int) -> String {
        if totalMinutes < 60 { return "\(totalMinutes) min" }
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return minutes == 0 ? "\(hours)h" : "\(hours)h \(minutes)m"
    }

    private func setupModelContainer() {
        modelContainer = createSharedModelContainer()
    }

    private func checkIfRecipeExists(url: URL) -> Bool {
        guard let container = modelContainer else { return false }

        let context = container.mainContext
        let urlString = url.absoluteString

        let descriptor = FetchDescriptor<Recipe>(
            predicate: #Predicate { recipe in
                recipe.sourceURL == urlString
            }
        )

        do {
            let existingRecipes = try context.fetch(descriptor)
            return !existingRecipes.isEmpty
        } catch {
            return false
        }
    }
}
