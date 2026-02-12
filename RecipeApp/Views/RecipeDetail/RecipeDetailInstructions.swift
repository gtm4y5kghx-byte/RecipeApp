import SwiftUI
import SwiftData

struct RecipeDetailInstructions: View {
    let instructions: [Step]

    var body: some View {
        if !instructions.isEmpty {
            DSSection("Instructions", titleColor: .adaptiveBrand, verticalPadding: Theme.Spacing.md) {
                ForEach(Array(instructions.enumerated()), id: \.element.id) { index, step in
                    DSLabel(step.instruction, style: .body, color: .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if index < instructions.count - 1 {
                        DSDivider(thickness: .thin, color: .subtle, spacing: .compact)
                            .opacity(0.7)
                    }
                }
            }
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
