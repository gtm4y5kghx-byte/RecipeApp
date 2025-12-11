import Foundation
import SwiftData

struct SampleData {
    static func loadSampleRecipes(into context: ModelContext) {
        let recipes = [
            createApplePie(),
            createChocolateCake(),
            createGrilledCheese(),
            createTacos(),
            createPasta(),
            createChickenStirFry(),
            createTomSoup(),
            createQuickPickles(),
            createBeefBurgers(),
            createVegetarianChili(),
            createPadThai(),
            createFrenchOnionSoup(),
            createBakedSalmon(),
            createChickenParmesan(),
            createVeganCurry(),
            createQuickOmelette(),
            createSlowCookerRoast(),
            createCapreseSalad(),
            createSpicyRamen(),
            createLemonTart()
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
        recipe.timesCooked = 8
        recipe.lastMade = Calendar.current.date(byAdding: .day, value: -120, to: Date()) // 4 months ago

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

        recipe.userTags = ["Dessert", "Baking", "Pie"]
        recipe.imageURL = "https://placehold.co/400x300"

        return recipe
    }

    private static func createChocolateCake() -> Recipe {
        let recipe = Recipe(title: "Simple Chocolate Cake", sourceType: .manual)
        recipe.servings = 12
        recipe.prepTime = 20
        recipe.cookTime = 35
        recipe.cuisine = "Dessert"
        recipe.timesCooked = 3
        recipe.lastMade = Calendar.current.date(byAdding: .day, value: -10, to: Date()) // 10 days ago

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

        recipe.userTags = ["Dessert", "Baking", "Chocolate"]
        recipe.imageURL = "https://placehold.co/400x300"

        return recipe
    }

    private static func createGrilledCheese() -> Recipe {
        let recipe = Recipe(title: "Classic Grilled Cheese", sourceType: .manual)
        recipe.servings = 1
        recipe.prepTime = 5
        recipe.cookTime = 10
        recipe.cuisine = "American"
        recipe.isFavorite = true
        recipe.timesCooked = 15
        recipe.lastMade = Calendar.current.date(byAdding: .day, value: -5, to: Date()) // 5 days ago

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

        recipe.userTags = ["Lunch", "Quick", "Sandwich"]
        recipe.imageURL = "https://placehold.co/400x300"

        return recipe
    }

    private static func createTacos() -> Recipe {
        let recipe = Recipe(title: "Easy Beef Tacos", sourceType: .manual)
        recipe.servings = 4
        recipe.prepTime = 10
        recipe.cookTime = 15
        recipe.cuisine = "Mexican"
        recipe.notes = "Great for taco Tuesday!"
        recipe.timesCooked = 0
        // No lastMade - never cooked

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

        recipe.userTags = ["Dinner", "Mexican", "Beef"]
        recipe.imageURL = "https://placehold.co/400x300"

        return recipe
    }

    private static func createPasta() -> Recipe {
        let recipe = Recipe(title: "Garlic Butter Pasta", sourceType: .manual)
        recipe.servings = 4
        recipe.prepTime = 5
        recipe.cookTime = 15
        recipe.cuisine = "Italian"
        recipe.timesCooked = 0
        // No lastMade - never cooked

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

        recipe.userTags = ["Dinner", "Pasta", "Italian", "Quick"]
        recipe.imageURL = "https://placehold.co/400x300"

        return recipe
    }

    // NEW RECIPES FOR TESTING VARIETY

    private static func createChickenStirFry() -> Recipe {
        let recipe = Recipe(title: "Quick Chicken Stir Fry", sourceType: .manual)
        recipe.servings = 4
        recipe.prepTime = 15
        recipe.cookTime = 15
        recipe.cuisine = "Chinese"
        recipe.notes = "Perfect weeknight dinner!"
        recipe.isFavorite = true
        recipe.timesCooked = 12
        recipe.lastMade = Calendar.current.date(byAdding: .day, value: -20, to: Date())

        let ingredients = [
            Ingredient(quantity: "1", unit: "lb", item: "chicken breast", preparation: "sliced thin", section: nil),
            Ingredient(quantity: "2", unit: "cups", item: "broccoli florets", preparation: nil, section: nil),
            Ingredient(quantity: "1", unit: nil, item: "bell pepper", preparation: "sliced", section: nil),
            Ingredient(quantity: "3", unit: "tbsp", item: "soy sauce", preparation: nil, section: nil),
            Ingredient(quantity: "2", unit: "tbsp", item: "vegetable oil", preparation: nil, section: nil)
        ]

        for (index, ingredient) in ingredients.enumerated() {
            ingredient.order = index
        }
        recipe.ingredients = ingredients

        let steps = [
            Step(instruction: "Heat oil in a wok or large skillet over high heat"),
            Step(instruction: "Add chicken and stir-fry until cooked through, about 5 minutes"),
            Step(instruction: "Add vegetables and stir-fry for 3-4 minutes"),
            Step(instruction: "Add soy sauce and toss to coat"),
            Step(instruction: "Serve over rice")
        ]

        for (index, step) in steps.enumerated() {
            step.order = index
        }
        recipe.instructions = steps

        recipe.userTags = ["Dinner", "Chicken", "Chinese", "Quick"]
        recipe.imageURL = "https://placehold.co/400x300"

        return recipe
    }

    private static func createTomSoup() -> Recipe {
        let recipe = Recipe(title: "Creamy Tomato Soup", sourceType: .web_imported)
        recipe.servings = 6
        recipe.prepTime = 10
        recipe.cookTime = 30
        recipe.cuisine = "American"
        recipe.notes = "Perfect with grilled cheese!"
        recipe.timesCooked = 5
        recipe.lastMade = Calendar.current.date(byAdding: .day, value: -45, to: Date())

        let ingredients = [
            Ingredient(quantity: "2", unit: "cans", item: "crushed tomatoes", preparation: "28 oz each", section: nil),
            Ingredient(quantity: "1", unit: "cup", item: "heavy cream", preparation: nil, section: nil),
            Ingredient(quantity: "1", unit: nil, item: "onion", preparation: "diced", section: nil),
            Ingredient(quantity: "3", unit: "cloves", item: "garlic", preparation: "minced", section: nil),
            Ingredient(quantity: "2", unit: "cups", item: "vegetable broth", preparation: nil, section: nil)
        ]

        for (index, ingredient) in ingredients.enumerated() {
            ingredient.order = index
        }
        recipe.ingredients = ingredients

        let steps = [
            Step(instruction: "Sauté onion and garlic in olive oil until soft"),
            Step(instruction: "Add crushed tomatoes and broth"),
            Step(instruction: "Simmer for 20 minutes"),
            Step(instruction: "Blend until smooth"),
            Step(instruction: "Stir in heavy cream and season to taste")
        ]

        for (index, step) in steps.enumerated() {
            step.order = index
        }
        recipe.instructions = steps

        recipe.userTags = ["Soup", "Vegetarian", "Comfort Food"]
        recipe.imageURL = "https://placehold.co/400x300"

        return recipe
    }

    private static func createQuickPickles() -> Recipe {
        let recipe = Recipe(title: "Quick Pickles", sourceType: .manual)
        recipe.servings = 4
        recipe.prepTime = 10
        recipe.cookTime = 0
        recipe.cuisine = "American"
        recipe.notes = "Refrigerate for 2 hours before serving"
        recipe.timesCooked = 0

        let ingredients = [
            Ingredient(quantity: "2", unit: nil, item: "cucumbers", preparation: "sliced", section: nil),
            Ingredient(quantity: "1", unit: "cup", item: "white vinegar", preparation: nil, section: nil),
            Ingredient(quantity: "1", unit: "cup", item: "water", preparation: nil, section: nil),
            Ingredient(quantity: "2", unit: "tbsp", item: "sugar", preparation: nil, section: nil),
            Ingredient(quantity: "1", unit: "tbsp", item: "salt", preparation: nil, section: nil)
        ]

        for (index, ingredient) in ingredients.enumerated() {
            ingredient.order = index
        }
        recipe.ingredients = ingredients

        let steps = [
            Step(instruction: "Slice cucumbers thinly"),
            Step(instruction: "Heat vinegar, water, sugar, and salt until dissolved"),
            Step(instruction: "Pour hot liquid over cucumbers in jar"),
            Step(instruction: "Let cool, then refrigerate for at least 2 hours")
        ]

        for (index, step) in steps.enumerated() {
            step.order = index
        }
        recipe.instructions = steps

        recipe.userTags = ["Side Dish", "Vegetarian", "Quick"]
        recipe.imageURL = "https://placehold.co/400x300"

        return recipe
    }

    private static func createBeefBurgers() -> Recipe {
        let recipe = Recipe(title: "Classic Beef Burgers", sourceType: .manual)
        recipe.servings = 4
        recipe.prepTime = 10
        recipe.cookTime = 15
        recipe.cuisine = "American"
        recipe.isFavorite = false
        recipe.timesCooked = 8
        recipe.lastMade = Calendar.current.date(byAdding: .day, value: -15, to: Date())

        let ingredients = [
            Ingredient(quantity: "1.5", unit: "lb", item: "ground beef", preparation: "80/20", section: nil),
            Ingredient(quantity: "4", unit: nil, item: "burger buns", preparation: nil, section: nil),
            Ingredient(quantity: "1", unit: "tsp", item: "salt", preparation: nil, section: nil),
            Ingredient(quantity: "1/2", unit: "tsp", item: "black pepper", preparation: nil, section: nil)
        ]

        for (index, ingredient) in ingredients.enumerated() {
            ingredient.order = index
        }
        recipe.ingredients = ingredients

        let steps = [
            Step(instruction: "Form beef into 4 equal patties"),
            Step(instruction: "Season both sides with salt and pepper"),
            Step(instruction: "Grill or pan-fry over high heat for 4-5 minutes per side"),
            Step(instruction: "Let rest for 2 minutes before serving")
        ]

        for (index, step) in steps.enumerated() {
            step.order = index
        }
        recipe.instructions = steps

        recipe.userTags = ["Beef", "Grilling", "Sandwich"]
        recipe.imageURL = "https://placehold.co/400x300"

        return recipe
    }

    private static func createVegetarianChili() -> Recipe {
        let recipe = Recipe(title: "Hearty Vegetarian Chili", sourceType: .manual)
        recipe.servings = 8
        recipe.prepTime = 15
        recipe.cookTime = 45
        recipe.cuisine = "Mexican"
        recipe.notes = "Freezes well, vegan-friendly"
        recipe.isFavorite = true
        recipe.timesCooked = 6
        recipe.lastMade = Calendar.current.date(byAdding: .day, value: -60, to: Date())

        let ingredients = [
            Ingredient(quantity: "2", unit: "cans", item: "black beans", preparation: "drained", section: nil),
            Ingredient(quantity: "1", unit: "can", item: "kidney beans", preparation: "drained", section: nil),
            Ingredient(quantity: "1", unit: "can", item: "diced tomatoes", preparation: nil, section: nil),
            Ingredient(quantity: "1", unit: nil, item: "onion", preparation: "diced", section: nil),
            Ingredient(quantity: "2", unit: "tbsp", item: "chili powder", preparation: nil, section: nil)
        ]

        for (index, ingredient) in ingredients.enumerated() {
            ingredient.order = index
        }
        recipe.ingredients = ingredients

        let steps = [
            Step(instruction: "Sauté onion until soft"),
            Step(instruction: "Add beans, tomatoes, and chili powder"),
            Step(instruction: "Simmer for 45 minutes"),
            Step(instruction: "Adjust seasonings to taste")
        ]

        for (index, step) in steps.enumerated() {
            step.order = index
        }
        recipe.instructions = steps

        recipe.userTags = ["Vegetarian", "Mexican", "Comfort Food", "Vegan"]
        recipe.imageURL = "https://placehold.co/400x300"

        return recipe
    }

    private static func createPadThai() -> Recipe {
        let recipe = Recipe(title: "Pad Thai", sourceType: .web_imported)
        recipe.servings = 4
        recipe.prepTime = 20
        recipe.cookTime = 15
        recipe.cuisine = "Thai"
        recipe.notes = "Authentic Thai street food"
        recipe.timesCooked = 0

        let ingredients = [
            Ingredient(quantity: "8", unit: "oz", item: "rice noodles", preparation: nil, section: nil),
            Ingredient(quantity: "1", unit: "lb", item: "shrimp", preparation: "peeled", section: nil),
            Ingredient(quantity: "3", unit: "tbsp", item: "fish sauce", preparation: nil, section: nil),
            Ingredient(quantity: "2", unit: "tbsp", item: "tamarind paste", preparation: nil, section: nil),
            Ingredient(quantity: "1/4", unit: "cup", item: "peanuts", preparation: "crushed", section: nil)
        ]

        for (index, ingredient) in ingredients.enumerated() {
            ingredient.order = index
        }
        recipe.ingredients = ingredients

        let steps = [
            Step(instruction: "Soak rice noodles in hot water for 30 minutes"),
            Step(instruction: "Stir-fry shrimp until pink"),
            Step(instruction: "Add drained noodles and sauce"),
            Step(instruction: "Toss until well coated"),
            Step(instruction: "Top with peanuts and serve")
        ]

        for (index, step) in steps.enumerated() {
            step.order = index
        }
        recipe.instructions = steps

        recipe.userTags = ["Thai", "Noodles", "Seafood"]
        recipe.imageURL = "https://placehold.co/400x300"

        return recipe
    }

    private static func createFrenchOnionSoup() -> Recipe {
        let recipe = Recipe(title: "French Onion Soup", sourceType: .manual)
        recipe.servings = 6
        recipe.prepTime = 20
        recipe.cookTime = 60
        recipe.cuisine = "French"
        recipe.notes = "Classic French bistro dish"
        recipe.isFavorite = true
        recipe.timesCooked = 3
        recipe.lastMade = Calendar.current.date(byAdding: .day, value: -150, to: Date())

        let ingredients = [
            Ingredient(quantity: "6", unit: nil, item: "onions", preparation: "thinly sliced", section: nil),
            Ingredient(quantity: "4", unit: "cups", item: "beef broth", preparation: nil, section: nil),
            Ingredient(quantity: "1", unit: "cup", item: "white wine", preparation: nil, section: nil),
            Ingredient(quantity: "6", unit: "slices", item: "French bread", preparation: "toasted", section: nil),
            Ingredient(quantity: "1", unit: "cup", item: "Gruyère cheese", preparation: "grated", section: nil)
        ]

        for (index, ingredient) in ingredients.enumerated() {
            ingredient.order = index
        }
        recipe.ingredients = ingredients

        let steps = [
            Step(instruction: "Caramelize onions slowly over low heat for 45 minutes"),
            Step(instruction: "Add wine and simmer until reduced"),
            Step(instruction: "Add broth and simmer for 15 minutes"),
            Step(instruction: "Ladle into oven-safe bowls"),
            Step(instruction: "Top with bread and cheese, broil until golden")
        ]

        for (index, step) in steps.enumerated() {
            step.order = index
        }
        recipe.instructions = steps

        recipe.userTags = ["Soup", "French", "Comfort Food"]
        recipe.imageURL = "https://placehold.co/400x300"

        return recipe
    }

    private static func createBakedSalmon() -> Recipe {
        let recipe = Recipe(title: "Simple Baked Salmon", sourceType: .manual)
        recipe.servings = 4
        recipe.prepTime = 5
        recipe.cookTime = 20
        recipe.cuisine = "American"
        recipe.notes = "Healthy and quick"
        recipe.timesCooked = 10
        recipe.lastMade = Calendar.current.date(byAdding: .day, value: -8, to: Date())

        let ingredients = [
            Ingredient(quantity: "4", unit: nil, item: "salmon fillets", preparation: "6 oz each", section: nil),
            Ingredient(quantity: "2", unit: "tbsp", item: "olive oil", preparation: nil, section: nil),
            Ingredient(quantity: "2", unit: nil, item: "lemons", preparation: "sliced", section: nil),
            Ingredient(quantity: "1", unit: "tsp", item: "salt", preparation: nil, section: nil),
            Ingredient(quantity: "1/2", unit: "tsp", item: "black pepper", preparation: nil, section: nil)
        ]

        for (index, ingredient) in ingredients.enumerated() {
            ingredient.order = index
        }
        recipe.ingredients = ingredients

        let steps = [
            Step(instruction: "Preheat oven to 400°F"),
            Step(instruction: "Place salmon on baking sheet"),
            Step(instruction: "Drizzle with olive oil, season with salt and pepper"),
            Step(instruction: "Top with lemon slices"),
            Step(instruction: "Bake for 15-20 minutes until cooked through")
        ]

        for (index, step) in steps.enumerated() {
            step.order = index
        }
        recipe.instructions = steps

        recipe.userTags = ["Seafood", "Healthy", "Quick"]
        recipe.imageURL = "https://placehold.co/400x300"

        return recipe
    }

    private static func createChickenParmesan() -> Recipe {
        let recipe = Recipe(title: "Chicken Parmesan", sourceType: .web_imported)
        recipe.servings = 4
        recipe.prepTime = 20
        recipe.cookTime = 30
        recipe.cuisine = "Italian"
        recipe.notes = "Classic Italian-American comfort food"
        recipe.isFavorite = false
        recipe.timesCooked = 4
        recipe.lastMade = Calendar.current.date(byAdding: .day, value: -35, to: Date())

        let ingredients = [
            Ingredient(quantity: "4", unit: nil, item: "chicken breasts", preparation: "pounded thin", section: nil),
            Ingredient(quantity: "1", unit: "cup", item: "breadcrumbs", preparation: nil, section: nil),
            Ingredient(quantity: "1", unit: "cup", item: "marinara sauce", preparation: nil, section: nil),
            Ingredient(quantity: "1", unit: "cup", item: "mozzarella cheese", preparation: "shredded", section: nil),
            Ingredient(quantity: "1/2", unit: "cup", item: "parmesan cheese", preparation: "grated", section: nil)
        ]

        for (index, ingredient) in ingredients.enumerated() {
            ingredient.order = index
        }
        recipe.ingredients = ingredients

        let steps = [
            Step(instruction: "Coat chicken in breadcrumbs"),
            Step(instruction: "Pan-fry until golden brown on both sides"),
            Step(instruction: "Top with marinara and cheeses"),
            Step(instruction: "Bake at 375°F for 15 minutes until cheese melts")
        ]

        for (index, step) in steps.enumerated() {
            step.order = index
        }
        recipe.instructions = steps

        recipe.userTags = ["Chicken", "Italian", "Comfort Food"]
        recipe.imageURL = "https://placehold.co/400x300"

        return recipe
    }

    private static func createVeganCurry() -> Recipe {
        let recipe = Recipe(title: "Coconut Vegetable Curry", sourceType: .manual)
        recipe.servings = 6
        recipe.prepTime = 15
        recipe.cookTime = 30
        recipe.cuisine = "Thai"
        recipe.notes = "Vegan, gluten-free, can be made mild or spicy"
        recipe.timesCooked = 0

        let ingredients = [
            Ingredient(quantity: "1", unit: "can", item: "coconut milk", preparation: nil, section: nil),
            Ingredient(quantity: "2", unit: "tbsp", item: "red curry paste", preparation: nil, section: nil),
            Ingredient(quantity: "2", unit: "cups", item: "mixed vegetables", preparation: "chopped", section: nil),
            Ingredient(quantity: "1", unit: "cup", item: "chickpeas", preparation: "cooked", section: nil),
            Ingredient(quantity: "2", unit: "tbsp", item: "soy sauce", preparation: nil, section: nil)
        ]

        for (index, ingredient) in ingredients.enumerated() {
            ingredient.order = index
        }
        recipe.ingredients = ingredients

        let steps = [
            Step(instruction: "Sauté curry paste in a little coconut milk"),
            Step(instruction: "Add vegetables and cook for 5 minutes"),
            Step(instruction: "Add remaining coconut milk and chickpeas"),
            Step(instruction: "Simmer for 20 minutes"),
            Step(instruction: "Stir in soy sauce and serve over rice")
        ]

        for (index, step) in steps.enumerated() {
            step.order = index
        }
        recipe.instructions = steps

        recipe.userTags = ["Vegan", "Thai", "Healthy"]
        recipe.imageURL = "https://placehold.co/400x300"

        return recipe
    }

    private static func createQuickOmelette() -> Recipe {
        let recipe = Recipe(title: "Quick Cheese Omelette", sourceType: .manual)
        recipe.servings = 1
        recipe.prepTime = 2
        recipe.cookTime = 5
        recipe.cuisine = "French"
        recipe.notes = "Perfect breakfast!"
        recipe.timesCooked = 25
        recipe.lastMade = Calendar.current.date(byAdding: .day, value: -2, to: Date())

        let ingredients = [
            Ingredient(quantity: "3", unit: nil, item: "eggs", preparation: nil, section: nil),
            Ingredient(quantity: "1/4", unit: "cup", item: "cheese", preparation: "shredded", section: nil),
            Ingredient(quantity: "1", unit: "tbsp", item: "butter", preparation: nil, section: nil),
            Ingredient(quantity: "1", unit: "pinch", item: "salt", preparation: nil, section: nil)
        ]

        for (index, ingredient) in ingredients.enumerated() {
            ingredient.order = index
        }
        recipe.ingredients = ingredients

        let steps = [
            Step(instruction: "Beat eggs with salt"),
            Step(instruction: "Melt butter in non-stick pan over medium heat"),
            Step(instruction: "Pour in eggs, cook until almost set"),
            Step(instruction: "Add cheese to one half"),
            Step(instruction: "Fold omelette and serve immediately")
        ]

        for (index, step) in steps.enumerated() {
            step.order = index
        }
        recipe.instructions = steps

        recipe.userTags = ["Breakfast", "Eggs", "Quick", "French"]
        recipe.imageURL = "https://placehold.co/400x300"

        return recipe
    }

    private static func createSlowCookerRoast() -> Recipe {
        let recipe = Recipe(title: "Slow Cooker Pot Roast", sourceType: .web_imported)
        recipe.servings = 8
        recipe.prepTime = 15
        recipe.cookTime = 480 // 8 hours
        recipe.cuisine = "American"
        recipe.notes = "Perfect for Sunday dinner, low maintenance"
        recipe.isFavorite = true
        recipe.timesCooked = 5
        recipe.lastMade = Calendar.current.date(byAdding: .day, value: -90, to: Date())

        let ingredients = [
            Ingredient(quantity: "3", unit: "lb", item: "beef chuck roast", preparation: nil, section: nil),
            Ingredient(quantity: "4", unit: nil, item: "carrots", preparation: "cut into chunks", section: nil),
            Ingredient(quantity: "4", unit: nil, item: "potatoes", preparation: "quartered", section: nil),
            Ingredient(quantity: "1", unit: nil, item: "onion", preparation: "quartered", section: nil),
            Ingredient(quantity: "2", unit: "cups", item: "beef broth", preparation: nil, section: nil)
        ]

        for (index, ingredient) in ingredients.enumerated() {
            ingredient.order = index
        }
        recipe.ingredients = ingredients

        let steps = [
            Step(instruction: "Place roast in slow cooker"),
            Step(instruction: "Add vegetables around roast"),
            Step(instruction: "Pour broth over everything"),
            Step(instruction: "Cook on low for 8 hours or high for 4-5 hours"),
            Step(instruction: "Shred meat and serve with vegetables")
        ]

        for (index, step) in steps.enumerated() {
            step.order = index
        }
        recipe.instructions = steps

        recipe.userTags = ["Beef", "Slow Cooker", "Comfort Food"]
        recipe.imageURL = "https://placehold.co/400x300"

        return recipe
    }

    private static func createCapreseSalad() -> Recipe {
        let recipe = Recipe(title: "Caprese Salad", sourceType: .manual)
        recipe.servings = 4
        recipe.prepTime = 10
        recipe.cookTime = 0
        recipe.cuisine = "Italian"
        recipe.notes = "Fresh summer salad, no cooking required"
        recipe.timesCooked = 0

        let ingredients = [
            Ingredient(quantity: "4", unit: nil, item: "tomatoes", preparation: "sliced", section: nil),
            Ingredient(quantity: "8", unit: "oz", item: "fresh mozzarella", preparation: "sliced", section: nil),
            Ingredient(quantity: "1", unit: "bunch", item: "fresh basil", preparation: nil, section: nil),
            Ingredient(quantity: "2", unit: "tbsp", item: "olive oil", preparation: "extra virgin", section: nil),
            Ingredient(quantity: "1", unit: "tbsp", item: "balsamic vinegar", preparation: nil, section: nil)
        ]

        for (index, ingredient) in ingredients.enumerated() {
            ingredient.order = index
        }
        recipe.ingredients = ingredients

        let steps = [
            Step(instruction: "Arrange tomato and mozzarella slices on a platter"),
            Step(instruction: "Tuck basil leaves between slices"),
            Step(instruction: "Drizzle with olive oil and balsamic vinegar"),
            Step(instruction: "Season with salt and pepper"),
            Step(instruction: "Serve immediately")
        ]

        for (index, step) in steps.enumerated() {
            step.order = index
        }
        recipe.instructions = steps

        recipe.userTags = ["Salad", "Italian", "Vegetarian", "Quick"]
        recipe.imageURL = "https://placehold.co/400x300"

        return recipe
    }

    private static func createSpicyRamen() -> Recipe {
        let recipe = Recipe(title: "Spicy Miso Ramen", sourceType: .manual)
        recipe.servings = 2
        recipe.prepTime = 10
        recipe.cookTime = 20
        recipe.cuisine = "Japanese"
        recipe.notes = "Customize spice level to taste"
        recipe.timesCooked = 7
        recipe.lastMade = Calendar.current.date(byAdding: .day, value: -12, to: Date())

        let ingredients = [
            Ingredient(quantity: "2", unit: "packs", item: "ramen noodles", preparation: nil, section: nil),
            Ingredient(quantity: "4", unit: "cups", item: "chicken broth", preparation: nil, section: nil),
            Ingredient(quantity: "2", unit: "tbsp", item: "miso paste", preparation: nil, section: nil),
            Ingredient(quantity: "1", unit: "tbsp", item: "chili oil", preparation: nil, section: nil),
            Ingredient(quantity: "2", unit: nil, item: "soft-boiled eggs", preparation: nil, section: nil)
        ]

        for (index, ingredient) in ingredients.enumerated() {
            ingredient.order = index
        }
        recipe.ingredients = ingredients

        let steps = [
            Step(instruction: "Bring broth to a simmer"),
            Step(instruction: "Whisk in miso paste and chili oil"),
            Step(instruction: "Cook noodles according to package"),
            Step(instruction: "Divide noodles into bowls"),
            Step(instruction: "Pour broth over noodles, top with soft-boiled eggs")
        ]

        for (index, step) in steps.enumerated() {
            step.order = index
        }
        recipe.instructions = steps

        recipe.userTags = ["Japanese", "Noodles", "Spicy"]
        recipe.imageURL = "https://placehold.co/400x300"

        return recipe
    }

    private static func createLemonTart() -> Recipe {
        let recipe = Recipe(title: "French Lemon Tart", sourceType: .web_imported)
        recipe.servings = 8
        recipe.prepTime = 30
        recipe.cookTime = 45
        recipe.cuisine = "French"
        recipe.notes = "Elegant dessert, best served chilled"
        recipe.isFavorite = true
        recipe.timesCooked = 2
        recipe.lastMade = Calendar.current.date(byAdding: .day, value: -180, to: Date())

        let ingredients = [
            Ingredient(quantity: "1", unit: nil, item: "pre-made tart crust", preparation: nil, section: nil),
            Ingredient(quantity: "4", unit: nil, item: "eggs", preparation: nil, section: nil),
            Ingredient(quantity: "1", unit: "cup", item: "sugar", preparation: nil, section: nil),
            Ingredient(quantity: "1/2", unit: "cup", item: "lemon juice", preparation: "fresh", section: nil),
            Ingredient(quantity: "1/4", unit: "cup", item: "butter", preparation: "melted", section: nil)
        ]

        for (index, ingredient) in ingredients.enumerated() {
            ingredient.order = index
        }
        recipe.ingredients = ingredients

        let steps = [
            Step(instruction: "Preheat oven to 350°F"),
            Step(instruction: "Blind bake tart crust for 15 minutes"),
            Step(instruction: "Whisk eggs, sugar, lemon juice, and melted butter"),
            Step(instruction: "Pour filling into baked crust"),
            Step(instruction: "Bake for 30 minutes until set"),
            Step(instruction: "Chill for 2 hours before serving")
        ]

        for (index, step) in steps.enumerated() {
            step.order = index
        }
        recipe.instructions = steps

        recipe.userTags = ["Dessert", "French", "Baking"]
        recipe.imageURL = "https://placehold.co/400x300"

        return recipe
    }
}
