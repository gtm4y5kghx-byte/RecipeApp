import SwiftUI
import SwiftData
import StoreKit

struct GeneratePlanSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var recipes: [Recipe]

    @State private var viewModel: GeneratePlanViewModel?
    @State private var showingPaywall = false
    @State private var subscriptionService: UserSubscriptionService?

    private let previewViewModel: GeneratePlanViewModel?

    init(previewViewModel: GeneratePlanViewModel? = nil) {
        self.previewViewModel = previewViewModel
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Generate Plan")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                            .accessibilityIdentifier("generate-plan-cancel-button")
                    }
                }
        }
        .presentationDetents([.large])
        .onAppear {
            initializeViewModel()
            if subscriptionService == nil {
                subscriptionService = UserSubscriptionService()
            }
        }
        .task {
            await subscriptionService?.loadProducts()
        }
        .sheet(isPresented: $showingPaywall) {
            SubscriptionUpsellSheet(
                subscriptionPrice: subscriptionService?.store.subscriptionProduct?.displayPrice,
                hasPremium: UserSubscriptionService.shared.isPremium,
                isPurchasing: false,
                onSubscribe: { Task { await purchaseSubscription() } },
                onDismiss: { showingPaywall = false }
            )
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if let viewModel = viewModel {
            sheetContent(viewModel)
        } else {
            DSLoadingSpinner(message: "Loading...")
        }
    }

    private func sheetContent(_ viewModel: GeneratePlanViewModel) -> some View {
        VStack(spacing: 0) {
            GeneratePlanConfigSection(viewModel: viewModel, onShowPaywall: { showingPaywall = true })
            Divider()

            if viewModel.isLoading {
                loadingState
            } else if let error = viewModel.error {
                errorState(error, viewModel: viewModel)
            } else if viewModel.hasResults {
                GeneratePlanResultsView(viewModel: viewModel, onDone: { dismiss() })
            } else {
                emptyState
            }
        }
    }

    // MARK: - States

    private var loadingState: some View {
        VStack {
            Spacer()
            DSLoadingSpinner(message: "Generating your meal plan...")
            Spacer()
        }
    }

    private func errorState(_ error: Error, viewModel: GeneratePlanViewModel) -> some View {
        DSEmptyState(
            icon: "exclamationmark.triangle",
            title: "Generation Failed",
            message: error.localizedDescription,
            actionTitle: "Try Again",
            action: { Task { await viewModel.generatePlan() } },
            accessibilityID: "generate-plan-error-empty-state"
        )
    }

    private var emptyState: some View {
        DSEmptyState(
            icon: "sparkles",
            title: "Ready to Generate",
            message: "Configure your preferences above and tap Generate Plan.",
            accessibilityID: "generate-plan-empty-state"
        )
    }

    // MARK: - Purchases

    private func purchaseSubscription() async {
        do {
            let success = try await subscriptionService?.store.purchaseSubscription() ?? false
            if success { showingPaywall = false }
        } catch {}
    }

    // MARK: - Initialization

    private func initializeViewModel() {
        guard viewModel == nil else { return }

        if let previewViewModel {
            viewModel = previewViewModel
            return
        }

        let mealPlanService = MealPlanService(modelContext: modelContext)
        let aiService = MealPlanAIService()

        viewModel = GeneratePlanViewModel(
            recipes: recipes,
            mealPlanService: mealPlanService,
            aiService: aiService
        )
    }
}

// MARK: - Previews

#Preview("Empty State") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, MealPlanEntry.self, configurations: config)

    let viewModel = GeneratePlanViewModel(
        recipes: [],
        mealPlanService: MealPlanService(modelContext: container.mainContext),
        aiService: MealPlanAIService()
    )

    return GeneratePlanSheet(previewViewModel: viewModel)
        .modelContainer(container)
}

#Preview("Loading") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, MealPlanEntry.self, configurations: config)

    let viewModel = GeneratePlanViewModel(
        recipes: [Recipe(title: "Sample Recipe", sourceType: .manual)],
        mealPlanService: MealPlanService(modelContext: container.mainContext),
        aiService: MealPlanAIService()
    )
    viewModel.isLoading = true

    return GeneratePlanSheet(previewViewModel: viewModel)
        .modelContainer(container)
}

#Preview("Results") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, MealPlanEntry.self, configurations: config)

    let recipes = [
        Recipe(title: "Spaghetti Carbonara", sourceType: .manual),
        Recipe(title: "Chicken Tikka Masala", sourceType: .manual),
        Recipe(title: "Beef Tacos", sourceType: .manual),
        Recipe(title: "Grilled Salmon", sourceType: .manual),
        Recipe(title: "Vegetable Stir Fry", sourceType: .manual)
    ]
    recipes[0].cuisine = "Italian"
    recipes[1].cuisine = "Indian"
    recipes[2].cuisine = "Mexican"
    recipes[3].cuisine = "American"
    recipes[4].cuisine = "Asian"

    let viewModel = GeneratePlanViewModel(
        recipes: recipes,
        mealPlanService: MealPlanService(modelContext: container.mainContext),
        aiService: MealPlanAIService()
    )

    let today = Date()
    viewModel.results = [
        MealPlanGenerationResult(date: today, recipe: recipes[0]),
        MealPlanGenerationResult(date: Calendar.current.date(byAdding: .day, value: 1, to: today)!, recipe: recipes[1]),
        MealPlanGenerationResult(date: Calendar.current.date(byAdding: .day, value: 2, to: today)!, recipe: recipes[2]),
        MealPlanGenerationResult(date: Calendar.current.date(byAdding: .day, value: 3, to: today)!, recipe: recipes[3]),
        MealPlanGenerationResult(date: Calendar.current.date(byAdding: .day, value: 4, to: today)!, recipe: recipes[4])
    ]
    viewModel.selectedDayCount = 5

    return GeneratePlanSheet(previewViewModel: viewModel)
        .modelContainer(container)
}

#Preview("Error") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, MealPlanEntry.self, configurations: config)

    let viewModel = GeneratePlanViewModel(
        recipes: [Recipe(title: "Sample Recipe", sourceType: .manual)],
        mealPlanService: MealPlanService(modelContext: container.mainContext),
        aiService: MealPlanAIService()
    )
    viewModel.error = AIError.emptyCollection

    return GeneratePlanSheet(previewViewModel: viewModel)
        .modelContainer(container)
}
