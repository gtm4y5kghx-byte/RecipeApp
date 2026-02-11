import SwiftUI

struct CookingModeStepCard: View {
    let item: CookingModeViewModel.StepItem
    
    var body: some View {
        DSLabel(item.step.instruction, style: .title2, alignment: .center)
            .padding(.horizontal, Theme.Spacing.lg)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
