import Foundation

@MainActor
class UserSubscriptionService {
    static let shared = UserSubscriptionService()

    enum SubscriptionTier {
        case free
        case premium
        case subscriber
    }

    private let subscriptionService: SubscriptionService

    // For previews/testing
    static var mockIsPremium: Bool = true

    init(subscriptionService: SubscriptionService? = nil) {
        self.subscriptionService = subscriptionService ?? SubscriptionService()
    }

    var currentTier: SubscriptionTier {
        if subscriptionService.hasActiveSubscription {
            return .subscriber
        } else if subscriptionService.hasPremium {
            return .premium
        }
        return .free
    }

    /// Has premium access (purchased or ever subscribed)
    var isPremium: Bool {
        guard FeatureFlags.isPremiumGatingEnabled else { return true }
        return subscriptionService.hasPremium
    }

    /// Has active subscription for meal plan generation
    var canGenerateMealPlan: Bool {
        guard FeatureFlags.isPremiumGatingEnabled else { return true }
        return subscriptionService.hasActiveSubscription
    }

    /// Access to underlying subscription service for purchases
    var store: SubscriptionService {
        subscriptionService
    }

    func loadProducts() async {
        await subscriptionService.loadProducts()
    }

    func requiresPremium(action: () -> Void, showPaywall: @escaping () -> Void) {
        if isPremium {
            action()
        } else {
            showPaywall()
        }
    }

    func requiresSubscription(action: () -> Void, showPaywall: @escaping () -> Void) {
        if canGenerateMealPlan {
            action()
        } else {
            showPaywall()
        }
    }
}
