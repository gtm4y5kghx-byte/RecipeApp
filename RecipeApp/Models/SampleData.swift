import Foundation
import SwiftData

struct SampleData {
    static func loadSampleRecipes(into context: ModelContext) {
        let recipes = [
            createApplePie(),
            createChocolateCake(),
            createGrilledCheese(),
            createTacos(),
            createPasta()
        ]

        for recipe in recipes {
            context.insert(recipe)
        }

        try? context.save()
    }

    static func clearAllData(from context: ModelContext) {
        do {
            try context.delete(model: Recipe.self)
            try context.save()
        } catch {
            print("Failed to clear data: \(error)")
        }
    }

    private static func createApplePie() -> Recipe {
        let recipe = Recipe(title: "Grandma's Apple Pie", sourceType: .manual)
        recipe.servings = 8
        recipe.prepTime = 30
        recipe.cookTime = 50
        recipe.cuisine = "American"
        recipe.notes = "Best served warm with vanilla ice cream!"
        recipe.isFavorite = true
        recipe.rating = 5

        let ingredients = [
            Ingredient(quantity: "2", unit: "cups", item: "all-purpose flour", preparation: nil, section: "Crust"),
            Ingredient(quantity: "1", unit: "cup", item: "butter", preparation: "cold, cubed", section: "Crust"),
            Ingredient(quantity: "6", unit: nil, item: "Granny Smith apples", preparation: "peeled and sliced", section: "Filling"),
            Ingredient(quantity: "1", unit: "cup", item: "sugar", preparation: nil, section: "Filling"),
            Ingredient(quantity: "2", unit: "tsp", item: "cinnamon", preparation: nil, section: "Filling")
        ]

        for (index, ingredient) in ingredients.enumerated() {
            ingredient.order = index
        }
        recipe.ingredients = ingredients

        let steps = [
            Step(instruction: "Preheat oven to 375°F"),
            Step(instruction: "Mix flour and butter until crumbly, form into dough"),
            Step(instruction: "Roll out dough and place in 9-inch pie pan"),
            Step(instruction: "Toss apples with sugar and cinnamon"),
            Step(instruction: "Fill pie crust with apple mixture"),
            Step(instruction: "Cover with top crust, cut vents"),
            Step(instruction: "Bake for 50 minutes until golden brown")
        ]

        for (index, step) in steps.enumerated() {
            step.order = index
        }
        recipe.instructions = steps

        return recipe
    }

    private static func createChocolateCake() -> Recipe {
        let recipe = Recipe(title: "Simple Chocolate Cake", sourceType: .manual)
        recipe.servings = 12
        recipe.prepTime = 20
        recipe.cookTime = 35
        recipe.cuisine = "Dessert"
        recipe.rating = 4

        let ingredients = [
            Ingredient(quantity: "2", unit: "cups", item: "all-purpose flour", preparation: nil, section: nil),
            Ingredient(quantity: "2", unit: "cups", item: "sugar", preparation: nil, section: nil),
            Ingredient(quantity: "3/4", unit: "cup", item: "cocoa powder", preparation: nil, section: nil),
            Ingredient(quantity: "2", unit: "tsp", item: "baking soda", preparation: nil, section: nil),
            Ingredient(quantity: "1", unit: "cup", item: "milk", preparation: nil, section: nil),
            Ingredient(quantity: "2", unit: nil, item: "eggs", preparation: nil, section: nil)
        ]

        for (index, ingredient) in ingredients.enumerated() {
            ingredient.order = index
        }
        recipe.ingredients = ingredients

        let steps = [
            Step(instruction: "Preheat oven to 350°F and grease a 9x13 pan"),
            Step(instruction: "Mix all dry ingredients in a large bowl"),
            Step(instruction: "Add milk and eggs, beat until smooth"),
            Step(instruction: "Pour into prepared pan"),
            Step(instruction: "Bake for 35 minutes until toothpick comes out clean"),
            Step(instruction: "Cool completely before frosting")
        ]

        for (index, step) in steps.enumerated() {
            step.order = index
        }
        recipe.instructions = steps

        return recipe
    }

