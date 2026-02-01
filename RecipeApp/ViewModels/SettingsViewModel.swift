import Foundation

@Observable
class SettingsViewModel {
    private let subscriptionService: UserSubscriptionService
    private let userDefaults: UserDefaults
    private let isPremiumOverride: Bool?

    var keepScreenOnInCookingMode: Bool {
        get { userDefaults.object(forKey: "keepScreenOnInCookingMode") as? Bool ?? true }
        set { userDefaults.set(newValue, forKey: "keepScreenOnInCookingMode") }
    }

    var keepScreenOnWhileViewingRecipes: Bool {
        get { userDefaults.bool(forKey: "keepScreenOnWhileViewingRecipes") }
        set { userDefaults.set(newValue, forKey: "keepScreenOnWhileViewingRecipes") }
    }

    var isPremium: Bool {
        isPremiumOverride ?? subscriptionService.isPremium
    }

    init(
        subscriptionService: UserSubscriptionService,
        userDefaults: UserDefaults = .standard,
        isPremiumOverride: Bool? = nil
    ) {
        self.subscriptionService = subscriptionService
        self.userDefaults = userDefaults
        self.isPremiumOverride = isPremiumOverride
    }
}
