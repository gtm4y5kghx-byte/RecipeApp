import SwiftUI

struct RecipeDetailMetaData: View {
    let totalTime: Int?
    let servings: Int?
    let cuisine: String?
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            if let totalTime = totalTime {
                HStack(spacing: Theme.Spacing.xs) {
                    DSIcon("clock", size: .small, color: .secondary)
                    DSLabel("\(totalTime) min", style: .caption1, color: .secondary)
                }
            }
            
            if let servings = servings {
                HStack(spacing: Theme.Spacing.xs) {
                    DSIcon("person.2", size: .small, color: .secondary)
                    DSLabel("\(servings)", style: .caption1, color: .secondary)
                }
            }
            
            if let cuisine = cuisine {
                HStack(spacing: Theme.Spacing.xs) {
                    DSIcon("fork.knife", size: .small, color: .secondary)
                    DSLabel(cuisine, style: .caption1, color: .secondary)
                }
            }
            
            Spacer()
        }
        .padding(Theme.Spacing.md)
    }
}
