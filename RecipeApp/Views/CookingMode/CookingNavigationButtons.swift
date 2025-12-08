import SwiftUI

struct CookingNavigationButtons: View {
    let isOnFinalStep: Bool
    let canGoToPrevious: Bool
    let canGoToNext: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onMarkAsCooked: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            if isOnFinalStep {
                Button("Mark as Cooked") {
                    onMarkAsCooked()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityIdentifier("mark-as-cooked-button")
            } else {
                Button("Previous") {
                    onPrevious()
                }
                .disabled(!canGoToPrevious)
                .accessibilityIdentifier("previous-step-button")

                Button("Next") {
                    onNext()
                }
                .accessibilityIdentifier("next-step-button")
            }
        }
        .buttonStyle(.borderedProminent)
        .font(.title3)
    }
}
