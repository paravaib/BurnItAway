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
    @State private var showRitualAnimation = false
    @State private var showSubscriptionPaywall = false
    @State private var worryText = ""
    @State private var showTextInput = false
    
    var body: some View {
        CalmBackground {
            VStack(spacing: CalmDesignSystem.Spacing.xxl) {
                // Header
                VStack(spacing: CalmDesignSystem.Spacing.lg) {
                    Text("Choose Your Ritual")
                        .font(CalmDesignSystem.Typography.largeTitle)
                        .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .allowsTightening(true)
                        .multilineTextAlignment(.center)
                    
                    Text("Select how you'd like to symbolically release your worry")
                        .font(CalmDesignSystem.Typography.subheadline)
                        .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .minimumScaleFactor(0.7)
                        .allowsTightening(true)
                        .padding(.horizontal, CalmDesignSystem.Spacing.xl)
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
                
                Spacer()
                
                // Text Input Section
                if showTextInput {
                    VStack(spacing: CalmDesignSystem.Spacing.lg) {
                        Text("What's on your mind?")
                            .font(CalmDesignSystem.Typography.headline)
                            .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        TextField("Type your worry here...", text: $worryText, axis: .vertical)
                            .font(CalmDesignSystem.Typography.body)
                            .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                            .padding(CalmDesignSystem.Spacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                                    .fill(CalmDesignSystem.Colors.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                                            .stroke(CalmDesignSystem.Colors.glassBorder, lineWidth: 1)
                                    )
                            )
                            .lineLimit(3...6)
                            .accessibilityLabel("Text input for your worry")
                            .accessibilityHint("Type the worry or thought you want to release")
                        
                        HStack(spacing: CalmDesignSystem.Spacing.lg) {
                            Button("Cancel") {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showTextInput = false
                                    worryText = ""
                                    selectedRitual = nil
                                }
                            }
                            .buttonStyle(CalmSecondaryButtonStyle())
                            
                            Button("Release") {
                                if !worryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    showRitualAnimation = true
                                }
                            }
                            .buttonStyle(CalmPrimaryButtonStyle(color: selectedRitual?.calmColor ?? CalmDesignSystem.Colors.primary))
                            .disabled(worryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                    .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(false)
        .fullScreenCover(isPresented: $showRitualAnimation) {
            if let ritual = selectedRitual {
                RitualAnimationView(
                    ritual: ritual,
                    text: worryText,
                    onComplete: {
                        showRitualAnimation = false
                        showTextInput = false
                        worryText = ""
                        selectedRitual = nil
                    }
                )
                .ignoresSafeArea(.all)
            }
        }
        .sheet(isPresented: $showSubscriptionPaywall) {
            SubscriptionPaywallView()
        }
    }
    
    private func handleRitualSelection(_ ritual: RitualType) {
        HapticFeedback.light()
        
        if ritual.isPremium && !premium.isPremium {
            showSubscriptionPaywall = true
        } else {
            selectedRitual = ritual
            withAnimation(.easeInOut(duration: 0.3)) {
                showTextInput = true
            }
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

// MARK: - Ritual Animation View
struct RitualAnimationView: View {
    let ritual: RitualType
    let text: String
    let onComplete: () -> Void
    
    var body: some View {
        Group {
            switch ritual {
            case .burn:
                CalmBurnAnimationView(worryText: text, onComplete: onComplete)
            case .shred:
                ShredAnimation(text: text, onComplete: onComplete)
            case .bury:
                BuryAnimation(text: text, onComplete: onComplete)
            case .wash:
                WashAnimation(text: text, onComplete: onComplete)
            }
        }
    }
}

#Preview {
    NavigationStack {
        RitualSelectionView()
            .environmentObject(PremiumState())
    }
}
