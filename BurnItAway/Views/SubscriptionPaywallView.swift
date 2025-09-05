import SwiftUI
import StoreKit

struct SubscriptionPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        CalmBackground {
            ScrollView {
                VStack(spacing: CalmDesignSystem.Spacing.xl) {
                // Header
                VStack(spacing: CalmDesignSystem.Spacing.lg) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, CalmDesignSystem.Spacing.lg)
                    
                    // Premium badge
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(CalmDesignSystem.Colors.accent)
                        Text("Premium")
                            .font(CalmDesignSystem.Typography.title)
                            .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                    }
                    
                    Text("Unlock unlimited worry release")
                        .font(CalmDesignSystem.Typography.subheadline)
                        .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .allowsTightening(true)
                }
                
                // Features
                VStack(spacing: CalmDesignSystem.Spacing.lg) {
                    FeatureRow(
                        icon: "flame.fill",
                        title: "Unlimited Rituals",
                        description: "Release as many worries as you need, anytime"
                    )
                    
                    FeatureRow(
                        icon: "infinity",
                        title: "No Daily Limits",
                        description: "Access your healing ritual without restrictions"
                    )
                    
                    FeatureRow(
                        icon: "photo.fill",
                        title: "Photo Release",
                        description: "Release photos to symbolically let go of visual memories"
                    )
                    
                    FeatureRow(
                        icon: "sparkles",
                        title: "Multiple Rituals",
                        description: "Choose from Burn, Smoke, Space, and Wash rituals"
                    )
                    
                    FeatureRow(
                        icon: "heart.fill",
                        title: "Priority Support",
                        description: "Get help when you need it most"
                    )
                }
                .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                
                // Subscription Options
                VStack(spacing: CalmDesignSystem.Spacing.md) {
                    if subscriptionManager.isLoading {
                        VStack(spacing: CalmDesignSystem.Spacing.md) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: CalmDesignSystem.Colors.primary))
                                .scaleEffect(1.2)
                            Text("Loading subscription options...")
                                .font(CalmDesignSystem.Typography.caption)
                                .foregroundColor(CalmDesignSystem.Colors.textTertiary)
                        }
                    } else if let product = subscriptionManager.products.first {
                        SubscriptionCard(product: product)
                    } else {
                        // Show fallback pricing if products don't load
                        FallbackSubscriptionCard()
                    }
                }
                .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                
                // Action Buttons
                VStack(spacing: CalmDesignSystem.Spacing.md) {
                    if let product = subscriptionManager.products.first {
                        Button(action: {
                            Task {
                                await purchaseSubscription(product.product)
                            }
                        }) {
                            HStack {
                                if isPurchasing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text(hasFreeTrial(product.product) ? "Start Free Trial" : "Subscribe")
                                        .font(CalmDesignSystem.Typography.button)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                        .allowsTightening(true)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, CalmDesignSystem.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                                    .fill(
                                        LinearGradient(
                                            colors: [CalmDesignSystem.Colors.primary, CalmDesignSystem.Colors.primary.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                        }
                        .buttonStyle(CalmPrimaryButtonStyle())
                        .disabled(isPurchasing)
                    } else {
                        // Fallback button when products don't load
                        Button(action: {
                            // Retry loading products
                            Task {
                                await subscriptionManager.loadProducts()
                            }
                        }) {
                            Text("Retry Loading")
                                .font(CalmDesignSystem.Typography.button)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .allowsTightening(true)
                        }
                        .buttonStyle(CalmPrimaryButtonStyle())
                    }
                    
                    Button(action: {
                        Task {
                            await restorePurchases()
                        }
                    }) {
                        Text("Restore Purchases")
                            .font(CalmDesignSystem.Typography.button)
                            .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .allowsTightening(true)
                    }
                    .buttonStyle(CalmSecondaryButtonStyle())
                    
                    Button(action: {
                        openSubscriptionManagement()
                    }) {
                        Text("Manage Subscription")
                            .font(CalmDesignSystem.Typography.button)
                            .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .allowsTightening(true)
                    }
                    .buttonStyle(CalmSecondaryButtonStyle())
                    
                    // Terms and Privacy
                    VStack(spacing: CalmDesignSystem.Spacing.xs) {
                        Text("By subscribing, you agree to our Terms of Service and Privacy Policy")
                            .font(CalmDesignSystem.Typography.caption)
                            .foregroundColor(CalmDesignSystem.Colors.textTertiary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                            .allowsTightening(true)
                        
                        Text("Cancel anytime in Settings")
                            .font(CalmDesignSystem.Typography.caption)
                            .foregroundColor(CalmDesignSystem.Colors.textTertiary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .allowsTightening(true)
                    }
                }
                .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                .padding(.bottom, CalmDesignSystem.Spacing.xl)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await subscriptionManager.loadProducts()
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func purchaseSubscription(_ product: Product) async {
        isPurchasing = true
        
        let success = await subscriptionManager.purchase(product)
        
        if success {
            dismiss()
        } else if let error = subscriptionManager.errorMessage {
            errorMessage = error
            showError = true
        }
        
        isPurchasing = false
    }
    
    private func restorePurchases() async {
        let success = await subscriptionManager.restorePurchases()
        
        if success {
            dismiss()
        } else if let error = subscriptionManager.errorMessage {
            errorMessage = error
            showError = true
        }
    }
    
    private func hasFreeTrial(_ product: Product) -> Bool {
        guard let subscription = product.subscription else { return false }
        return subscription.introductoryOffer != nil
    }
    
    private func openSubscriptionManagement() {
        Task {
            do {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                    print("🔥 No window scene available")
                    errorMessage = "Please go to Settings > Apple ID > Subscriptions to manage your subscription."
                    showError = true
                    return
                }
                try await AppStore.showManageSubscriptions(in: windowScene)
            } catch {
                print("🔥 Failed to open subscription management: \(error)")
                // Fallback: Show alert with instructions
                errorMessage = "Please go to Settings > Apple ID > Subscriptions to manage your subscription."
                showError = true
            }
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: CalmDesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(CalmDesignSystem.Colors.primary)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(CalmDesignSystem.Colors.primary.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: CalmDesignSystem.Spacing.xs) {
                Text(title)
                    .font(CalmDesignSystem.Typography.headline)
                    .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .allowsTightening(true)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(description)
                    .font(CalmDesignSystem.Typography.body)
                    .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                    .allowsTightening(true)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, CalmDesignSystem.Spacing.lg)
        .padding(.vertical, CalmDesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                .fill(CalmDesignSystem.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                        .stroke(CalmDesignSystem.Colors.glassBorder, lineWidth: 1)
                )
        )
    }
}

// MARK: - Subscription Card
struct SubscriptionCard: View {
    let product: SubscriptionProduct
    
    var body: some View {
        VStack(spacing: CalmDesignSystem.Spacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: CalmDesignSystem.Spacing.xs) {
                    Text(product.displayName)
                        .font(CalmDesignSystem.Typography.headline)
                        .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .allowsTightening(true)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(product.description)
                        .font(CalmDesignSystem.Typography.body)
                        .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                        .lineLimit(3)
                        .minimumScaleFactor(0.8)
                        .allowsTightening(true)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .trailing, spacing: CalmDesignSystem.Spacing.xs) {
                    Text(product.price)
                        .font(CalmDesignSystem.Typography.title)
                        .foregroundColor(CalmDesignSystem.Colors.primary)
                    
                    Text(product.period)
                        .font(CalmDesignSystem.Typography.caption)
                        .foregroundColor(CalmDesignSystem.Colors.textTertiary)
                }
            }
            
            // Free trial badge
            HStack {
                Image(systemName: "gift.fill")
                    .foregroundColor(CalmDesignSystem.Colors.accent)
                Text("7-day free trial, then \(product.price) per month")
                    .font(CalmDesignSystem.Typography.caption)
                    .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .allowsTightening(true)
            }
            .padding(.horizontal, CalmDesignSystem.Spacing.md)
            .padding(.vertical, CalmDesignSystem.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.md)
                    .fill(CalmDesignSystem.Colors.accent.opacity(0.1))
            )
        }
        .padding(CalmDesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                .fill(CalmDesignSystem.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                        .stroke(CalmDesignSystem.Colors.primary.opacity(0.3), lineWidth: 2)
                )
        )
    }
}

// MARK: - Fallback Subscription Card
struct FallbackSubscriptionCard: View {
    var body: some View {
        VStack(spacing: CalmDesignSystem.Spacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: CalmDesignSystem.Spacing.xs) {
                    Text("Premium Monthly")
                        .font(CalmDesignSystem.Typography.headline)
                        .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .allowsTightening(true)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Unlimited worry release and premium features")
                        .font(CalmDesignSystem.Typography.body)
                        .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                        .lineLimit(3)
                        .minimumScaleFactor(0.8)
                        .allowsTightening(true)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .trailing, spacing: CalmDesignSystem.Spacing.xs) {
                    Text("$2.99")
                        .font(CalmDesignSystem.Typography.title)
                        .foregroundColor(CalmDesignSystem.Colors.primary)
                    
                    Text("per month")
                        .font(CalmDesignSystem.Typography.caption)
                        .foregroundColor(CalmDesignSystem.Colors.textTertiary)
                }
            }
            
            // Free trial badge
            HStack {
                Image(systemName: "gift.fill")
                    .foregroundColor(CalmDesignSystem.Colors.accent)
                Text("7-day free trial, then $2.99 per month")
                    .font(CalmDesignSystem.Typography.caption)
                    .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .allowsTightening(true)
            }
            .padding(.horizontal, CalmDesignSystem.Spacing.md)
            .padding(.vertical, CalmDesignSystem.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.md)
                    .fill(CalmDesignSystem.Colors.accent.opacity(0.1))
            )
        }
        .padding(CalmDesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                .fill(CalmDesignSystem.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                        .stroke(CalmDesignSystem.Colors.primary.opacity(0.3), lineWidth: 2)
                )
        )
    }
}

#Preview {
    SubscriptionPaywallView()
}
