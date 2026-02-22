import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isIPad) private var isIPad

    @State private var viewModel: RecipeDetailViewModel?
    @State private var showingEditSheet = false
    @State private var showingCookingMode = false
    @State private var showingDeleteConfirmation = false
    @State private var showingRemoveConfirmation = false
    @State private var showingCannotCookAlert = false
    @State private var showingAddToMealPlan = false
    @State private var error: Error?

    let recipe: Recipe
    var onRemoveFromContext: (() -> Void)?
    var columnVisibility: Binding<NavigationSplitViewVisibility>?

    init(
        recipe: Recipe,
        onRemoveFromContext: (() -> Void)? = nil,
        columnVisibility: Binding<NavigationSplitViewVisibility>? = nil
    ) {
        self.recipe = recipe
        self.onRemoveFromContext = onRemoveFromContext
        self.columnVisibility = columnVisibility
    }

    private var isDetailOnly: Bool {
        columnVisibility?.wrappedValue == .detailOnly
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let viewModel = viewModel {
                    RecipeDetailHeader(
                        title: viewModel.recipe.title,
                        isFavorite: viewModel.recipe.isFavorite,
                        onFavoriteTap: {
                            HapticFeedback.light.trigger()
                            viewModel.toggleFavorite()
                        }
                    )
                    
                    RecipeDetailImage(
                        imageURL: viewModel.recipe.imageURL
                    )
                    
                    DSSection {
                        HStack(spacing: Theme.Spacing.xs) {
                            RecipeDetailMetaData(
                                totalTime: viewModel.formattedTotalTime,
                                servings: viewModel.recipe.servings,
                                cuisine: viewModel.recipe.cuisine,
                            )

                            Spacer()

                            HStack(spacing: Theme.Spacing.sm) {
                                DSButton(
                                    title: "Made It",
                                    style: .primary,
                                    size: .small,
                                    fullWidth: false
                                ) {
                                    HapticFeedback.success.trigger()
                                    viewModel.markAsCooked()
                                }
                                .accessibilityIdentifier("recipe-detail-cooked-button")

                                if viewModel.recipe.timesCooked > 0 {
                                    Text("\(viewModel.recipe.timesCooked)")
                                        .font(Theme.Typography.caption1.bold())
                                        .foregroundColor(Theme.Colors.tagSecondaryText)
                                        .frame(minWidth: 24, minHeight: 24)
                                        .background(Theme.Colors.tagSecondaryBackground)
                                        .clipShape(Circle())
                                        .contentTransition(.numericText())
                                        .animation(.default, value: viewModel.recipe.timesCooked)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.top, Theme.Spacing.sm)
                    
                    RecipeDetailTags(
                        tags: viewModel.recipe.userTags
                    )
                    
                    RecipeDetailSources(
                        sourceURL: viewModel.sourceDomain
                    )
                    
                    RecipeDetailIngredients(
                        groupedIngredients: viewModel.groupedIngredients
                    )
                    
                    RecipeDetailInstructions(
                        instructions: viewModel.recipe.instructions
                    )
                    
                    RecipeDetailNotes(
                        notes: viewModel.recipe.notes
                    )
                    
                    RecipeDetailNutrition(
                        nutrition: viewModel.recipe.nutrition
                    )
                } else {
                    DSLoadingSpinner(message: "Loading recipe...")
                }
            }
        }
        .background(Theme.Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if columnVisibility != nil {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation {
                            columnVisibility?.wrappedValue = isDetailOnly ? .doubleColumn : .detailOnly
                        }
                    } label: {
                        Image(systemName: isDetailOnly ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                    }
                    .accessibilityIdentifier("recipe-detail-fullscreen-button")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Start Cooking") {
                        if recipe.canStartCooking {
                            showingCookingMode = true
                        } else {
                            HapticFeedback.warning.trigger()
                            showingCannotCookAlert = true
                        }
                    }
                    .accessibilityIdentifier("recipe-detail-start-cooking-button")
                    Button("Add to Shopping List") {
                        viewModel?.addToShoppingList()
                    }
                    .accessibilityIdentifier("recipe-detail-add-to-shopping-list-button")
                    Button("Add to Meal Plan") {
                        showingAddToMealPlan = true
                    }
                    .accessibilityIdentifier("recipe-detail-add-to-meal-plan-button")
                    Button("Edit") { showingEditSheet = true }
                        .accessibilityIdentifier("recipe-detail-edit-button")
                    if onRemoveFromContext != nil {
                        Button("Remove from Calendar", role: .destructive) { showingRemoveConfirmation = true }
                            .accessibilityIdentifier("recipe-detail-remove-from-calendar-button")
                    } else {
                        Button("Delete", role: .destructive) { showingDeleteConfirmation = true }
                            .accessibilityIdentifier("recipe-detail-delete-button")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityIdentifier("recipe-detail-menu-button")
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            RecipeFormView(recipe: recipe)
        }
        .fullScreenCover(isPresented: $showingCookingMode) {
            CookingModeView(recipe: recipe)
        }
        .fullScreenCover(isPresented: $showingAddToMealPlan) {
            MealPlanCalendarSheet(recipe: recipe)
        }
        .alert(String(localized: "Delete Recipe?"), isPresented: $showingDeleteConfirmation) {
            Button(String(localized: "Delete"), role: .destructive) {
                guard let viewModel = viewModel else { return }
                HapticFeedback.warning.trigger()
                if viewModel.deleteRecipe() {
                    dismiss()
                }
            }
            Button(String(localized: "Cancel"), role: .cancel) { }
        }
        .alert(String(localized: "Remove from Calendar?"), isPresented: $showingRemoveConfirmation) {
            Button(String(localized: "Remove"), role: .destructive) {
                HapticFeedback.light.trigger()
                onRemoveFromContext?()
            }
            Button(String(localized: "Cancel"), role: .cancel) { }
        }
        .alert(String(localized: "Can't Start Cooking"), isPresented: $showingCannotCookAlert) {
            Button(String(localized: "OK"), role: .cancel) { }
        } message: {
            Text(String(localized: "This recipe needs ingredients and instructions before you can start cooking."))
        }
        .onAppear {
            if viewModel == nil {
                viewModel = RecipeDetailViewModel(
                    recipe: recipe,
                    modelContext: modelContext
                )
            }

            if UserDefaults.standard.bool(forKey: "keepScreenOnWhileViewingRecipes") {
                UIApplication.shared.isIdleTimerDisabled = true
            }
        }
        .onChange(of: recipe) { _, newRecipe in
            // Only needed on iPad where detail view persists across selections
            guard isIPad else { return }
            viewModel?.updateRecipe(newRecipe)
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: SampleData.createApplePie())
    }
}

#Preview("Dark: Recipe Detail") {
    NavigationStack {
        RecipeDetailView(recipe: SampleData.createApplePie())
    }
    .preferredColorScheme(.dark)
}
