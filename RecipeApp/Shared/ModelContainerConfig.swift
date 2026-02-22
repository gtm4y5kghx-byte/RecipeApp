import SwiftData

func createSharedModelContainer(inMemory: Bool = false) -> ModelContainer {
    let schema = Schema([
        Recipe.self,
        Ingredient.self,
        Step.self,
        NutritionInfo.self,
        ShoppingList.self,
        ShoppingListItem.self,
        MealPlanEntry.self
    ])
    let config = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: inMemory,
        groupContainer: .identifier("group.com.jasenmp.RecipeApp")
    )
    do {
        return try ModelContainer(for: schema, configurations: [config])
    } catch {
        fatalError("Failed to create ModelContainer: \(error)")
    }
}
