import SwiftUI

struct OnboardingWelcomePage: View {

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()

            DSIcon("fork.knife", size: .xlarge, color: .adaptiveBrand)
                .padding(Theme.Spacing.lg)
                .background(Theme.Colors.backgroundLight)
                .clipShape(Circle())

            DSLabel("Welcome", style: .largeTitle, color: .primary, alignment: .center)

            DSLabel("Your personal recipe companion", style: .title3, color: .secondary, alignment: .center)
                .padding(.horizontal, Theme.Spacing.xl)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }
}

#Preview {
    OnboardingWelcomePage()
}