import SwiftUI
import StoreKit

struct TrialStatusView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var trialStatus: (isInTrial: Bool, trialEndDate: Date?, subscriptionStartDate: Date?) = (false, nil, nil)
    
    var body: some View {
        if trialStatus.isInTrial {
            VStack(spacing: CalmDesignSystem.Spacing.sm) {
                // Trial status header
                HStack(spacing: CalmDesignSystem.Spacing.sm) {
                    Image(systemName: "gift.fill")
                        .foregroundColor(CalmDesignSystem.Colors.accent)
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("Free Trial Active")
                        .font(CalmDesignSystem.Typography.callout)
                        .fontWeight(.medium)
                        .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                }
                
                // Trial details
                VStack(spacing: CalmDesignSystem.Spacing.xs) {
                    if let trialEndDate = trialStatus.trialEndDate {
                        Text("Trial ends: \(formatDate(trialEndDate))")
                            .font(CalmDesignSystem.Typography.caption)
                            .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                    }
                    
                    if let subscriptionStartDate = trialStatus.subscriptionStartDate {
                        Text("Billing starts: \(formatDate(subscriptionStartDate))")
                            .font(CalmDesignSystem.Typography.caption)
                            .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                    }
                }
                
                // Manage subscription button
                Button(action: {
                    openSubscriptionManagement()
                }) {
                    Text("Manage Subscription")
                        .font(CalmDesignSystem.Typography.caption)
                        .foregroundColor(CalmDesignSystem.Colors.primary)
                        .underline()
                }
            }
            .padding(CalmDesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                    .fill(CalmDesignSystem.Colors.accent.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                            .stroke(CalmDesignSystem.Colors.accent.opacity(0.3), lineWidth: 1)
                    )
            )
            .onAppear {
                updateTrialStatus()
            }
        }
    }
    
    private func updateTrialStatus() {
        trialStatus = subscriptionManager.getTrialStatus()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func openSubscriptionManagement() {
        Task {
            do {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                    print("🔥 No window scene available")
                    return
                }
                try await AppStore.showManageSubscriptions(in: windowScene)
            } catch {
                print("🔥 Failed to open subscription management: \(error)")
            }
        }
    }
}

#Preview {
    TrialStatusView()
        .preferredColorScheme(.dark)
}
