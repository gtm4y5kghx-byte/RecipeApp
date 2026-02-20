import SwiftUI
import StoreKit

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var currentPage = 0
    @State private var subscriptionService: UserSubscriptionService?
    @State private var isPurchasing = false

    private let pageCount = 4

    var body: some View {
        VStack(spacing: 0) {
            DSCarousel(pageCount: pageCount, currentPage: $currentPage) { index in
                page(for: index)
            }

            if currentPage < pageCount - 1 {
                navigationFooter
            }
        }
        .background(Theme.Colors.background)
        .onAppear {
            if subscriptionService == nil {
                subscriptionService = UserSubscriptionService()
            }
        }
        .task {
            await subscriptionService?.loadProducts()
        }
    }

    @ViewBuilder
    private func page(for index: Int) -> some View {
        switch index {
        case 0:
            OnboardingWelcomePage()
        case 1:
            OnboardingRecipesPage()
        case 2:
            OnboardingAIFeaturesPage()
        case 3:
            OnboardingPremiumPage(
                subscriptionPrice: subscriptionService?.store.subscriptionProduct?.displayPrice,
                premiumPrice: subscriptionService?.store.premiumProduct?.displayPrice,
                isPurchasing: isPurchasing,
                onSubscribe: { Task { await purchaseSubscription() } },
                onPurchasePremium: { Task { await purchasePremium() } },
                onSkip: onComplete
            )
        default:
            EmptyView()
        }
    }

    private var navigationFooter: some View {
        HStack {
            if currentPage > 0 {
                DSButton(title: "Back", style: .tertiary) {
                    withAnimation { currentPage -= 1 }
                }
            }

            Spacer()

            DSButton(title: "Next", style: .primary) {
                withAnimation { currentPage += 1 }
            }
        }
        .padding(Theme.Spacing.md)
    }

    private func purchaseSubscription() async {
        isPurchasing = true
        do {
            let success = try await subscriptionService?.store.purchaseSubscription() ?? false
            if success { onComplete() }
        } catch {
            // Purchase failed or cancelled
        }
        isPurchasing = false
    }

    private func purchasePremium() async {
        isPurchasing = true
        do {
            let success = try await subscriptionService?.store.purchasePremium() ?? false
            if success { onComplete() }
        } catch {
            // Purchase failed or cancelled
        }
        isPurchasing = false
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
