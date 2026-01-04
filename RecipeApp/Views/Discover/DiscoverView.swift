import SwiftUI
import SwiftData

struct DiscoverView: View {
    @Query(sort: \Recipe.createdAt, order: .reverse) private var recipes: [Recipe]
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel: DiscoverViewModel?

    init(previewViewModel: DiscoverViewModel? = nil) {
        _viewModel = State(initialValue: previewViewModel)
    }

    var body: some View {
        Group {
            if let viewModel = viewModel {
                content(viewModel: viewModel)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
        .onAppear {
            if viewModel == nil {
                viewModel = DiscoverViewModel(
                    recipes: recipes,
                    modelContext: modelContext,
                    generationService: RecipeGenerationService()
                )
                Task { await viewModel?.loadGeneratedRecipes() }
            }
        }
    }
    
    @ViewBuilder
    private func content(viewModel: DiscoverViewModel) -> some View {
        Group {
            if !viewModel.isPremium {
                premiumUpgradeState
            } else if viewModel.isLoading {
                DSLoadingSpinner(message: "Generating recipes...")
            } else if viewModel.error != nil {
                errorState
            } else if viewModel.generatedRecipes.isEmpty {
                emptyState(viewModel: viewModel)
            } else {
                generatedRecipesContent(viewModel: viewModel)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var premiumUpgradeState: some View {
        DSEmptyState(
            icon: "sparkles",
            title: "Unlock AI Recipes",
            message: "Get personalized recipe suggestions based on your cooking style and preferences.",
            actionTitle: "Upgrade to Premium",
            action: { /* TODO: Show paywall */ }
        )
    }
    
    private var errorState: some View {
        DSEmptyState(
            icon: "exclamationmark.triangle",
            title: AIError.generationFailed.title,
            message: AIError.generationFailed.message,
            actionTitle: "Try Again",
            action: { Task { await viewModel?.loadGeneratedRecipes() } }
        )
    }
    
    private func emptyState(viewModel: DiscoverViewModel) -> some View {
        DSEmptyState(
            icon: "sparkles",
            title: "Ready to Discover",
            message: "Generate new recipes tailored to your taste.",
            actionTitle: "Generate Recipes",
            action: { Task { await viewModel.loadGeneratedRecipes() } }
        )
    }
    
    private func generatedRecipesContent(viewModel: DiscoverViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                DSLabel("Made for You", style: .title2)
                    .padding(.horizontal, Theme.Spacing.md)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Theme.Spacing.md) {
                        ForEach(viewModel.generatedRecipes) { recipe in
                            DSGeneratedRecipeCard(
                                title: recipe.title,
                                description: recipe.description,
                                cuisine: recipe.cuisine,
                                totalTime: recipe.totalTime,
                                servings: recipe.servings,
                                tags: recipe.tags,
                                onSaveTap: { viewModel.saveToCollection(recipe) }
                            )
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                }
            }
            .padding(.vertical, Theme.Spacing.md)
        }
    }
}

// MARK: - Previews

#Preview("Non-Premium") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, configurations: config)
    
    UserSubscriptionService.mockIsPremium = false
    
    let viewModel = DiscoverViewModel(
        recipes: [],
        modelContext: container.mainContext,
        generationService: RecipeGenerationService()
    )
    
    return DiscoverView(previewViewModel: viewModel)
        .modelContainer(container)
}

#Preview("Loading") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, configurations: config)
    
    UserSubscriptionService.mockIsPremium = true
    
    let viewModel = DiscoverViewModel(
        recipes: [],
        modelContext: container.mainContext,
        generationService: RecipeGenerationService()
    )
    viewModel.isLoading = true
    
    return DiscoverView(previewViewModel: viewModel)
        .modelContainer(container)
}

#Preview("Generated Recipes") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, configurations: config)
    
    UserSubscriptionService.mockIsPremium = true
    
    let viewModel = DiscoverViewModel(
        recipes: [],
        modelContext: container.mainContext,
        generationService: RecipeGenerationService()
    )
    viewModel.generatedRecipes = [
        GeneratedRecipe(
            title: "Mediterranean Chickpea Bowl",
            description: "A healthy grain bowl with roasted chickpeas, fresh vegetables, and tahini dressing.",
            prepTime: 15,
            cookTime: 20,
            servings: 4,
            cuisine: "Mediterranean",
            tags: ["Healthy", "Vegetarian", "Quick"]
        ),
        GeneratedRecipe(
            title: "Spicy Korean Beef Tacos",
            description: "Fusion tacos with gochujang-marinated beef, pickled vegetables, and sriracha mayo.",
            prepTime: 20,
            cookTime: 25,
            servings: 6,
            cuisine: "Korean-Mexican",
            tags: ["Spicy", "Fusion"]
        ),
        GeneratedRecipe(
            title: "Lemon Herb Roasted Chicken",
            description: "Classic roasted chicken with garlic, rosemary, and a bright lemon finish.",
            prepTime: 15,
            cookTime: 60,
            servings: 4,
            cuisine: "American",
            tags: ["Classic", "Sunday Dinner"]
        )
    ]
    
    return DiscoverView(previewViewModel: viewModel)
        .modelContainer(container)
}

#Preview("Error") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, configurations: config)
    
    UserSubscriptionService.mockIsPremium = true
    
    let viewModel = DiscoverViewModel(
        recipes: [],
        modelContext: container.mainContext,
        generationService: RecipeGenerationService()
    )
    viewModel.error = AIError.generationFailed
    
    return DiscoverView(previewViewModel: viewModel)
        .modelContainer(container)
}
