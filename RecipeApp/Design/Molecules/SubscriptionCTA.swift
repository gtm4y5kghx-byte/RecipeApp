import SwiftUI

/// Shared subscription call-to-action with button and price captions
struct SubscriptionCTA: View {
    let introPrice: String
    let monthlyPrice: String
    let isPurchasing: Bool
    let onSubscribe: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            DSButton(
                title: "Subscribe - \(introPrice) first month",
                style: .primary,
                fullWidth: true
            ) {
                onSubscribe()
            }
            .disabled(isPurchasing)

            VStack(spacing: 2) {
                Text("Includes lifetime Premium access")
                Text("Then \(monthlyPrice)/month for Meal Planning")
            }
            .font(Theme.Typography.caption1)
            .foregroundStyle(Theme.Colors.textSecondary)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    SubscriptionCTA(
        introPrice: "$19.99",
        monthlyPrice: "$4.99",
        isPurchasing: false,
        onSubscribe: {}
    )
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Dark") {
    SubscriptionCTA(
        introPrice: "$19.99",
        monthlyPrice: "$4.99",
        isPurchasing: false,
        onSubscribe: {}
    )
    .padding()
    .background(Theme.Colors.background)
    .preferredColorScheme(.dark)
}
