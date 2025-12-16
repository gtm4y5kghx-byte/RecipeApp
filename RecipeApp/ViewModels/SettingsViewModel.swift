import Foundation

@Observable
class SettingsViewModel {
    private let subscriptionService: UserSubscriptionService
    private let userDefaults: UserDefaults

    var keepScreenOnInCookingMode: Bool {
        get { userDefaults.bool(forKey: "keepScreenOnInCookingMode") }
        set { userDefaults.set(newValue, forKey: "keepScreenOnInCookingMode") }
    }

    var keepScreenOnWhileViewingRecipes: Bool {
        get { userDefaults.bool(forKey: "keepScreenOnWhileViewingRecipes") }
        set { userDefaults.set(newValue, forKey: "keepScreenOnWhileViewingRecipes") }
    }

    var isPremium: Bool {
        subscriptionService.isPremium
    }

    init(subscriptionService: UserSubscriptionService, userDefaults: UserDefaults = .standard) {
        self.subscriptionService = subscriptionService
        self.userDefaults = userDefaults
    }
}
