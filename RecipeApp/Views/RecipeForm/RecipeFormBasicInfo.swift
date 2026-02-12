import SwiftUI

struct RecipeFormBasicInfo : View {
    @Binding var title: String
    @Binding var servings: String
    @Binding var prepTime: String
    @Binding var cookTime: String
    @Binding var cuisine: String
    
    var body: some View {
        DSSection("Basic Info", titleColor: .brand, spacing: Theme.Spacing.md, titleSpacing: Theme.Spacing.xs) {
            DSFormField(
                label: "Title",
                placeholder: "Enter recipe name",
                text: $title,
                icon: "text.alignleft",
                isRequired: true,
                helperText: "Give your recipe a descriptive name",
                accessibilityID: "recipe-form-title-field"
            )

            DSFormField(
                label: "Cuisine Type",
                placeholder: "Italian",
                text: $cuisine,
                icon: "fork.knife",
                helperText: "e.g., Italian, Mexican, Thai",
                accessibilityID: "recipe-form-cuisine-field"
            )

            DSFormField(
                label: "Servings",
                placeholder: "4",
                text: $servings,
                icon: "person.2",
                keyboardType: .numberPad,
                accessibilityID: "recipe-form-servings-field"
            )

            DSFormField(
                label: "Prep Time",
                placeholder: "15 minutes",
                text: $prepTime,
                icon: "clock",
                keyboardType: .numberPad,
                accessibilityID: "recipe-form-prep-time-field"
            )

            DSFormField(
                label: "Cook Time",
                placeholder: "30 minutes",
                text: $cookTime,
                icon: "timer",
                keyboardType: .numberPad,
                accessibilityID: "recipe-form-cook-time-field"
            )
        }
    }
}
