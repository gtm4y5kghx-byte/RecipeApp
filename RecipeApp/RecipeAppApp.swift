import SwiftUI
import SwiftData
import BackgroundTasks

@main
struct RecipeAppApp: App {
    @Environment(\.scenePhase) private var scenePhase

    init() {
        if ProcessInfo.processInfo.arguments.contains("RESET_USER_DEFAULTS") {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        }

        registerBackgroundTask()
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Recipe.self,
            Ingredient.self,
            Step.self,
            ShoppingList.self,
            ShoppingListItem.self,
            MealPlanEntry.self
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
            MainView()
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                scheduleBackgroundTask()
            }
        }
    }

    private func registerBackgroundTask() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: BackgroundTaskConstants.aiGenerationIdentifier,
            using: nil
        ) { task in
            guard let processingTask = task as? BGProcessingTask else { return }
            self.handleBackgroundTask(processingTask)
        }
    }

    private func handleBackgroundTask(_ task: BGProcessingTask) {
        let taskOperation = Task {
            await BackgroundTaskHandler.shared.handleAIGeneration(
                modelContainer: sharedModelContainer
            )
            task.setTaskCompleted(success: true)
        }

        task.expirationHandler = {
            taskOperation.cancel()
            task.setTaskCompleted(success: false)
        }
    }

    private func scheduleBackgroundTask() {
        let request = BGProcessingTaskRequest(
            identifier: BackgroundTaskConstants.aiGenerationIdentifier
        )
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = true
        request.earliestBeginDate = Date(
            timeIntervalSinceNow: BackgroundTaskConstants.earliestBeginInterval
        )

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to schedule background task: \(error)")
        }
    }
}
