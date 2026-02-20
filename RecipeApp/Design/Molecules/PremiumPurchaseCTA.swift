import SwiftUI

/// Shared premium one-time purchase call-to-action with button and price caption
struct PremiumPurchaseCTA: View {
    let price: String
    let isPurchasing: Bool
    let onPurchase: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            DSButton(
                title: "Buy Premium - \(price)",
                style: .secondary,
                fullWidth: true
            ) {
                onPurchase()
            }
            .disabled(isPurchasing)

            Text("One-time purchase. All features, forever.")
                .font(Theme.Typography.caption1)
                .foregroundStyle(Theme.Colors.textSecondary)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    PremiumPurchaseCTA(
        price: "$14.99",
        isPurchasing: false,
        onPurchase: {}
    )
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Dark") {
    PremiumPurchaseCTA(
        price: "$14.99",
        isPurchasing: false,
        onPurchase: {}
    )
    .padding()
    .background(Theme.Colors.background)
    .preferredColorScheme(.dark)
}
