import SwiftUI

struct CookingModeStepCard: View {
    let item: CookingModeViewModel.StepItem
    
    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            DSLabel(item.label, style: .metadata, color: .accent, alignment: .center)

            DSLabel(item.step.instruction, style: .title2, alignment: .center)
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
