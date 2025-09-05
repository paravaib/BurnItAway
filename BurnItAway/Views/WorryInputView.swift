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
    
    // Character limit constants
    private let maxCharacters = 100
    private var remainingCharacters: Int {
        maxCharacters - worryText.count
    }
    private var isNearLimit: Bool {
        remainingCharacters <= 15
    }
    private var isOverLimit: Bool {
        remainingCharacters < 0
    }
    
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
                    
                    VStack(spacing: CalmDesignSystem.Spacing.sm) {
                        TextField("Type your worry here...", text: $worryText, axis: .vertical)
                            .font(CalmDesignSystem.Typography.body)
                            .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                            .padding(CalmDesignSystem.Spacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                                    .fill(CalmDesignSystem.Colors.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                                            .stroke(
                                                isOverLimit ? CalmDesignSystem.Colors.error : 
                                                isNearLimit ? CalmDesignSystem.Colors.warning : 
                                                CalmDesignSystem.Colors.glassBorder, 
                                                lineWidth: isOverLimit ? 2 : 1
                                            )
                                    )
                            )
                            .lineLimit(3...6)
                            .accessibilityLabel("Text input for your worry")
                            .accessibilityHint("Type the worry or thought you want to release")
                        
                        // Character counter
                        HStack {
                            Spacer()
                            Text("\(worryText.count)/\(maxCharacters)")
                                .font(CalmDesignSystem.Typography.caption)
                                .foregroundColor(
                                    isOverLimit ? CalmDesignSystem.Colors.error :
                                    isNearLimit ? CalmDesignSystem.Colors.warning :
                                    CalmDesignSystem.Colors.textSecondary
                                )
                                .animation(.easeInOut(duration: 0.2), value: isOverLimit)
                                .animation(.easeInOut(duration: 0.2), value: isNearLimit)
                        }
                        .padding(.horizontal, CalmDesignSystem.Spacing.sm)
                    }
                    
                    // Symbolic message or limit warning
                    if isOverLimit {
                        Text("Please shorten your message to continue")
                            .font(CalmDesignSystem.Typography.caption)
                            .foregroundColor(CalmDesignSystem.Colors.error)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, CalmDesignSystem.Spacing.lg)
                    } else if isNearLimit {
                        Text("Almost at the limit - keep it concise for the best experience")
                            .font(CalmDesignSystem.Typography.caption)
                            .foregroundColor(CalmDesignSystem.Colors.warning)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, CalmDesignSystem.Spacing.lg)
                    } else {
                        Text("This is a symbolic \(ritual.displayName.lowercased()) experience. Your thoughts remain safe.")
                            .font(CalmDesignSystem.Typography.caption)
                            .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .opacity(0.8)
                            .padding(.horizontal, CalmDesignSystem.Spacing.lg)
                    }
                }
                .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: CalmDesignSystem.Spacing.lg) {
                    Button("\(ritual.emoji) \(ritual.displayName) This Worry") {
                        if !worryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isOverLimit {
                            HapticFeedback.medium()
                            showRitualAnimation = true
                        } else if isOverLimit {
                            HapticFeedback.error()
                        }
                    }
                    .buttonStyle(CalmPrimaryButtonStyle(color: ritual.calmColor))
                    .disabled(worryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isOverLimit)
                    .accessibilityLabel("\(ritual.displayName) this worry")
                    .accessibilityHint(isOverLimit ? "Text is too long. Please shorten your message." : "Double tap to start the \(ritual.displayName.lowercased()) ritual")
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
                    // Add a small delay for smooth transition
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showRitualAnimation = false
                        // Add another small delay before dismissing
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            dismiss()
                        }
                    }
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
            ZStack {
                // Ritual Animation (background)
                Group {
                    switch ritual {
                    case .burn:
                        EnhancedRitualView(ritualType: "burn", text: text, onComplete: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showingCelebration = true
                            }
                        })
                    case .smoke:
                        EnhancedRitualView(ritualType: "smoke", text: text, onComplete: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showingCelebration = true
                            }
                        })
                    case .space:
                        EnhancedRitualView(ritualType: "space", text: text, onComplete: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showingCelebration = true
                            }
                        })
                    case .wash:
                        EnhancedRitualView(ritualType: "wash", text: text, onComplete: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showingCelebration = true
                            }
                        })
                    }
                }
                .opacity(showingCelebration ? 0.0 : 1.0)
                .animation(.easeInOut(duration: 0.5), value: showingCelebration)
                
                // Celebration View (overlay)
                if showingCelebration {
                    RitualCelebrationView(
                        feedback: RitualCompletionFeedback.generateFeedback(for: wellnessProgress, ritual: ritual),
                        progress: wellnessProgress,
                        onContinue: {
                            wellnessProgress.completeRitual(ritual)
                            onComplete()
                        }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .animation(.easeInOut(duration: 0.5), value: showingCelebration)
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
