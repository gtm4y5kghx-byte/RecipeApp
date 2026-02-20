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

    #if DEBUG
    static var debugTierOverride: SubscriptionTier?

    @discardableResult
    static func cycleDebugTier() -> String {
        switch debugTierOverride {
        case .none, .some(.free): debugTierOverride = .premium
        case .some(.premium): debugTierOverride = .subscriber
        case .some(.subscriber): debugTierOverride = .free
        }
        return debugTierLabel
    }

    static var debugTierLabel: String {
        switch debugTierOverride {
        case .none, .some(.free): return "Free"
        case .some(.premium): return "Premium"
        case .some(.subscriber): return "Subscriber"
        }
    }
    #endif

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
        #if DEBUG
        if let override = Self.debugTierOverride {
            return override != .free
        }
        #endif
        return subscriptionService.hasPremium
    }

    /// Has access to meal plan generation (premium or subscriber)
    var canGenerateMealPlan: Bool {
        guard FeatureFlags.isPremiumGatingEnabled else { return true }
        #if DEBUG
        if let override = Self.debugTierOverride {
            return override != .free
        }
        #endif
        return isPremium
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
