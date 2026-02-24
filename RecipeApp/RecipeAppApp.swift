import SwiftUI
import SwiftData
import BackgroundTasks

@main
struct RecipeAppApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("has_completed_onboarding") private var hasCompletedOnboarding = false

    init() {
        if ProcessInfo.processInfo.arguments.contains("RESET_USER_DEFAULTS") {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        }

        if ProcessInfo.processInfo.arguments.contains("UI_TESTING") {
            UserDefaults.standard.set(true, forKey: "has_completed_onboarding")
        }

        let context = sharedModelContainer.mainContext
        if ProcessInfo.processInfo.arguments.contains("SEED_SAMPLE_DATA") {
            SampleData.loadSampleRecipes(into: context)
        }
        if let seedRecipes = ProcessInfo.processInfo.environment["SEED_RECIPES"] {
            let ids = seedRecipes.components(separatedBy: ",")
            SampleData.loadSpecificRecipes(ids, into: context)
        }

        registerBackgroundTask()
    }

    var sharedModelContainer: ModelContainer = {
        let isUITesting = ProcessInfo.processInfo.arguments.contains("UI_TESTING")
        return createSharedModelContainer(inMemory: isUITesting)
    }()

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainView()
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            }
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
