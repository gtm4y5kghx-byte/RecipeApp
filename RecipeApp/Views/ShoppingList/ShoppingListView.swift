import SwiftUI
import SwiftData

struct ShoppingListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var recipes: [Recipe]
    @State private var viewModel: ShoppingListViewModel?
    
    var body: some View {
        NavigationStack {
            Group {
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
            .navigationTitle("Shopping List")
            .navigationBarTitleDisplayMode(.large)
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
    
    private var emptyState: some View {
        DSEmptyState(
            icon: "cart",
            title: "Shopping List Empty",
            message: "Add ingredients from your recipes to start building your shopping list."
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
