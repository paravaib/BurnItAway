//
//  PremiumState.swift
//  BurnItAway
//
//  Created by Vaibhav Parashar on 9/1/25.
//

import SwiftUI
import Foundation
import Combine

@MainActor
final class PremiumState: ObservableObject {
    @Published var isPremium: Bool = false
    @Published var isForcedPremium: Bool = false {
        didSet {
            updatePremiumStatus()
        }
    }
    
    private let subscriptionManager = SubscriptionManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Check subscription status
        updatePremiumStatus()
        
        // Listen for subscription changes
        subscriptionManager.$purchasedSubscriptions
            .map { !$0.isEmpty }
            .sink { [weak self] newValue in
                self?.isPremium = newValue
            }
            .store(in: &cancellables)
    }
    
    func updatePremiumStatus() {
        isPremium = isForcedPremium || subscriptionManager.hasActiveSubscription()
        print("🔥 PremiumState updated: isPremium=\(isPremium), isForcedPremium=\(isForcedPremium)")
    }
    
    func upgradeToPremium() async -> Bool {
        guard let product = await subscriptionManager.products.first else {
            print("🔥 No subscription products available")
            return false
        }
        
        let success = await subscriptionManager.purchase(product.product)
        if success {
            HapticFeedback.success()
            print("🔥 Premium upgrade successful")
        } else {
            print("🔥 Premium upgrade failed")
        }
        return success
    }
    
    func restorePurchases() async -> Bool {
        let success = await subscriptionManager.restorePurchases()
        if success {
            HapticFeedback.success()
            print("🔥 Purchases restored successfully")
        } else {
            print("🔥 No purchases to restore")
        }
        return success
    }
    
    func loadProducts() async {
        await subscriptionManager.loadProducts()
    }
}
