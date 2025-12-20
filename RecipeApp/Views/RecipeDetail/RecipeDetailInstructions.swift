import SwiftUI
import SwiftData

struct RecipeDetailInstructions: View {
    let instructions: [Step]
    
    var body: some View {
        if !instructions.isEmpty {
            DSSection("Instructions") {
                ForEach(Array(instructions.enumerated()), id: \.element.id) { index, step in
                    DSLabel(step.instruction, style: .body, color: .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
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
