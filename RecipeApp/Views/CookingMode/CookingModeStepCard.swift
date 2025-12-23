import SwiftUI

struct CookingModeStepCard: View {
    let item: CookingModeViewModel.StepItem
    
    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            DSLabel(item.label, style: .metadata, color: .secondary, alignment: .center)
            
            DSLabel(item.step.instruction, style: .title2, alignment: .center)
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
