import Foundation
import StoreKit

@MainActor
@Observable
class SubscriptionService {

    // MARK: - Product IDs

    enum ProductID {
        static let premiumLifetime = "premium_lifetime"
        static let mealPlanMonthly = "meal_plan_monthly"

        static var all: [String] {
            [premiumLifetime, mealPlanMonthly]
        }
    }

    // MARK: - State

    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []
    private(set) var isLoading = false
    private(set) var error: Error?

    private var transactionListener: Task<Void, Error>?
    private let hasEverSubscribedKey = "has_ever_subscribed"
    private let userDefaults: UserDefaults

    // MARK: - Computed Properties

    var premiumProduct: Product? {
        products.first { $0.id == ProductID.premiumLifetime }
    }

    var subscriptionProduct: Product? {
        products.first { $0.id == ProductID.mealPlanMonthly }
    }

    /// User has premium access (purchased premium OR ever subscribed)
    var hasPremium: Bool {
        purchasedProductIDs.contains(ProductID.premiumLifetime) || hasEverSubscribed
    }

    /// User has active meal plan subscription
    var hasActiveSubscription: Bool {
        purchasedProductIDs.contains(ProductID.mealPlanMonthly)
    }

    /// User has subscribed at least once (persisted)
    var hasEverSubscribed: Bool {
        get { userDefaults.bool(forKey: hasEverSubscribedKey) }
        set { userDefaults.set(newValue, forKey: hasEverSubscribedKey) }
    }

    // MARK: - Initialization

    init(
        userDefaults: UserDefaults = .standard,
        initialPurchasedProductIDs: Set<String>? = nil
    ) {
        self.userDefaults = userDefaults
        if let initialIDs = initialPurchasedProductIDs {
            self.purchasedProductIDs = initialIDs
        } else {
            transactionListener = listenForTransactions()
        }
    }

    // MARK: - Public Methods

    func loadProducts() async {
        isLoading = true
        error = nil

        do {
            products = try await Product.products(for: ProductID.all)
            await updatePurchasedProducts()
        } catch {
            self.error = error
        }

        isLoading = false
    }

    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            return true

        case .userCancelled:
            return false

        case .pending:
            return false

        @unknown default:
            return false
        }
    }

    func purchasePremium() async throws -> Bool {
        guard let product = premiumProduct else {
            throw SubscriptionError.productNotFound
        }
        return try await purchase(product)
    }

    func purchaseSubscription() async throws -> Bool {
        guard let product = subscriptionProduct else {
            throw SubscriptionError.productNotFound
        }
        return try await purchase(product)
    }

    func restorePurchases() async {
        await updatePurchasedProducts()
    }

    // MARK: - Private Methods

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { break }

                do {
                    let transaction = try await self.checkVerified(result)
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                } catch {
                    // Transaction failed verification
                }
            }
        }
    }

    private func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []

        // Check non-consumables (Premium)
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                purchasedIDs.insert(transaction.productID)

                // Mark hasEverSubscribed if this is a subscription
                if transaction.productID == ProductID.mealPlanMonthly {
                    hasEverSubscribed = true
                }
            } catch {
                // Transaction failed verification
            }
        }

        purchasedProductIDs = purchasedIDs
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Errors

enum SubscriptionError: LocalizedError {
    case productNotFound
    case verificationFailed

    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Product not found"
        case .verificationFailed:
            return "Purchase verification failed"
        }
    }
}
