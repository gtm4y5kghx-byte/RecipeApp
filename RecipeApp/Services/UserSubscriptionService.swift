import Foundation

@MainActor
class UserSubscriptionService {
    static let shared = UserSubscriptionService()

    enum SubscriptionTier {
        case free
        case premium
    }

    static var mockIsPremium: Bool = true
    
    var currentTier: SubscriptionTier {
        Self.mockIsPremium ? .premium : .free
    }
    
    var isPremium: Bool {
        // TestFlight: everyone is premium when gating disabled
        guard FeatureFlags.isPremiumGatingEnabled else { return true }
        return Self.mockIsPremium
    }
    
    func requiresPremium(action: () -> Void, showPaywall: @escaping () -> Void) {
        if isPremium {
            action()
        } else {
            showPaywall()
        }
    }
}