    private static func createGrilledCheese() -> Recipe {
        let recipe = Recipe(title: "Classic Grilled Cheese", sourceType: .manual)
        recipe.servings = 1
        recipe.prepTime = 5
        recipe.cookTime = 10
        recipe.cuisine = "American"
        recipe.rating = 5
        recipe.isFavorite = true

        let ingredients = [
            Ingredient(quantity: "2", unit: "slices", item: "bread", preparation: nil, section: nil),
            Ingredient(quantity: "2", unit: "slices", item: "cheddar cheese", preparation: nil, section: nil),
            Ingredient(quantity: "1", unit: "tbsp", item: "butter", preparation: nil, section: nil)
        ]

        for (index, ingredient) in ingredients.enumerated() {
            ingredient.order = index
        }
        recipe.ingredients = ingredients

        let steps = [
            Step(instruction: "Heat a skillet over medium heat"),
            Step(instruction: "Butter one side of each bread slice"),
            Step(instruction: "Place one slice butter-side down in skillet"),
            Step(instruction: "Add cheese and top with second slice, butter-side up"),
            Step(instruction: "Cook until golden brown, about 3-4 minutes per side")
        ]

        for (index, step) in steps.enumerated() {
            step.order = index
        }
        recipe.instructions = steps

        return recipe
    }

    private static func createTacos() -> Recipe {
        let recipe = Recipe(title: "Easy Beef Tacos", sourceType: .voice_created)
        recipe.servings = 4
        recipe.prepTime = 10
        recipe.cookTime = 15
        recipe.cuisine = "Mexican"
        recipe.notes = "Great for taco Tuesday!"
        recipe.rating = 4

        let ingredients = [
            Ingredient(quantity: "1", unit: "lb", item: "ground beef", preparation: nil, section: nil),
            Ingredient(quantity: "1", unit: "packet", item: "taco seasoning", preparation: nil, section: nil),
            Ingredient(quantity: "8", unit: nil, item: "taco shells", preparation: nil, section: nil),
            Ingredient(quantity: "1", unit: "cup", item: "lettuce", preparation: "shredded", section: nil),
            Ingredient(quantity: "1", unit: "cup", item: "cheese", preparation: "shredded", section: nil),
            Ingredient(quantity: "1", unit: nil, item: "tomato", preparation: "diced", section: nil)
        ]

        for (index, ingredient) in ingredients.enumerated() {
            ingredient.order = index
        }
        recipe.ingredients = ingredients

        let steps = [
            Step(instruction: "Brown ground beef in a large skillet over medium-high heat"),
            Step(instruction: "Drain excess fat"),
            Step(instruction: "Add taco seasoning and water per packet instructions"),
            Step(instruction: "Simmer for 5 minutes"),
            Step(instruction: "Warm taco shells according to package"),
            Step(instruction: "Fill shells with meat and desired toppings")
        ]

        for (index, step) in steps.enumerated() {
            step.order = index
        }
        recipe.instructions = steps

        return recipe
    }

    private static func createPasta() -> Recipe {
        let recipe = Recipe(title: "Garlic Butter Pasta", sourceType: .manual)
        recipe.servings = 4
        recipe.prepTime = 5
        recipe.cookTime = 15
        recipe.cuisine = "Italian"
        recipe.rating = 3

        let ingredients = [
            Ingredient(quantity: "1", unit: "lb", item: "spaghetti", preparation: nil, section: nil),
            Ingredient(quantity: "4", unit: "cloves", item: "garlic", preparation: "minced", section: nil),
            Ingredient(quantity: "1/2", unit: "cup", item: "butter", preparation: nil, section: nil),
            Ingredient(quantity: "1/2", unit: "cup", item: "parmesan cheese", preparation: "grated", section: nil),
            Ingredient(quantity: "2", unit: "tbsp", item: "fresh parsley", preparation: "chopped", section: nil)
        ]

        for (index, ingredient) in ingredients.enumerated() {
            ingredient.order = index
        }
        recipe.ingredients = ingredients

        let steps = [
            Step(instruction: "Cook pasta according to package directions"),
            Step(instruction: "While pasta cooks, melt butter in a large pan"),
            Step(instruction: "Add garlic and sauté for 1-2 minutes until fragrant"),
            Step(instruction: "Drain pasta, reserving 1 cup pasta water"),
            Step(instruction: "Toss pasta with garlic butter, adding pasta water to create sauce"),
            Step(instruction: "Top with parmesan and parsley before serving")
        ]

        for (index, step) in steps.enumerated() {
            step.order = index
        }
        recipe.instructions = steps

        return recipe
    }
}
