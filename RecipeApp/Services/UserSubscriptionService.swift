import Foundation

@MainActor
class UserSubscriptionService {
    enum SubscriptionTier {
        case free
        case premium
    }
    
    static var mockIsPremium: Bool = true
    
    var currentTier: SubscriptionTier {
        Self.mockIsPremium ? .premium : .free
    }
    
    var isPremium: Bool {
        Self.mockIsPremium
    }
    
    func requiresPremium(action: () -> Void, showPaywall: @escaping () -> Void) {
        if isPremium {
            action()
        } else {
            showPaywall()
        }
    }
}
