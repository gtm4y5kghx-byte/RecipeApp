import SwiftUI

struct RecipeFormIntstructions : View {
    @Binding var instructions: [String]
    let onAdd: () -> Void
    let onRemove: (Int) -> Void
    
    var body: some View {
        DSSection("Instructions", titleColor: .accent, spacing: Theme.Spacing.md) {
            ForEach(instructions.indices, id: \.self) { index in
                HStack {
                    DSFormField(
                        label: "Step \(index + 1)",
                        placeholder: "Enter instruction",
                        text: $instructions[index],
                        accessibilityID: "recipe-form-instruction-\(index)-field"
                    )
                    
                    if instructions.count > 1 {
                        DSButton(title: "Remove Instruction",
                                 style: .tertiary,
                                 icon: "minus.circle.fill",
                                 fullWidth: false
                        ) {
                            onRemove(index)
                        }
                    }
                }
            }
            
            DSButton(
                title: "Add Step",
                style: .tertiary,
                icon: "plus.circle.fill",
                fullWidth: false
            ) {
                onAdd()
            }
        }
    }
}
