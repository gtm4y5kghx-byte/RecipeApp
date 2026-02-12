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
        DSSection("Nutrition (per serving)", titleColor: .brand, spacing: Theme.Spacing.md, titleSpacing: Theme.Spacing.xs) {
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
                placeholder: "12g",
                text: $protein,
                icon: "leaf",
                keyboardType: .numberPad,
                accessibilityID: "recipe-form-protein-field"
            )

            DSFormField(
                label: "Carbohydrates",
                placeholder: "45g",
                text: $carbohydrates,
                icon: "circle.grid.3x3",
                keyboardType: .numberPad,
                accessibilityID: "recipe-form-carbs-field"
            )

            DSFormField(
                label: "Fat",
                placeholder: "14g",
                text: $fat,
                icon: "drop",
                keyboardType: .numberPad,
                accessibilityID: "recipe-form-fat-field"
            )

            DSFormField(
                label: "Fiber",
                placeholder: "3g",
                text: $fiber,
                icon: "leaf.arrow.circlepath",
                keyboardType: .numberPad,
                accessibilityID: "recipe-form-fiber-field"
            )

            DSFormField(
                label: "Sugar",
                placeholder: "8g",
                text: $sugar,
                icon: "cube",
                keyboardType: .numberPad,
                accessibilityID: "recipe-form-sugar-field"
            )

            DSFormField(
                label: "Sodium",
                placeholder: "400mg",
                text: $sodium,
                icon: "drop.triangle",
                keyboardType: .numberPad,
                accessibilityID: "recipe-form-sodium-field"
            )
        }
    }
}
