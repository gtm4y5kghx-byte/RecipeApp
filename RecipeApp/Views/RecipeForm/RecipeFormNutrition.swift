import SwiftUI

struct RecipeFormNutrition: View {
    @Binding var calories: String
    @Binding var protein: String
    @Binding var carbohydrates: String
    @Binding var fat: String
    @Binding var fiber: String
    @Binding var sodium: String
    @Binding var sugar: String

    var body: some View {
        DSSection("Nutrition (per serving)") {
            DSFormField(
                label: "Calories",
                placeholder: "320",
                text: $calories,
                icon: "flame",
                keyboardType: .numberPad,
                accessibilityID: "recipe-form-calories-field"
            )

            DSFormField(
                label: "Protein",
                placeholder: "12",
                text: $protein,
                icon: "leaf",
                keyboardType: .numberPad,
                helperText: "grams",
                accessibilityID: "recipe-form-protein-field"
            )

            DSFormField(
                label: "Carbohydrates",
                placeholder: "45",
                text: $carbohydrates,
                icon: "circle.grid.3x3",
                keyboardType: .numberPad,
                helperText: "grams",
                accessibilityID: "recipe-form-carbs-field"
            )

            DSFormField(
                label: "Fat",
                placeholder: "14",
                text: $fat,
                icon: "drop",
                keyboardType: .numberPad,
                helperText: "grams",
                accessibilityID: "recipe-form-fat-field"
            )

            DSFormField(
                label: "Fiber",
                placeholder: "3",
                text: $fiber,
                icon: "leaf.arrow.circlepath",
                keyboardType: .numberPad,
                helperText: "grams",
                accessibilityID: "recipe-form-fiber-field"
            )

            DSFormField(
                label: "Sugar",
                placeholder: "8",
                text: $sugar,
                icon: "cube",
                keyboardType: .numberPad,
                helperText: "grams",
                accessibilityID: "recipe-form-sugar-field"
            )

            DSFormField(
                label: "Sodium",
                placeholder: "400",
                text: $sodium,
                icon: "drop.triangle",
                keyboardType: .numberPad,
                helperText: "milligrams",
                accessibilityID: "recipe-form-sodium-field"
            )
        }
    }
}
