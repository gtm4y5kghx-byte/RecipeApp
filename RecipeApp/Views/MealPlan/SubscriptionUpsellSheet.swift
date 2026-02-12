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

            DSIcon("calendar.badge.plus", size: .xlarge, color: .accent)
                .padding(Theme.Spacing.xl)
                .background(Theme.Colors.backgroundLight)
                .clipShape(Circle())

            if hasPremium {
                premiumUserContent
            } else {
                freeUserContent
            }

            Spacer()

            subscribeButton
                .padding(.horizontal, Theme.Spacing.lg)

            DSButton(title: "Maybe Later", style: .tertiary, action: onDismiss)
                .padding(.bottom, Theme.Spacing.md)
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
            DSLabel("Unlock Everything", style: .largeTitle, color: .primary, alignment: .center)

            DSLabel(
                "Get the most out of your recipe collection with AI-powered features.",
                style: .body,
                color: .secondary,
                alignment: .center
            )
            .padding(.horizontal, Theme.Spacing.xl)

            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                featureRow(
                    icon: "calendar",
                    title: PremiumFeatureCopy.MealPlanning.title,
                    description: PremiumFeatureCopy.MealPlanning.description
                )
                featureRow(
                    icon: "sparkles",
                    title: PremiumFeatureCopy.Suggestions.title,
                    description: PremiumFeatureCopy.Suggestions.description
                )
                featureRow(
                    icon: "wand.and.stars",
                    title: PremiumFeatureCopy.Generation.title,
                    description: PremiumFeatureCopy.Generation.description
                )
            }
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.top, Theme.Spacing.md)
        }
    }

    @ViewBuilder
    private var subscribeButton: some View {
        if hasPremium, let price = subscriptionPrice {
            DSButton(
                title: "Subscribe - \(price)/month",
                style: .primary,
                icon: "star.fill",
                fullWidth: true,
                action: onSubscribe
            )
            .disabled(isPurchasing)
        } else if let introPrice = introPrice, let monthlyPrice = subscriptionPrice {
            VStack(spacing: Theme.Spacing.xs) {
                DSButton(
                    title: "Subscribe - \(introPrice) first month",
                    style: .primary,
                    icon: "star.fill",
                    fullWidth: true,
                    action: onSubscribe
                )
                .disabled(isPurchasing)

                DSLabel("Includes lifetime Premium access", style: .caption1, color: .secondary, alignment: .center)
                    .padding(.top, Theme.Spacing.xs)
                DSLabel("Then \(monthlyPrice)/month for Meal Planning", style: .caption1, color: .secondary, alignment: .center)
            }
        } else if let price = subscriptionPrice {
            DSButton(
                title: "Subscribe - \(price)/month",
                style: .primary,
                icon: "star.fill",
                fullWidth: true,
                action: onSubscribe
            )
            .disabled(isPurchasing)
        }
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: Theme.Spacing.md) {
            DSIcon(icon, size: .medium, color: .adaptiveBrand)
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                DSLabel(title, style: .headline)
                DSLabel(description, style: .subheadline, color: .secondary)
            }
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
