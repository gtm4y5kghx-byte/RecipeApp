import Foundation
import SwiftData
@testable import RecipeApp

@MainActor
class TestModelContainer {
    static func create() -> ModelContainer {
        let schema = Schema([
            Recipe.self,
            Ingredient.self,
            Step.self,
            NutritionInfo.self
        ])
        
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create test model container: \(error)")
        }
    }
}
