import Foundation
import SwiftData
import os.log

actor BackgroundTaskHandler {
    static let shared = BackgroundTaskHandler()

    private let logger = Logger(subsystem: "com.recipeapp", category: "BackgroundTask")
    private let cooldownInterval: TimeInterval = 24 * 60 * 60
    private let lastAttemptKey = "background_task_last_attempt"

    func handleAIGeneration(modelContainer: ModelContainer) async {
        logger.info("Background AI generation started")

        #if !DEBUG
        guard !isWithinCooldown() else {
            logger.info("Skipping - already attempted within 24 hours")
            return
        }
        #endif

        markAttempt()

        let context = ModelContext(modelContainer)
        let recipes = fetchRecipes(context: context)

        guard shouldGenerate(recipes: recipes) else {
            logger.info("Skipping generation - threshold not met")
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

    private func isWithinCooldown() -> Bool {
        guard let lastAttempt = UserDefaults.standard.object(forKey: lastAttemptKey) as? Date else {
            return false
        }
        return Date().timeIntervalSince(lastAttempt) < cooldownInterval
    }

    private func markAttempt() {
        UserDefaults.standard.set(Date(), forKey: lastAttemptKey)
    }
}
