import SwiftUI
import Swipy

/// Prototype: Hybrid Pattern - Each tab owns its NavigationSplitView, shares sidebar component
/// iPad: Each view embeds shared AppSidebar in its own NavigationSplitView
/// iPhone: TabView (unchanged)
struct NavigationTestView: View {
    @Environment(\.isIPad) private var isIPad
    @State private var selectedTab: TestTab = .recipes

    var body: some View {
        if isIPad {
            iPadLayout
        } else {
            iPhoneLayout
        }
    }

    // MARK: - iPhone Layout (TabView - unchanged pattern)

    private var iPhoneLayout: some View {
        TabView(selection: $selectedTab) {
            RecipesTabView(selectedTab: .constant(.recipes))
                .tag(TestTab.recipes)
                .tabItem { Label("Recipes", systemImage: "book") }

            MealPlanTabView(selectedTab: .constant(.mealPlan))
                .tag(TestTab.mealPlan)
                .tabItem { Label("Meal Plan", systemImage: "calendar") }

            ShoppingListTabView(selectedTab: .constant(.shoppingList))
                .tag(TestTab.shoppingList)
                .tabItem { Label("Shopping", systemImage: "cart") }
        }
    }

    // MARK: - iPad Layout (Each tab owns its NavigationSplitView with shared sidebar)

    private var iPadLayout: some View {
        Group {
            switch selectedTab {
            case .recipes:
                RecipesTabView(selectedTab: $selectedTab)
            case .mealPlan:
                MealPlanTabView(selectedTab: $selectedTab)
            case .shoppingList:
                ShoppingListTabView(selectedTab: $selectedTab)
            }
        }
    }
}

// MARK: - Shared Types

enum TestTab: String, CaseIterable {
    case recipes = "Recipes"
    case mealPlan = "Meal Plan"
    case shoppingList = "Shopping List"

    var icon: String {
        switch self {
        case .recipes: return "book"
        case .mealPlan: return "calendar"
        case .shoppingList: return "cart"
        }
    }
}

// MARK: - Shared Sidebar Component

private struct AppSidebar: View {
    @Binding var selectedTab: TestTab

    // Recipe-specific filters (only shown when on recipes tab)
    var showRecipeFilters: Bool = false
    @Binding var selectedFilter: String?

    let filters = ["All", "Favorites", "Recent"]
    let tags = ["Italian", "Quick", "Vegetarian"]

    var body: some View {
        List {
            Section("Sections") {
                ForEach(TestTab.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        Label(tab.rawValue, systemImage: tab.icon)
                    }
                    .foregroundStyle(selectedTab == tab ? Color.accentColor : .primary)
                }
            }

            if showRecipeFilters {
                Section("Filters") {
                    ForEach(filters, id: \.self) { filter in
                        Button {
                            selectedFilter = filter
                        } label: {
                            Label(filter, systemImage: filterIcon(for: filter))
                        }
                        .foregroundStyle(selectedFilter == filter ? Color.accentColor : .primary)
                    }
                }

                Section("Tags") {
                    ForEach(tags, id: \.self) { tag in
                        Button {
                            selectedFilter = tag
                        } label: {
                            Label(tag, systemImage: "tag")
                        }
                        .foregroundStyle(selectedFilter == tag ? Color.accentColor : .primary)
                    }
                }
            }
        }
        .navigationTitle("Menu")
    }

    private func filterIcon(for filter: String) -> String {
        switch filter {
        case "All": return "book"
        case "Favorites": return "heart"
        case "Recent": return "clock"
        default: return "folder"
        }
    }
}

// MARK: - Recipes Tab (3-column NavigationSplitView)

private struct RecipesTabView: View {
    @Environment(\.isIPad) private var isIPad
    @Binding var selectedTab: TestTab

    @State private var selectedFilter: String? = "All"
    @State private var selectedItem: String?

    let items = (1...20).map { "Recipe \($0)" }

    var body: some View {
        if isIPad {
            NavigationSplitView {
                AppSidebar(
                    selectedTab: $selectedTab,
                    showRecipeFilters: true,
                    selectedFilter: $selectedFilter
                )
            } content: {
                List(selection: $selectedItem) {
                    ForEach(items, id: \.self) { item in
                        Text(item).tag(item)
                    }
                }
                .navigationTitle(selectedFilter ?? "Recipes")
            } detail: {
                if let item = selectedItem {
                    Text("Detail: \(item)")
                        .font(.largeTitle)
                        .navigationTitle(item)
                } else {
                    ContentUnavailableView("Select a Recipe", systemImage: "fork.knife")
                }
            }
        } else {
            // iPhone: NavigationStack, no sidebar
            NavigationStack {
                List(selection: $selectedItem) {
                    ForEach(items, id: \.self) { item in
                        Text(item).tag(item)
                    }
                }
                .navigationTitle("Recipes")
            }
        }
    }
}

// MARK: - Meal Plan Tab (3-column: Sidebar | Calendar | Detail)

private struct MealPlanTabView: View {
    @Environment(\.isIPad) private var isIPad
    @Binding var selectedTab: TestTab

    @State private var selectedFilter: String? = nil
    @State private var selectedMeal: String?

    let meals = ["Monday Breakfast", "Monday Lunch", "Monday Dinner", "Tuesday Breakfast", "Tuesday Lunch"]

    var body: some View {
        if isIPad {
            NavigationSplitView {
                AppSidebar(
                    selectedTab: $selectedTab,
                    showRecipeFilters: false,
                    selectedFilter: $selectedFilter
                )
            } content: {
                // Calendar column
                List(selection: $selectedMeal) {
                    ForEach(meals, id: \.self) { meal in
                        Text(meal).tag(meal)
                    }
                }
                .navigationTitle("Meal Plan")
            } detail: {
                if let meal = selectedMeal {
                    Text("Recipe Detail for: \(meal)")
                        .font(.largeTitle)
                        .navigationTitle(meal)
                } else {
                    ContentUnavailableView("Select a Meal", systemImage: "fork.knife")
                }
            }
        } else {
            // iPhone: NavigationStack
            NavigationStack {
                List(selection: $selectedMeal) {
                    ForEach(meals, id: \.self) { meal in
                        Text(meal).tag(meal)
                    }
                }
                .navigationTitle("Meal Plan")
            }
        }
    }
}

// MARK: - Shopping List Tab (2-column: Sidebar | Content)

private struct ShoppingListTabView: View {
    @Environment(\.isIPad) private var isIPad
    @Binding var selectedTab: TestTab

    @State private var selectedFilter: String? = nil

    var body: some View {
        if isIPad {
            NavigationSplitView {
                AppSidebar(
                    selectedTab: $selectedTab,
                    showRecipeFilters: false,
                    selectedFilter: $selectedFilter
                )
            } detail: {
                List {
                    Section("Produce") {
                        Text("Apples")
                        Text("Bananas")
                        Text("Carrots")
                    }
                    Section("Dairy") {
                        Text("Milk")
                        Text("Cheese")
                        Text("Yogurt")
                    }
                }
                .navigationTitle("Shopping List")
            }
        } else {
            // iPhone: NavigationStack
            NavigationStack {
                List {
                    Section("Produce") {
                        Text("Apples")
                        Text("Bananas")
                        Text("Carrots")
                    }
                    Section("Dairy") {
                        Text("Milk")
                        Text("Cheese")
                        Text("Yogurt")
                    }
                }
                .navigationTitle("Shopping List")
            }
        }
    }
}

#Preview {
    NavigationTestView()
}
