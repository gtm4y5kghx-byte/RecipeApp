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
                .scaleEffect(1.5)
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
            DSLabel("Add Meal Planning", style: .largeTitle, color: .primary, alignment: .center)

            DSLabel(
                "Generate AI-powered meal plans from your recipe collection.",
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

            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                featureRow("AI meal plan generation")
                featureRow("AI recipe suggestions")
                featureRow("Recipe generation")
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

                DSLabel("Then \(monthlyPrice)/month", style: .caption1, color: .tertiary, alignment: .center)
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

    private func featureRow(_ text: String) -> some View {
        HStack(spacing: Theme.Spacing.sm) {
            DSIcon("checkmark.circle.fill", size: .small, color: .success)
            DSLabel(text, style: .body, color: .primary)
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
