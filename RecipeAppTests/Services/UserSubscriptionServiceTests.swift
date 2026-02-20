import Testing
import Foundation
@testable import RecipeApp

@Suite("UserSubscriptionService Tests")
@MainActor
struct UserSubscriptionServiceTests {

    // MARK: - canGenerateMealPlan Tests

    @Test("canGenerateMealPlan true when user has active subscription")
    func canGenerateMealPlanWithSubscription() {
        let store = SubscriptionService(
            userDefaults: createCleanUserDefaults(),
            initialPurchasedProductIDs: [SubscriptionService.ProductID.mealPlanMonthly]
        )
        store.hasEverSubscribed = true
        let service = UserSubscriptionService(subscriptionService: store)

        #expect(service.canGenerateMealPlan == true)
    }

    @Test("canGenerateMealPlan true when user has premium lifetime purchase")
    func canGenerateMealPlanWithPremium() {
        let store = SubscriptionService(
            userDefaults: createCleanUserDefaults(),
            initialPurchasedProductIDs: [SubscriptionService.ProductID.premiumLifetime]
        )
        let service = UserSubscriptionService(subscriptionService: store)

        #expect(service.canGenerateMealPlan == true)
    }

    @Test("canGenerateMealPlan true when user has ever subscribed")
    func canGenerateMealPlanWithPastSubscription() {
        let userDefaults = createCleanUserDefaults()
        userDefaults.set(true, forKey: "has_ever_subscribed")

        let store = SubscriptionService(
            userDefaults: userDefaults,
            initialPurchasedProductIDs: []
        )
        let service = UserSubscriptionService(subscriptionService: store)

        #expect(service.canGenerateMealPlan == true)
    }

    @Test("canGenerateMealPlan false when user is free tier")
    func canGenerateMealPlanFalseForFreeUser() {
        let store = SubscriptionService(
            userDefaults: createCleanUserDefaults(),
            initialPurchasedProductIDs: []
        )
        let service = UserSubscriptionService(subscriptionService: store)

        #expect(service.canGenerateMealPlan == false)
    }

    // MARK: - isPremium Tests

    @Test("isPremium true with lifetime purchase")
    func isPremiumWithLifetimePurchase() {
        let store = SubscriptionService(
            userDefaults: createCleanUserDefaults(),
            initialPurchasedProductIDs: [SubscriptionService.ProductID.premiumLifetime]
        )
        let service = UserSubscriptionService(subscriptionService: store)

        #expect(service.isPremium == true)
    }

    @Test("isPremium false for free user")
    func isPremiumFalseForFreeUser() {
        let store = SubscriptionService(
            userDefaults: createCleanUserDefaults(),
            initialPurchasedProductIDs: []
        )
        let service = UserSubscriptionService(subscriptionService: store)

        #expect(service.isPremium == false)
    }

    // MARK: - Test Helpers

    private func createCleanUserDefaults() -> UserDefaults {
        let suiteName = "UserSubscriptionServiceTests.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
        return userDefaults
    }
}
