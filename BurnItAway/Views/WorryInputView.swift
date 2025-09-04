//
//  WorryInputView.swift
//  BurnItAway
//
//  Created by Vaibhav Parashar on 9/4/25.
//

import SwiftUI

struct WorryInputView: View {
    let ritual: RitualType
    @State private var worryText = ""
    @State private var showRitualAnimation = false
    @State private var showingCelebration = false
    @StateObject private var wellnessProgress = WellnessProgress()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        CalmBackground {
            VStack(spacing: CalmDesignSystem.Spacing.xxl) {
                // Header
                VStack(spacing: CalmDesignSystem.Spacing.lg) {
                    Text("\(ritual.emoji) \(ritual.displayName) Your Worry")
                        .font(CalmDesignSystem.Typography.largeTitle)
                        .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .allowsTightening(true)
                        .multilineTextAlignment(.center)
                    
                    Text(ritual.description)
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
                
                // Text Input Section
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
                    
                    // Symbolic message
                    Text("This is a symbolic \(ritual.displayName.lowercased()) experience. Your thoughts remain safe.")
                        .font(CalmDesignSystem.Typography.caption)
                        .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(0.8)
                        .padding(.horizontal, CalmDesignSystem.Spacing.lg)
                }
                .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: CalmDesignSystem.Spacing.lg) {
                    Button("\(ritual.emoji) \(ritual.displayName) This Worry") {
                        if !worryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            HapticFeedback.medium()
                            showRitualAnimation = true
                        }
                    }
                    .buttonStyle(CalmPrimaryButtonStyle(color: ritual.calmColor))
                    .disabled(worryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityLabel("\(ritual.displayName) this worry")
                    .accessibilityHint("Double tap to start the \(ritual.displayName.lowercased()) ritual")
                    .accessibilityAddTraits(.isButton)
                    
                    Button("Back to Rituals") {
                        HapticFeedback.light()
                        dismiss()
                    }
                    .buttonStyle(CalmSecondaryButtonStyle())
                    .accessibilityLabel("Back to ritual selection")
                    .accessibilityHint("Double tap to return to ritual selection")
                    .accessibilityAddTraits(.isButton)
                }
                .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                .padding(.bottom, CalmDesignSystem.Spacing.xxxl)
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showRitualAnimation) {
            RitualAnimationView(
                ritual: ritual,
                text: worryText,
                onComplete: {
                    showRitualAnimation = false
                    dismiss()
                }
            )
            .ignoresSafeArea(.all)
        }
    }
}

// Helper view to wrap different ritual animations
    struct RitualAnimationView: View {
        let ritual: RitualType
        let text: String
        let onComplete: () -> Void
        @StateObject private var wellnessProgress = WellnessProgress()
        @State private var showingCelebration = false
        
        var body: some View {
            Group {
                if showingCelebration {
                    RitualCelebrationView(
                        feedback: RitualCompletionFeedback.generateFeedback(for: wellnessProgress, ritual: ritual),
                        progress: wellnessProgress,
                        onContinue: {
                            wellnessProgress.completeRitual(ritual)
                            onComplete()
                        }
                    )
                } else {
                    Group {
                        switch ritual {
                        case .burn:
                            EnhancedRitualView(ritualType: "burn", text: text, onComplete: {
                                showingCelebration = true
                            })
                        case .smoke:
                            EnhancedRitualView(ritualType: "smoke", text: text, onComplete: {
                                showingCelebration = true
                            })
                        case .space:
                            EnhancedRitualView(ritualType: "space", text: text, onComplete: {
                                showingCelebration = true
                            })
                        case .wash:
                            EnhancedRitualView(ritualType: "wash", text: text, onComplete: {
                                showingCelebration = true
                            })
                        }
                    }
                }
            }
            .onAppear {
                wellnessProgress.loadProgress()
            }
        }
    }

#Preview {
    NavigationStack {
        WorryInputView(ritual: .burn)
    }
}
