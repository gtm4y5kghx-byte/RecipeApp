import Foundation

enum BackgroundTaskConstants {
    static let aiGenerationIdentifier = "com.recipeapp.aiGeneration"

    /// Minimum delay before task can run (15 minutes)
    static let earliestBeginInterval: TimeInterval = 15 * 60
}
