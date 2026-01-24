import SwiftUI
import SwiftData

struct ShoppingListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.isIPad) private var isIPad
    @Query private var recipes: [Recipe]

    var selectedTab: Binding<MainView.Tab>?
    var menuState: AppMenuState?

    @State private var viewModel: ShoppingListViewModel?
    @State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly

    var body: some View {
        Group {
            if isIPad {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = try? ShoppingListViewModel(
                    modelContext: modelContext,
                    recipes: recipes
                )
            }
        }
        .onChange(of: recipes) { _, newValue in
            viewModel?.updateRecipes(newValue)
        }
    }

    // MARK: - iPhone Layout

    private var iPhoneLayout: some View {
        NavigationStack {
            shoppingListContent
                .navigationTitle("Shopping List")
                .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - iPad Layout (2-column: Sidebar | Content)

    private var iPadLayout: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            RecipesMenuList(
                appSections: [.recipes, .mealPlan, .shoppingList],
                selectedAppSection: .shoppingList,
                onSelectAppSection: { tab in
                    selectedTab?.wrappedValue = tab
                },
                filterOptions: menuState?.filterOptions ?? [],
                tagOptions: menuState?.tagOptions ?? [],
                selectedOptionID: nil,
                onSelectOption: { optionId in
                    menuState?.selectOption(optionId)
                    selectedTab?.wrappedValue = .recipes
                },
                onNewRecipe: {
                    menuState?.newRecipe()
                },
                onSettings: {
                    menuState?.settings()
                }
            )
            .navigationTitle("Menu")
        } detail: {
            shoppingListContent
                .navigationTitle("Shopping List")
        }
    }

    @ViewBuilder
    private var shoppingListContent: some View {
        if let viewModel = viewModel {
            if viewModel.hasItems {
                ShoppingListContent(viewModel: viewModel)
            } else {
                emptyState
            }
        } else {
            DSLoadingSpinner(message: "Loading...")
        }
    }
    
    private var emptyState: some View {
        DSEmptyState(
            icon: "cart",
            title: "Shopping List Empty",
            message: "Add ingredients from your recipes to start building your shopping list.",
            accessibilityID: "shopping-list-empty-state"
        )
    }
}

#Preview {
      let config = ModelConfiguration(isStoredInMemoryOnly: true)
      let container = try! ModelContainer(for: Recipe.self, ShoppingList.self, configurations: config)
      let context = container.mainContext

      let cookies = Recipe(title: "Chocolate Chip Cookies", sourceType: .manual)
      cookies.ingredients = [
          Ingredient(quantity: "2", unit: "cups", item: "flour", preparation: "sifted", section: nil),
          Ingredient(quantity: "1", unit: "cup", item: "brown sugar", preparation: nil, section: nil),
          Ingredient(quantity: "2", unit: "cups", item: "chocolate chips", preparation: nil, section: nil)
      ]
      context.insert(cookies)

      let cake = Recipe(title: "Birthday Cake", sourceType: .manual)
      cake.ingredients = [
          Ingredient(quantity: "3", unit: "cups", item: "flour", preparation: nil, section: nil),
          Ingredient(quantity: "1", unit: "cup", item: "brown sugar", preparation: "packed", section: nil),
          Ingredient(quantity: "4", unit: "large", item: "eggs", preparation: nil, section: nil)
      ]
      context.insert(cake)

      let service = ShoppingListService(modelContext: context)
      try! service.addIngredientsFromRecipe(cookies)
      try! service.addIngredientsFromRecipe(cake)
      try! service.addManualItem(item: "paper towels", quantity: "2", unit: "rolls")
      try! service.addManualItem(item: "dish soap")

      return ShoppingListView()
          .modelContainer(container)
  }

 #Preview("Empty State") {
     let config = ModelConfiguration(isStoredInMemoryOnly: true)
     let container = try! ModelContainer(for: Recipe.self, ShoppingList.self, configurations: config)

     return ShoppingListView()
         .modelContainer(container)
 }
