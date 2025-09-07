//
//  RitualSelectionView.swift
//  BurnItAway
//
//  Created by Vaibhav Parashar on 9/4/25.
//

import SwiftUI

struct RitualSelectionView: View {
    @EnvironmentObject var premium: PremiumState
    @State private var selectedRitual: RitualType?
    @State private var showSubscriptionPaywall = false
    @State private var showContent = false
    @State private var ritualCompleted = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        if #available(iOS 17.0, *) {
            CalmBackground {
                VStack(spacing: CalmDesignSystem.Spacing.xxl) {
                    // Header
                    VStack(spacing: CalmDesignSystem.Spacing.lg) {
                        HStack {
                            Text("Choose Your Ritual")
                                .font(CalmDesignSystem.Typography.largeTitle)
                                .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                                .allowsTightening(true)
                                .multilineTextAlignment(.center)
                            
                            Spacer()
                            
                            // Premium button for reviewers
                            if !premium.isPremium {
                                Button(action: {
                                    showSubscriptionPaywall = true
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "crown.fill")
                                            .font(.system(size: 12, weight: .medium))
                                        Text("Premium")
                                            .font(CalmDesignSystem.Typography.caption)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(CalmDesignSystem.Colors.primary)
                                    .padding(.horizontal, CalmDesignSystem.Spacing.sm)
                                    .padding(.vertical, CalmDesignSystem.Spacing.xs)
                                    .background(
                                        RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.sm)
                                            .fill(CalmDesignSystem.Colors.primary.opacity(0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.sm)
                                                    .stroke(CalmDesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                }
                                .accessibilityLabel("Upgrade to Premium")
                                .accessibilityHint("Double tap to view premium subscription options")
                            }
                        }
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.6), value: showContent)
                        
                        Text("Select how you'd like to symbolically release your worry")
                            .font(CalmDesignSystem.Typography.subheadline)
                            .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .minimumScaleFactor(0.7)
                            .allowsTightening(true)
                            .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                            .opacity(showContent ? 1.0 : 0.0)
                            .animation(.easeInOut(duration: 0.6).delay(0.2), value: showContent)
                    }
                    .padding(.top, CalmDesignSystem.Spacing.xxxl)
                    
                    Spacer()
                    
                    // Ritual Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: CalmDesignSystem.Spacing.lg) {
                        ForEach(RitualType.allCases) { ritual in
                            RitualCard(
                                ritual: ritual,
                                isPremium: premium.isPremium,
                                onTap: {
                                    handleRitualSelection(ritual)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.6).delay(0.4), value: showContent)
                    
                    Spacer()
                }
            }
            .navigationBarBackButtonHidden(false)
            .navigationDestination(item: $selectedRitual) { ritual in
                WorryInputView(ritual: ritual, onRitualCompleted: {
                    ritualCompleted = true
                })
            }
            .sheet(isPresented: $showSubscriptionPaywall) {
                SubscriptionPaywallView()
            }
            .onAppear {
                // Trigger fade-in animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showContent = true
                }
            }
            .onChange(of: ritualCompleted) { completed in
                if completed {
                    // Auto-dismiss back to ContentView after ritual completion
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dismiss()
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func handleRitualSelection(_ ritual: RitualType) {
        HapticFeedback.light()
        
        if ritual.isPremium && !premium.isPremium {
            showSubscriptionPaywall = true
        } else {
            selectedRitual = ritual
        }
    }
}

// MARK: - Ritual Card
struct RitualCard: View {
    let ritual: RitualType
    let isPremium: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: CalmDesignSystem.Spacing.md) {
                // Emoji
                Text(ritual.emoji)
                    .font(.system(size: 50))
                    .scaleEffect(isPremium || !ritual.isPremium ? 1.0 : 0.8)
                    .opacity(isPremium || !ritual.isPremium ? 1.0 : 0.6)
                    .animation(.easeInOut(duration: 0.3), value: isPremium)
                
                // Title
                Text(ritual.displayName)
                    .font(CalmDesignSystem.Typography.headline)
                    .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .allowsTightening(true)
                    .multilineTextAlignment(.center)
                
                // Description
                Text(ritual.description)
                    .font(CalmDesignSystem.Typography.caption)
                    .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.7)
                    .allowsTightening(true)
                    .multilineTextAlignment(.center)
                
                // Premium badge
                if ritual.isPremium && !isPremium {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 12))
                        Text("Premium")
                            .font(CalmDesignSystem.Typography.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(CalmDesignSystem.Colors.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(CalmDesignSystem.Colors.accent.opacity(0.2))
                    )
                }
            }
            .padding(CalmDesignSystem.Spacing.lg)
            .frame(maxWidth: .infinity, minHeight: 180)
            .background(
                RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                    .fill(CalmDesignSystem.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                            .stroke(
                                isPremium || !ritual.isPremium ? 
                                ritual.calmColor.opacity(0.3) : 
                                CalmDesignSystem.Colors.glassBorder, 
                                lineWidth: 2
                            )
                    )
                    .shadow(color: CalmDesignSystem.Colors.shadow, radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPremium || !ritual.isPremium ? 1.0 : 0.95)
        .opacity(isPremium || !ritual.isPremium ? 1.0 : 0.7)
        .animation(.easeInOut(duration: 0.3), value: isPremium)
        .accessibilityLabel("\(ritual.displayName) ritual")
        .accessibilityHint(ritual.isPremium && !isPremium ? "Premium feature - tap to upgrade" : "Double tap to select this ritual")
        .accessibilityAddTraits(.isButton)
    }
}


#Preview {
    NavigationStack {
        RitualSelectionView()
            .environmentObject(PremiumState())
    }
}
