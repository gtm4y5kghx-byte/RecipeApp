import SwiftUI

struct CookingModeStepsSheet: View {
    let stepItems: [CookingModeViewModel.StepItem]
    let currentIndex: Int
    let onSelectStep: (Int) -> Void
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                DSSection("Instructions", titleColor: .accent, verticalPadding: Theme.Spacing.md) {
                    ForEach(Array(stepItems.enumerated()), id: \.element.id) { index, item in
                        Button {
                            onSelectStep(item.id)
                        } label: {
                            DSLabel(
                                item.step.instruction,
                                style: item.id == currentIndex ? .headline : .body,
                                color: item.id == currentIndex ? .accent : .secondary
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("cooking-mode-step-\(item.id)-button")

                        if index < stepItems.count - 1 {
                            DSDivider(thickness: .thin, color: .subtle, spacing: .compact)
                                .opacity(0.7)
                        }
                    }
                }
            }
            .background(Theme.Colors.background)
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
