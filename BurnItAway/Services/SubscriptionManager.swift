import Foundation
import StoreKit
import SwiftUI

// MARK: - Subscription Product
struct SubscriptionProduct: Identifiable, Hashable {
    let id: String
    let displayName: String
    let description: String
    let price: String
    let period: String
    let product: Product
    
    static func == (lhs: SubscriptionProduct, rhs: SubscriptionProduct) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Subscription Manager
@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published var products: [SubscriptionProduct] = []
    @Published var purchasedSubscriptions: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Product IDs - these should match your App Store Connect configuration
    private let productIDs = [
        "com.burnitaway.premium.monthly"
    ]
    
    private init() {
        Task {
            await loadProducts()
            await updatePurchasedSubscriptions()
        }
    }
    
    // MARK: - Product Loading
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let storeProducts = try await Product.products(for: productIDs)
            
            products = storeProducts.map { product in
                SubscriptionProduct(
                    id: product.id,
                    displayName: product.displayName,
                    description: product.description,
                    price: product.displayPrice,
                    period: getPeriodString(for: product),
                    product: product
                )
            }
            
            print("🔥 Loaded \(products.count) subscription products")
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            print("🔥 Error loading products: \(error)")
        }
        
        isLoading = false
    }
    
    private func getPeriodString(for product: Product) -> String {
        guard let subscription = product.subscription else { return "" }
        
        let period = subscription.subscriptionPeriod
        let unit = period.unit
        let value = period.value
        
        // Check for introductory offer (free trial)
        if let introOffer = subscription.introductoryOffer {
            let introPeriod = introOffer.period
            let introUnit = introPeriod.unit
            let introValue = introPeriod.value
            
            switch introUnit {
            case .day:
                let days = introValue == 1 ? "1 Day" : "\(introValue) Days"
                return "\(days) Free Trial"
            case .week:
                let weeks = introValue == 1 ? "1 Week" : "\(introValue) Weeks"
                return "\(weeks) Free Trial"
            case .month:
                let months = introValue == 1 ? "1 Month" : "\(introValue) Months"
                return "\(months) Free Trial"
            case .year:
                let years = introValue == 1 ? "1 Year" : "\(introValue) Years"
                return "\(years) Free Trial"
            @unknown default:
                return "Free Trial"
            }
        }
        
        // Regular subscription period
        switch unit {
        case .day:
            return value == 1 ? "Daily" : "\(value) Days"
        case .week:
            return value == 1 ? "Weekly" : "\(value) Weeks"
        case .month:
            return value == 1 ? "Monthly" : "\(value) Months"
        case .year:
            return value == 1 ? "Yearly" : "\(value) Years"
        @unknown default:
            return "Unknown"
        }
    }
    
    // MARK: - Purchase
    func purchase(_ product: Product) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updatePurchasedSubscriptions()
                await transaction.finish()
                
                print("🔥 Purchase successful: \(product.id)")
                return true
                
            case .userCancelled:
                print("🔥 Purchase cancelled by user")
                return false
                
            case .pending:
                print("🔥 Purchase pending")
                return false
                
            @unknown default:
                print("🔥 Unknown purchase result")
                return false
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            print("🔥 Purchase error: \(error)")
            return false
        }
        
        isLoading = false
    }
    
    // MARK: - Restore Purchases
    func restorePurchases() async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await AppStore.sync()
            await updatePurchasedSubscriptions()
            
            let hasActiveSubscription = !purchasedSubscriptions.isEmpty
            print("🔥 Restore completed. Has active subscription: \(hasActiveSubscription)")
            return hasActiveSubscription
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
            print("🔥 Restore error: \(error)")
            return false
        }
        
        isLoading = false
    }
    
    // MARK: - Subscription Status
    func updatePurchasedSubscriptions() async {
        var validSubscriptions: [Product] = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                if let product = products.first(where: { $0.id == transaction.productID })?.product {
                    validSubscriptions.append(product)
                }
            } catch {
                print("🔥 Failed to verify transaction: \(error)")
            }
        }
        
        purchasedSubscriptions = validSubscriptions
        print("🔥 Updated purchased subscriptions: \(purchasedSubscriptions.count) active")
    }
    
    func hasActiveSubscription() -> Bool {
        return !purchasedSubscriptions.isEmpty
    }
    
    func isInFreeTrial() -> Bool {
        // Check if user has an active subscription that's in trial period
        for subscription in purchasedSubscriptions {
            if let subscriptionInfo = subscription.subscription {
                // Check if there's an introductory offer and if it's still active
                if let introOffer = subscriptionInfo.introductoryOffer {
                    // This is a simplified check - in a real app you'd check transaction dates
                    return true
                }
            }
        }
        return false
    }
    
    func getTrialStatus() -> (isInTrial: Bool, trialEndDate: Date?, subscriptionStartDate: Date?) {
        // This is a simplified implementation
        // In a real app, you'd check actual transaction dates
        for subscription in purchasedSubscriptions {
            if let subscriptionInfo = subscription.subscription {
                if let introOffer = subscriptionInfo.introductoryOffer {
                    // Calculate trial end date (7 days from now for demo)
                    let trialEndDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
                    let subscriptionStartDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
                    return (true, trialEndDate, subscriptionStartDate)
                }
            }
        }
        return (false, nil, nil)
    }
    
    // MARK: - Helper Methods
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Transaction Listener
    func startTransactionListener() {
        Task {
            for await result in Transaction.updates {
                do {
                    let transaction = try checkVerified(result)
                    await updatePurchasedSubscriptions()
                    await transaction.finish()
                } catch {
                    print("🔥 Transaction update error: \(error)")
                }
            }
        }
    }
}

// MARK: - Store Error
enum StoreError: Error, LocalizedError {
    case failedVerification
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}
