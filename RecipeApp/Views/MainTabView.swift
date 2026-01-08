import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab: Tab = .recipes
    @State private var menuState = AppMenuState()
    
    enum Tab: Hashable {
        case recipes
        case discover
        case mealPlan
        case shoppingList

        var title: String {
            switch self {
            case .recipes: return "Recipes"
            case .discover: return "Discover"
            case .mealPlan: return "Meal Plan"
            case .shoppingList: return "Shopping List"
            }
        }
    }
    
    var body: some View {
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
        .sheet(isPresented: $menuState.showingNewRecipe) {
            RecipeFormView(recipe: nil)
        }
        .sheet(isPresented: $menuState.showingSettings) {
            SettingsView()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, MealPlanEntry.self, ShoppingList.self, configurations: config)
    
    SampleData.loadSampleRecipes(into: container.mainContext)
    
    return MainTabView()
        .modelContainer(container)
}
