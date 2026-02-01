import Foundation
import StoreKit

@Observable
class SettingsViewModel {
    private let subscriptionService: UserSubscriptionService
    private let userDefaults: UserDefaults
    private let isPremiumOverride: Bool?

    var isPurchasing = false
    var purchaseError: Error?

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

    var hasActiveSubscription: Bool {
        subscriptionService.canGenerateMealPlan
    }

    var premiumPrice: String? {
        subscriptionService.store.premiumProduct?.displayPrice
    }

    var subscriptionPrice: String? {
        subscriptionService.store.subscriptionProduct?.displayPrice
    }

    var subscriptionIntroPrice: String? {
        subscriptionService.store.subscriptionProduct?.subscription?.introductoryOffer?.displayPrice
    }

    /// Whether the user is eligible for the intro offer
    var isEligibleForIntroOffer: Bool {
        subscriptionService.store.subscriptionProduct?.subscription?.introductoryOffer != nil
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

    func loadProducts() async {
        await subscriptionService.loadProducts()
    }

    func purchasePremium() async {
        isPurchasing = true
        purchaseError = nil

        do {
            _ = try await subscriptionService.store.purchasePremium()
        } catch {
            purchaseError = error
        }

        isPurchasing = false
    }

    func purchaseSubscription() async {
        isPurchasing = true
        purchaseError = nil

        do {
            _ = try await subscriptionService.store.purchaseSubscription()
        } catch {
            purchaseError = error
        }

        isPurchasing = false
    }

    func restorePurchases() async {
        isPurchasing = true
        await subscriptionService.store.restorePurchases()
        isPurchasing = false
    }

    func openSubscriptionManagement() async {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        try? await AppStore.showManageSubscriptions(in: windowScene)
    }
}
