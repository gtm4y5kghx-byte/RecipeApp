import SwiftUI
import SwiftData

@main
struct RecipeAppApp: App {
    init() {
        if ProcessInfo.processInfo.arguments.contains("RESET_USER_DEFAULTS") {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        }
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Recipe.self,
            Ingredient.self,
            Step.self,
        ])

        let isUITesting = ProcessInfo.processInfo.arguments.contains("UI-TESTING")
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isUITesting)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RecipeListView()
        }
        .modelContainer(sharedModelContainer)
    }
}
