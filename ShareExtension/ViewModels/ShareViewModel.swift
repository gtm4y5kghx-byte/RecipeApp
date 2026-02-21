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
        complete: @escaping () -> Void
    ) {
        self.extensionDismiss = dismiss
        self.extensionComplete = complete
        setupModelContainer()
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
        guard case .preview(let recipe, _) = state else { return }

        do {
            try SharedDataManager.shared.savePendingImport(recipe)
            extensionComplete()
        } catch {
            state = .error(
                title: "Save Failed",
                message: "Could not save recipe: \(error.localizedDescription)"
            )
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
        let schema = Schema([
            Recipe.self,
            Ingredient.self,
            Step.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        modelContainer = try? ModelContainer(for: schema, configurations: [modelConfiguration])
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
