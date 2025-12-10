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

    var shoppingListTargetName: String {
        get { userDefaults.string(forKey: "shoppingListTargetName") ?? "RecipeApp Shopping List" }
        set { userDefaults.set(newValue, forKey: "shoppingListTargetName") }
    }

    var isPremium: Bool {
        subscriptionService.isPremium
    }

    init(subscriptionService: UserSubscriptionService, userDefaults: UserDefaults = .standard) {
        self.subscriptionService = subscriptionService
        self.userDefaults = userDefaults
    }
}
