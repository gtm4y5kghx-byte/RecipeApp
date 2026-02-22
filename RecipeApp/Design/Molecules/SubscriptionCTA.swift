import SwiftUI

/// Shared subscription call-to-action with button and price caption
struct SubscriptionCTA: View {
    let monthlyPrice: String?
    let isPurchasing: Bool
    let onSubscribe: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            DSButton(
                title: monthlyPrice != nil ? "Subscribe - \(monthlyPrice!)/month" : "Subscribe",
                style: .primary,
                fullWidth: true
            ) {
                onSubscribe()
            }
            .disabled(isPurchasing || monthlyPrice == nil)

            Text("All features. Cancel anytime.")
                .font(Theme.Typography.caption1)
                .foregroundStyle(Theme.Colors.textSecondary)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    SubscriptionCTA(
        monthlyPrice: "$4.99",
        isPurchasing: false,
        onSubscribe: {}
    )
    .padding()
    .background(Theme.Colors.background)
}

#Preview("Dark") {
    SubscriptionCTA(
        monthlyPrice: "$4.99",
        isPurchasing: false,
        onSubscribe: {}
    )
    .padding()
    .background(Theme.Colors.background)
    .preferredColorScheme(.dark)
}
