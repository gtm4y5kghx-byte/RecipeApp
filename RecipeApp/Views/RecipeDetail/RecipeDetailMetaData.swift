import SwiftUI

struct RecipeDetailMetaData: View {
    let totalTime: Int?
    let servings: Int?
    let cuisine: String?
    let sourceURL: String?
    
    var body: some View {
        DSSection {
            HStack(spacing: Theme.Spacing.sm) {
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
            }
            
            if let sourceURL = sourceURL {
                VStack(alignment: .leading) {
                    DSLabel(sourceURL, style: .subheadline, color: .secondary)
                }
            }
        }
    }
}
