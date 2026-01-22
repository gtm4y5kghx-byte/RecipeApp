import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var selectedTab: Tab = .recipes
    @State private var menuState = AppMenuState()
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State private var selectedRecipe: Recipe?

    enum Tab: Hashable {
        case recipes
        case discover
        case mealPlan
        case shoppingList

        var title: String {
            switch self {
            case .recipes: return String(localized: "Recipes")
            case .discover: return String(localized: "Discover")
            case .mealPlan: return String(localized: "Meal Plan")
            case .shoppingList: return String(localized: "Shopping List")
            }
        }

        var icon: String {
            switch self {
            case .recipes: return "book"
            case .discover: return "sparkles"
            case .mealPlan: return "calendar"
            case .shoppingList: return "cart"
            }
        }
    }

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
        .sheet(isPresented: $menuState.showingNewRecipe) {
            RecipeFormView(recipe: nil)
        }
        .sheet(isPresented: $menuState.showingSettings) {
            SettingsView()
        }
    }

    // MARK: - iPhone Layout

    private var iPhoneLayout: some View {
        TabView(selection: $selectedTab) {
            RecipeListView(menuState: menuState)
                .tag(Tab.recipes)
                .tabItem {
                    Label("Recipes", systemImage: "book")
                }
                .accessibilityIdentifier("tab-recipes")

            DiscoverView(menuState: menuState)
                .tag(Tab.discover)
                .tabItem {
                    Label("Discover", systemImage: "sparkles")
                }
                .accessibilityIdentifier("tab-discover")

            MealPlanView()
                .tag(Tab.mealPlan)
                .tabItem {
                    Label("Meal Plan", systemImage: "calendar")
                }
                .accessibilityIdentifier("tab-meal-plan")

            ShoppingListView()
                .tag(Tab.shoppingList)
                .tabItem {
                    Label("Shopping List", systemImage: "cart")
                }
                .accessibilityIdentifier("tab-shopping-list")
        }
        .sheet(isPresented: $menuState.showingMenu) {
            RecipesMenuSheet(
                filterOptions: menuState.filterOptions,
                tagOptions: menuState.tagOptions,
                onSelectOption: { optionId in
                    menuState.selectOption(optionId)
                    selectedTab = .recipes
                },
                onNewRecipe: {
                    menuState.newRecipe()
                },
                onSettings: {
                    menuState.settings()
                }
            )
        }
    }

    // MARK: - iPad Layout

    private var iPadLayout: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            RecipesMenuList(
                appSections: [.recipes, .discover, .mealPlan, .shoppingList],
                selectedAppSection: selectedTab,
                onSelectAppSection: { tab in
                    selectedTab = tab
                    columnVisibility = .doubleColumn
                },
                filterOptions: menuState.filterOptions,
                tagOptions: menuState.tagOptions,
                selectedOptionID: nil, // TODO: Track selected filter
                onSelectOption: { optionId in
                    menuState.selectOption(optionId)
                    selectedTab = .recipes
                    columnVisibility = .doubleColumn
                },
                onNewRecipe: {
                    menuState.newRecipe()
                },
                onSettings: {
                    menuState.settings()
                }
            )
            .navigationTitle(selectedTab.title)
        } content: {
            switch selectedTab {
            case .recipes:
                RecipeListView(menuState: menuState, selectedRecipe: $selectedRecipe)
            case .discover, .mealPlan, .shoppingList:
                // These tabs don't use three-column layout
                EmptyView()
            }
        } detail: {
            switch selectedTab {
            case .recipes:
                if let recipe = selectedRecipe {
                    RecipeDetailView(recipe: recipe)
                } else {
                    ContentUnavailableView("Select a Recipe", systemImage: "fork.knife")
                }
            case .discover:
                DiscoverView(menuState: menuState)
            case .mealPlan:
                MealPlanView()
            case .shoppingList:
                ShoppingListView()
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, MealPlanEntry.self, ShoppingList.self, configurations: config)

    SampleData.loadSampleRecipes(into: container.mainContext)

    return MainView()
        .modelContainer(container)
}

#Preview("Dark: Main View") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, MealPlanEntry.self, ShoppingList.self, configurations: config)

    SampleData.loadSampleRecipes(into: container.mainContext)

    return MainView()
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
