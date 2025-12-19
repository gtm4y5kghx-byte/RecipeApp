import SwiftUI

struct RecipeDetailNutrition: View {
    let nutrition: NutritionInfo?
    
    var body: some View {
        if let nutrition = nutrition {
            DSSection("Nutrition") {
                ForEach(nutrition.displayItems, id: \.label) { item in
                    HStack {
                        DSLabel(item.label)
                        Spacer()
                        DSLabel(item.value)
                    }
                }
            }
        }
    }
}
