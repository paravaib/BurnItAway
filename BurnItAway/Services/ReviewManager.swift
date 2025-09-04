import Foundation
import StoreKit
import SwiftUI

@MainActor
class ReviewManager: ObservableObject {
    static let shared = ReviewManager()
    
    private init() {}
    
    // Track review request attempts
    private let reviewRequestCountKey = "review_request_count"
    private let lastReviewRequestDateKey = "last_review_request_date"
    private let maxReviewRequests = 3 // Limit to 3 requests per year
    
    private var reviewRequestCount: Int {
        get { UserDefaults.standard.integer(forKey: reviewRequestCountKey) }
        set { UserDefaults.standard.set(newValue, forKey: reviewRequestCountKey) }
    }
    
    private var lastReviewRequestDate: Date? {
        get { UserDefaults.standard.object(forKey: lastReviewRequestDateKey) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: lastReviewRequestDateKey) }
    }
    
    /// Request a review if conditions are met
    func requestReviewIfAppropriate() {
        // Check if we can request a review
        guard canRequestReview() else { return }
        
        // Request the review
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
            
            // Update tracking
            reviewRequestCount += 1
            lastReviewRequestDate = Date()
            
            print("🔥 Review requested. Count: \(reviewRequestCount)")
        }
    }
    
    /// Check if we can request a review
    private func canRequestReview() -> Bool {
        // Don't request if we've hit the limit
        guard reviewRequestCount < maxReviewRequests else {
            print("🔥 Review request limit reached")
            return false
        }
        
        // Don't request if we requested recently (within 30 days)
        if let lastDate = lastReviewRequestDate {
            let daysSinceLastRequest = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
            guard daysSinceLastRequest >= 30 else {
                print("🔥 Review requested too recently")
                return false
            }
        }
        
        return true
    }
    
    /// Force request a review (for manual triggers)
    func forceRequestReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
            print("🔥 Force review requested")
        }
    }
    
    /// Reset review tracking (for testing)
    func resetReviewTracking() {
        reviewRequestCount = 0
        lastReviewRequestDate = nil
        print("🔥 Review tracking reset")
    }
    
    /// Get review request status for debugging
    func getReviewStatus() -> (count: Int, lastDate: Date?, canRequest: Bool) {
        return (reviewRequestCount, lastReviewRequestDate, canRequestReview())
    }
}
