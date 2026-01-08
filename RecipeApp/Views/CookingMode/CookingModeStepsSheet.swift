import SwiftUI

struct CookingModeStepsSheet: View {
    let stepItems: [CookingModeViewModel.StepItem]
    let currentIndex: Int
    let onSelectStep: (Int) -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            List(stepItems) { item in
                Button {
                    onSelectStep(item.id)
                } label: {
                    HStack {
                        DSLabel("\(item.id + 1).", style: .headline)
                        DSLabel(item.step.instruction, style: .body, color: .secondary)
                            .lineLimit(2)
                        Spacer()
                        if item.id == currentIndex {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Theme.Colors.primary)
                        }
                    }
                }
                .accessibilityIdentifier("cooking-mode-step-\(item.id)-button")
            }
            .navigationTitle("Steps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { onDismiss() }
                        .accessibilityIdentifier("cooking-mode-steps-done-button")
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
