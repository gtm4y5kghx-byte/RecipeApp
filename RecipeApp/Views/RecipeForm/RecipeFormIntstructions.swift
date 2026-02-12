import SwiftUI

struct RecipeFormIntstructions : View {
    @Binding var instructions: [String]
    let onAdd: () -> Void
    let onRemove: (Int) -> Void
    
    var body: some View {
        DSSection("Instructions", titleColor: .brand, spacing: Theme.Spacing.md, titleSpacing: Theme.Spacing.xs) {
            ForEach(instructions.indices, id: \.self) { index in
                HStack {
                    DSTextField(
                        placeholder: "Enter instruction",
                        text: $instructions[index],
                        accessibilityID: "recipe-form-instruction-\(index)-field"
                    )
                    
                    if instructions.count > 1 {
                        DSIconButton(
                            "minus.circle.fill",
                            size: .medium,
                            color: .brand,
                            accessibilityID: "remove-step-\(index)"
                        ) {
                            onRemove(index)
                        }
                    }
                }
            }
            
            DSIconButton(
                "plus.circle.fill",
                size: .medium,
                color: .brand,
                accessibilityID: "add-step"
            ) {
                onAdd()
            }
        }
    }
}
