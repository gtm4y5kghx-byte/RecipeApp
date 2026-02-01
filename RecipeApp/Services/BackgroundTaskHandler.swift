import Foundation
import SwiftData
import os.log

actor BackgroundTaskHandler {
    static let shared = BackgroundTaskHandler()

    private let logger = Logger(subsystem: "com.recipeapp", category: "BackgroundTask")

    func handleAIGeneration(modelContainer: ModelContainer) async {
        logger.info("Background AI generation started")

        let context = ModelContext(modelContainer)
        let recipes = fetchRecipes(context: context)

        guard shouldGenerate(recipes: recipes) else {
            logger.info("Skipping generation - threshold not met or cache fresh")
            return
        }

        do {
            let service = await UnifiedSuggestionService()

            let suggestions = try await service.getUnifiedSuggestions(
                recipes: recipes,
                forceRefresh: false
            )

            logger.info("Background AI generation completed - \(suggestions.count) suggestions")
        } catch {
            logger.error("Background AI generation failed: \(error.localizedDescription)")
        }
    }

    private func fetchRecipes(context: ModelContext) -> [Recipe] {
        let descriptor = FetchDescriptor<Recipe>()
        return (try? context.fetch(descriptor)) ?? []
    }

    private func shouldGenerate(recipes: [Recipe]) -> Bool {
        guard recipes.count >= 10 else {
            logger.info("Recipe count \(recipes.count) below threshold")
            return false
        }
        return true
    }
}
