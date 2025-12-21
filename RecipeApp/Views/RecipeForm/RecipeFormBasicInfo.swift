import SwiftUI

struct RecipeFormBasicInfo : View {
    @Binding var title: String
    @Binding var servings: String
    @Binding var prepTime: String
    @Binding var cookTime: String
    @Binding var cuisine: String
    
    var body: some View {
        DSSection("Basic Info") {
            DSFormField(
                label: "Title",
                placeholder: "Enter recipe name",
                text: $title,
                icon: "text.alignleft",
                isRequired: true,
                helperText: "Give your recipe a descriptive name"
            )
            
            DSFormField(
                label: "Cuisine Type",
                placeholder: "Italian",
                text: $cuisine,
                icon: "fork.knife",
                helperText: "e.g., Italian, Mexican, Thai"
            )
            
            DSFormField(
                label: "Servings",
                placeholder: "4",
                text: $servings,
                icon: "person.2",
                keyboardType: .numberPad
            )

            DSFormField(
                label: "Prep Time",
                placeholder: "15",
                text: $prepTime,
                icon: "clock",
                keyboardType: .numberPad,
            )
            
            DSFormField(
                label: "Cook Time",
                placeholder: "30",
                text: $cookTime,
                icon: "timer",
                keyboardType: .numberPad,
                helperText: "minutes"
            )
        }
    }
}
