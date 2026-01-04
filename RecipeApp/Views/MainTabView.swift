import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab: Tab = .recipes
    @State private var menuState = AppMenuState()

    enum Tab: Hashable {
        case recipes
        case discover

        var title: String {
            switch self {
            case .recipes: return "Recipes"
            case .discover: return "Discover"
            }
        }
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                RecipeListView(menuState: menuState)
                    .tag(Tab.recipes)
                    .tabItem {
                        Label("Recipes", systemImage: "book")
                    }

                DiscoverView()
                    .tag(Tab.discover)
                    .tabItem {
                        Label("Discover", systemImage: "sparkles")
                    }
            }
            .navigationTitle(selectedTab.title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        menuState.showingMenu = true
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
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
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, configurations: config)

    SampleData.loadSampleRecipes(into: container.mainContext)

    return MainTabView()
        .modelContainer(container)
}
