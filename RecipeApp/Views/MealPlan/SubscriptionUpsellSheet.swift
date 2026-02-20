import SwiftUI
import StoreKit

struct SubscriptionUpsellSheet: View {
    let subscriptionPrice: String?
    let premiumPrice: String?
    let isPurchasing: Bool
    let onSubscribe: () -> Void
    let onPurchasePremium: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()

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

            VStack(spacing: Theme.Spacing.sm) {
                if let price = subscriptionPrice {
                    SubscriptionCTA(
                        monthlyPrice: price,
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
            .padding(.horizontal, Theme.Spacing.lg)

            DSButton(title: "Maybe Later", style: .tertiary, action: onDismiss)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }
}

#Preview {
    SubscriptionUpsellSheet(
        subscriptionPrice: "$4.99",
        premiumPrice: "$29.99",
        isPurchasing: false,
        onSubscribe: {},
        onPurchasePremium: {},
        onDismiss: {}
    )
}

#Preview("Dark") {
    SubscriptionUpsellSheet(
        subscriptionPrice: "$4.99",
        premiumPrice: "$29.99",
        isPurchasing: false,
        onSubscribe: {},
        onPurchasePremium: {},
        onDismiss: {}
    )
    .preferredColorScheme(.dark)
}
