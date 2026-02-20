import SwiftUI

struct OnboardingPremiumPage: View {
    let subscriptionPrice: String?
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

            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                PremiumFeatureRow.suggestions
                PremiumFeatureRow.generation
                PremiumFeatureRow.mealPlanning
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

    @ViewBuilder
    private var purchaseButtons: some View {
        VStack(spacing: Theme.Spacing.sm) {
            if let monthlyPrice = subscriptionPrice {
                SubscriptionCTA(
                    monthlyPrice: monthlyPrice,
                    isPurchasing: isPurchasing,
                    onSubscribe: onSubscribe
                )
            }

            if let price = premiumPrice {
                PremiumPurchaseCTA(
                    price: price,
                    isPurchasing: isPurchasing,
                    onPurchase: onPurchasePremium
                )
            }
        }
    }
}

#Preview("With Prices") {
    OnboardingPremiumPage(
        subscriptionPrice: "$4.99",
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
        premiumPrice: "$14.99",
        isPurchasing: true,
        onSubscribe: {},
        onPurchasePremium: {},
        onSkip: {}
    )
}
