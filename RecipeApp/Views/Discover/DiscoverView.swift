import SwiftUI
import SwiftData

struct DiscoverView: View {
    @Query(sort: \Recipe.createdAt, order: .reverse) private var recipes: [Recipe]
    @Environment(\.modelContext) private var modelContext
    
    @State private var viewModel: DiscoverViewModel?
    
    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel {
                    content(viewModel: viewModel)
                } else {
                    DSLoadingSpinner(message: "Loading...")
                }
            }
            .navigationTitle("Discover")
            .background(Theme.Colors.background)
        }
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
        if !viewModel.isPremium {
            premiumUpgradeState
        } else if !viewModel.canGenerate {
            needMoreRecipesState
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
    
    private var premiumUpgradeState: some View {
        DSEmptyState(
            icon: "sparkles",
            title: "Unlock AI Recipes",
            message: "Get personalized recipe suggestions based on your cooking style and preferences.",
            actionTitle: "Upgrade to Premium",
            action: { /* TODO: Show paywall */ }
        )
    }
    
    private var needMoreRecipesState: some View {
        DSEmptyState(
            icon: "book",
            title: "Build Your Collection",
            message: "Add at least 10 recipes so we can learn your taste and generate personalized suggestions.",
            actionTitle: nil,
            action: nil
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
