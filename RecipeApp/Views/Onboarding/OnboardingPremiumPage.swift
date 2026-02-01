import SwiftUI

struct OnboardingPremiumPage: View {
    let subscriptionPrice: String?
    let subscriptionIntroPrice: String?
    let premiumPrice: String?
    let isPurchasing: Bool
    let onSubscribe: () -> Void
    let onPurchasePremium: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()

            DSIcon("star.fill", size: .xlarge, color: .accent)
                .scaleEffect(1.5)
                .padding(Theme.Spacing.xl)
                .background(Theme.Colors.backgroundLight)
                .clipShape(Circle())

            DSLabel("Unlock Everything", style: .largeTitle, color: .primary, alignment: .center)

            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                featureRow("AI recipe suggestions")
                featureRow("Recipe generation")
                featureRow("Meal planning")
            }
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.top, Theme.Spacing.md)

            Spacer()

            purchaseButtons
                .padding(.horizontal, Theme.Spacing.lg)

            DSButton(title: "Maybe Later", style: .tertiary, action: onSkip)
                .padding(.bottom, Theme.Spacing.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }

    private func featureRow(_ text: String) -> some View {
        HStack(spacing: Theme.Spacing.sm) {
            DSIcon("checkmark.circle.fill", size: .small, color: .success)
            DSLabel(text, style: .body, color: .primary)
        }
    }

    @ViewBuilder
    private var purchaseButtons: some View {
        VStack(spacing: Theme.Spacing.sm) {
            if let introPrice = subscriptionIntroPrice, let monthlyPrice = subscriptionPrice {
                DSButton(
                    title: "Subscribe - \(introPrice) first month",
                    style: .primary,
                    icon: "star.fill",
                    fullWidth: true,
                    action: onSubscribe
                )
                .disabled(isPurchasing)

                DSLabel("Then \(monthlyPrice)/month", style: .caption1, color: .tertiary, alignment: .center)
            }

            if let price = premiumPrice {
                DSButton(
                    title: "Buy Premium - \(price)",
                    style: .secondary,
                    fullWidth: true,
                    action: onPurchasePremium
                )
                .disabled(isPurchasing)

                DSLabel("One-time purchase, no meal planning", style: .caption1, color: .tertiary, alignment: .center)
            }
        }
    }
}

#Preview("With Prices") {
    OnboardingPremiumPage(
        subscriptionPrice: "$4.99",
        subscriptionIntroPrice: "$19.99",
        premiumPrice: "$14.99",
        isPurchasing: false,
        onSubscribe: {},
        onPurchasePremium: {},
        onSkip: {}
    )
}

#Preview("Loading Prices") {
    OnboardingPremiumPage(
        subscriptionPrice: nil,
        subscriptionIntroPrice: nil,
        premiumPrice: nil,
        isPurchasing: false,
        onSubscribe: {},
        onPurchasePremium: {},
        onSkip: {}
    )
}

#Preview("Purchasing") {
    OnboardingPremiumPage(
        subscriptionPrice: "$4.99",
        subscriptionIntroPrice: "$19.99",
        premiumPrice: "$14.99",
        isPurchasing: true,
        onSubscribe: {},
        onPurchasePremium: {},
        onSkip: {}
    )
}
