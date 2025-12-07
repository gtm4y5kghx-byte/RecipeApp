import Testing
 @testable import RecipeApp

 @Suite("Ingredient Formatter Tests")
 struct IngredientFormatterTests {

     @Test("Format ingredient with all components")
     func testFullIngredient() {
         let ingredient = Ingredient(
             quantity: "2",
             unit: "cups",
             item: "flour",
             preparation: "sifted",
             section: nil
         )

         let result = IngredientFormatter.format(ingredient)

         #expect(result == "2 cups flour, sifted")
     }

     @Test("Format ingredient without preparation")
     func testIngredientWithoutPreparation() {
         let ingredient = Ingredient(
             quantity: "1",
             unit: "cup",
             item: "sugar",
             preparation: nil,
             section: nil
         )

         let result = IngredientFormatter.format(ingredient)

         #expect(result == "1 cup sugar")
     }

     @Test("Format ingredient without unit")
     func testIngredientWithoutUnit() {
         let ingredient = Ingredient(
             quantity: "3",
             unit: nil,
             item: "eggs",
             preparation: nil,
             section: nil
         )

         let result = IngredientFormatter.format(ingredient)

         #expect(result == "3 eggs")
     }

     @Test("Format ingredient without quantity")
     func testIngredientWithoutQuantity() {
         let ingredient = Ingredient(
             quantity: "",
             unit: nil,
             item: "salt",
             preparation: "to taste",
             section: nil
         )

         let result = IngredientFormatter.format(ingredient)

         #expect(result == "salt, to taste")
     }

     @Test("Format ingredient with only item")
     func testMinimalIngredient() {
         let ingredient = Ingredient(
             quantity: "",
             unit: nil,
             item: "water",
             preparation: nil,
             section: nil
         )

         let result = IngredientFormatter.format(ingredient)

         #expect(result == "water")
     }
 }
