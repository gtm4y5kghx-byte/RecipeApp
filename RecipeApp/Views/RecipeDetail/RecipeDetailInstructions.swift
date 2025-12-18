import SwiftUI
import SwiftData

struct RecipeDetailInstructions: View {
    let instructions: [Step]
    
    var body: some View {
        if !instructions.isEmpty {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                DSLabel("Instructions", style: .title2)
                    .padding(.horizontal, Theme.Spacing.md)
                
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    ForEach(Array(instructions.enumerated()), id: \.element.id) { index, step in
                        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                            DSLabel("\(index + 1).", style: .headline, color: .accent)
                                .frame(width: 32, alignment: .leading)
                            
                            DSLabel(step.instruction, style: .body, color: .primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                    }
                }
            }
            .padding(.vertical, Theme.Spacing.md)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, configurations: config)
    
    SampleData.loadSampleRecipes(into: container.mainContext)
    let recipes = try! container.mainContext.fetch(FetchDescriptor<Recipe>())
    
    return RecipeDetailInstructions(instructions: recipes[0].instructions)
        .modelContainer(container)
}
