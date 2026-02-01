import Testing
import Foundation
@testable import RecipeApp

@Suite("SubscriptionService Business Logic Tests")
@MainActor
struct SubscriptionServiceTests {

    // MARK: - hasPremium Tests

    @Test("hasPremium returns true when premium product is purchased")
    func hasPremiumWithPurchase() async {
        let service = SubscriptionService(
            userDefaults: createCleanUserDefaults(),
            initialPurchasedProductIDs: [SubscriptionService.ProductID.premiumLifetime]
        )

        #expect(service.hasPremium == true)
    }

    @Test("hasPremium returns true when user has ever subscribed")
    func hasPremiumWithPastSubscription() async {
        let userDefaults = createCleanUserDefaults()
        userDefaults.set(true, forKey: "has_ever_subscribed")

        let service = SubscriptionService(
            userDefaults: userDefaults,
            initialPurchasedProductIDs: []
        )

        #expect(service.hasPremium == true)
    }

    @Test("hasPremium returns true when both premium purchased and ever subscribed")
    func hasPremiumWithBoth() async {
        let userDefaults = createCleanUserDefaults()
        userDefaults.set(true, forKey: "has_ever_subscribed")

        let service = SubscriptionService(
            userDefaults: userDefaults,
            initialPurchasedProductIDs: [SubscriptionService.ProductID.premiumLifetime]
        )

        #expect(service.hasPremium == true)
    }

    @Test("hasPremium returns false when no premium and never subscribed")
    func hasPremiumFalseWhenNeither() async {
        let service = SubscriptionService(
            userDefaults: createCleanUserDefaults(),
            initialPurchasedProductIDs: []
        )

        #expect(service.hasPremium == false)
    }

    @Test("hasPremium returns false when only subscription is active (not ever-subscribed flag)")
    func hasPremiumFalseWithOnlyActiveSubscription() async {
        // Active subscription without the hasEverSubscribed flag being set
        // This shouldn't happen in practice, but tests the logic
        let service = SubscriptionService(
            userDefaults: createCleanUserDefaults(),
            initialPurchasedProductIDs: [SubscriptionService.ProductID.mealPlanMonthly]
        )

        // Note: In real usage, having mealPlanMonthly would set hasEverSubscribed
        // But here we're testing the raw logic without that side effect
        #expect(service.hasPremium == false)
    }

    // MARK: - hasActiveSubscription Tests

    @Test("hasActiveSubscription returns true when subscription product is active")
    func hasActiveSubscriptionTrue() async {
        let service = SubscriptionService(
            userDefaults: createCleanUserDefaults(),
            initialPurchasedProductIDs: [SubscriptionService.ProductID.mealPlanMonthly]
        )

        #expect(service.hasActiveSubscription == true)
    }

    @Test("hasActiveSubscription returns false when subscription is not active")
    func hasActiveSubscriptionFalse() async {
        let service = SubscriptionService(
            userDefaults: createCleanUserDefaults(),
            initialPurchasedProductIDs: []
        )

        #expect(service.hasActiveSubscription == false)
    }

    @Test("hasActiveSubscription returns false when only premium is purchased")
    func hasActiveSubscriptionFalseWithPremiumOnly() async {
        let service = SubscriptionService(
            userDefaults: createCleanUserDefaults(),
            initialPurchasedProductIDs: [SubscriptionService.ProductID.premiumLifetime]
        )

        #expect(service.hasActiveSubscription == false)
    }

    @Test("hasActiveSubscription returns true when both premium and subscription are active")
    func hasActiveSubscriptionWithBoth() async {
        let service = SubscriptionService(
            userDefaults: createCleanUserDefaults(),
            initialPurchasedProductIDs: [
                SubscriptionService.ProductID.premiumLifetime,
                SubscriptionService.ProductID.mealPlanMonthly
            ]
        )

        #expect(service.hasActiveSubscription == true)
        #expect(service.hasPremium == true)
    }

    // MARK: - hasEverSubscribed Persistence Tests

    @Test("hasEverSubscribed reads false from fresh UserDefaults")
    func hasEverSubscribedDefaultsFalse() async {
        let service = SubscriptionService(
            userDefaults: createCleanUserDefaults(),
            initialPurchasedProductIDs: []
        )

        #expect(service.hasEverSubscribed == false)
    }

    @Test("hasEverSubscribed reads true when previously set")
    func hasEverSubscribedReadsTrue() async {
        let userDefaults = createCleanUserDefaults()
        userDefaults.set(true, forKey: "has_ever_subscribed")

        let service = SubscriptionService(
            userDefaults: userDefaults,
            initialPurchasedProductIDs: []
        )

        #expect(service.hasEverSubscribed == true)
    }

    @Test("hasEverSubscribed persists when set to true")
    func hasEverSubscribedPersistsTrue() async {
        let userDefaults = createCleanUserDefaults()
        let service = SubscriptionService(
            userDefaults: userDefaults,
            initialPurchasedProductIDs: []
        )

        #expect(service.hasEverSubscribed == false)

        service.hasEverSubscribed = true

        #expect(service.hasEverSubscribed == true)
        #expect(userDefaults.bool(forKey: "has_ever_subscribed") == true)
    }

    @Test("hasEverSubscribed grants premium access after being set")
    func hasEverSubscribedGrantsPremium() async {
        let userDefaults = createCleanUserDefaults()
        let service = SubscriptionService(
            userDefaults: userDefaults,
            initialPurchasedProductIDs: []
        )

        #expect(service.hasPremium == false)

        service.hasEverSubscribed = true

        #expect(service.hasPremium == true)
    }

    // MARK: - Product ID Constants Tests

    @Test("ProductID constants have expected values")
    func productIDConstants() {
        #expect(SubscriptionService.ProductID.premiumLifetime == "premium_lifetime")
        #expect(SubscriptionService.ProductID.mealPlanMonthly == "meal_plan_monthly")
        #expect(SubscriptionService.ProductID.all.count == 2)
        #expect(SubscriptionService.ProductID.all.contains("premium_lifetime"))
        #expect(SubscriptionService.ProductID.all.contains("meal_plan_monthly"))
    }

    // MARK: - Test Helpers

    private func createCleanUserDefaults() -> UserDefaults {
        let suiteName = "SubscriptionServiceTests.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
        return userDefaults
    }
}
