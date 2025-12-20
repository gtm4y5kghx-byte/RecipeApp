import SwiftUI

struct RecipeDetailMetaData: View {
    let totalTime: String?
    let servings: Int?
    let cuisine: String?
    
    var body: some View {
        VStack {
            HStack(spacing: Theme.Spacing.sm) {
                if let totalTime = totalTime {
                    HStack(spacing: Theme.Spacing.xs) {
                        DSIcon("clock", size: .small, color: .secondary)
                        DSLabel("\(totalTime)", style: .caption1, color: .secondary)
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
            }
        }
    }
}
