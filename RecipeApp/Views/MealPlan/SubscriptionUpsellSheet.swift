import SwiftUI
import StoreKit

struct SubscriptionUpsellSheet: View {
    let subscriptionPrice: String?
    let introPrice: String?
    let hasPremium: Bool
    let isPurchasing: Bool
    let onSubscribe: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()

            if hasPremium {
                premiumUserContent
            } else {
                freeUserContent
            }

            subscribeButton
                .padding(.horizontal, Theme.Spacing.lg)

            DSButton(title: "Maybe Later", style: .tertiary, action: onDismiss)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }

    private var premiumUserContent: some View {
        VStack(spacing: Theme.Spacing.md) {
            DSLabel(PremiumFeatureCopy.MealPlanning.title, style: .largeTitle, color: .primary, alignment: .center)

            DSLabel(
                PremiumFeatureCopy.MealPlanning.description,
                style: .body,
                color: .secondary,
                alignment: .center
            )
            .padding(.horizontal, Theme.Spacing.xl)
        }
    }

    private var freeUserContent: some View {
        VStack(spacing: Theme.Spacing.md) {
            VStack(spacing: Theme.Spacing.xs) {
                DSLabel("Unlock Everything", style: .largeTitle, color: .primary, alignment: .center)

                DSLabel(
                    "Get the most out of your recipe collection with AI-powered features.",
                    style: .body,
                    color: .secondary,
                    alignment: .center
                )
                .padding(.horizontal, Theme.Spacing.xl)
            }

            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                PremiumFeatureRow.mealPlanning
                PremiumFeatureRow.suggestions
                PremiumFeatureRow.generation
            }
            .padding(.horizontal, Theme.Spacing.xl)
        }
    }

    @ViewBuilder
    private var subscribeButton: some View {
        if hasPremium, let price = subscriptionPrice {
            DSButton(
                title: "Subscribe - \(price)/month",
                style: .primary,
                fullWidth: true,
                action: onSubscribe
            )
            .disabled(isPurchasing)
        } else if let introPrice = introPrice, let monthlyPrice = subscriptionPrice {
            SubscriptionCTA(
                introPrice: introPrice,
                monthlyPrice: monthlyPrice,
                isPurchasing: isPurchasing,
                onSubscribe: onSubscribe
            )
        } else if let price = subscriptionPrice {
            DSButton(
                title: "Subscribe - \(price)/month",
                style: .primary,
                fullWidth: true,
                action: onSubscribe
            )
            .disabled(isPurchasing)
        }
    }

}

#Preview("Free User") {
    SubscriptionUpsellSheet(
        subscriptionPrice: "$4.99",
        introPrice: "$19.99",
        hasPremium: false,
        isPurchasing: false,
        onSubscribe: {},
        onDismiss: {}
    )
}

#Preview("Premium User") {
    SubscriptionUpsellSheet(
        subscriptionPrice: "$4.99",
        introPrice: nil,
        hasPremium: true,
        isPurchasing: false,
        onSubscribe: {},
        onDismiss: {}
    )
}

#Preview("Dark: Free User") {
    SubscriptionUpsellSheet(
        subscriptionPrice: "$4.99",
        introPrice: "$19.99",
        hasPremium: false,
        isPurchasing: false,
        onSubscribe: {},
        onDismiss: {}
    )
    .preferredColorScheme(.dark)
}

#Preview("Dark: Premium User") {
    SubscriptionUpsellSheet(
        subscriptionPrice: "$4.99",
        introPrice: nil,
        hasPremium: true,
        isPurchasing: false,
        onSubscribe: {},
        onDismiss: {}
    )
    .preferredColorScheme(.dark)
}
