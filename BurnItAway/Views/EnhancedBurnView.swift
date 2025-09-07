import SwiftUI

struct EnhancedBurnView: View {
    @State private var worryText = ""
    @State private var navigateToAnimation = false
    @State private var navigateToComplete = false
    @State private var navigateToHome = false
    @State private var isAnalyzing = false
    @State private var showLoadingOverlay = false
    @State private var showSubscriptionPaywall = false
    @FocusState private var isTextFieldFocused: Bool

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var premium: PremiumState
    
    var body: some View {
        CalmBackground {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: CalmDesignSystem.Spacing.lg) {
                        Spacer().frame(height: 20)
                        
                        Text("Burn Your Thought")
                            .font(CalmDesignSystem.Typography.largeTitle)
                            .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("Write down what's troubling you, then watch it burn away")
                            .font(CalmDesignSystem.Typography.subheadline)
                            .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                    }
                    .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                    
                    Spacer().frame(height: 40)
                    
                    // Main Content
                    VStack(spacing: CalmDesignSystem.Spacing.xl) {
                        // Text Input
                        VStack(alignment: .leading, spacing: CalmDesignSystem.Spacing.md) {
                            Text("What's on your mind?")
                                .font(CalmDesignSystem.Typography.headline)
                                .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                            
                            ZStack {
                                // Background with border
                                RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                                    .fill(Color.black.opacity(0.3))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                                            .stroke(CalmDesignSystem.Colors.glassBorder, lineWidth: 1)
                                    )
                                    .frame(minHeight: 120)
                                
                                // TextEditor with transparent background
                                TextEditor(text: $worryText)
                                    .font(CalmDesignSystem.Typography.body)
                                    .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                                    .padding(CalmDesignSystem.Spacing.md)
                                    .background(Color.clear)
                                    .scrollContentBackground(.hidden)
                                    .frame(minHeight: 120)
                                    .focused($isTextFieldFocused)
                            }
                                .onChange(of: worryText) { _ in
                                    // Clear any previous state when text changes
                                    if worryText.isEmpty {
                                        return
                                    }
                                    
                                    // AI services removed - keeping simple worry burning experience
                                }
                        }
                        .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                        
                        // Release Button
                        Button(action: analyzeAndProceed) {
                            HStack(spacing: CalmDesignSystem.Spacing.sm) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 18, weight: .medium))
                                Text("Release")
                                    .font(CalmDesignSystem.Typography.button)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, CalmDesignSystem.Spacing.lg)
                        }
                        .buttonStyle(CalmPrimaryButtonStyle(color: CalmDesignSystem.Colors.accent))
                        .disabled(worryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isAnalyzing || !appState.canBurnWorry(isPremium: premium.isPremium))
                        .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                        .accessibilityLabel("Release worry")
                        .accessibilityHint("Double tap to burn away your worry and watch it disappear")
                        .accessibilityAddTraits(.isButton)

                        
                        // Daily limit message
                        if !appState.canBurnWorry(isPremium: premium.isPremium) {
                            dailyLimitCard
                        }
                    }
                    
                    Spacer().frame(height: 100) // Extra space for keyboard
                }
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationDestination(isPresented: $navigateToAnimation) {
            CalmBurnAnimationView(worryText: worryText) {
                // Navigate to complete view after burning animation
                navigateToComplete = true
            }
        }
        .navigationDestination(isPresented: $navigateToComplete) {
            BurnCompleteView()
        }
        .navigationDestination(isPresented: $navigateToHome) {
            ContentView()
        }
        .sheet(isPresented: $showSubscriptionPaywall) {
            SubscriptionPaywallView()
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") {
                        isTextFieldFocused = false
                    }
                    .foregroundColor(CalmDesignSystem.Colors.primary)
                    .font(.system(size: 16, weight: .medium))
                }
            }
        }
        .onAppear {
            // Start with text field focused
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
        .onTapGesture {
            // Dismiss keyboard when tapping outside text field
            isTextFieldFocused = false
        }
    }
    
    // MARK: - Computed Properties
    @ViewBuilder
    private var dailyLimitCard: some View {
        VStack(spacing: CalmDesignSystem.Spacing.md) {
            // Header with emoji
            HStack {
                Text("⏰")
                    .font(.system(size: 24))
                Text("Daily Limit Reached")
                    .font(CalmDesignSystem.Typography.headline)
                    .foregroundColor(CalmDesignSystem.Colors.primary)
                Spacer()
            }
            
            // Content
            VStack(alignment: .leading, spacing: CalmDesignSystem.Spacing.sm) {
                Text("You've used all 7 free burns for today.")
                    .font(CalmDesignSystem.Typography.body)
                    .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                
                Text("Upgrade to Premium for unlimited rituals and continue your healing journey.")
                    .font(CalmDesignSystem.Typography.callout)
                    .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            
            // Upgrade button
            Button("✨ Upgrade to Premium") {
                showSubscriptionPaywall = true
            }
            .buttonStyle(CalmPrimaryButtonStyle(color: CalmDesignSystem.Colors.success))
            .accessibilityLabel("Upgrade to premium")
            .accessibilityHint("Double tap to upgrade to premium for unlimited rituals")
            .accessibilityAddTraits(.isButton)
        }
        .padding(CalmDesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                .fill(CalmDesignSystem.Colors.surface)
                .shadow(color: CalmDesignSystem.Colors.shadow, radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, CalmDesignSystem.Spacing.lg)
        .padding(.bottom, CalmDesignSystem.Spacing.lg)
    }
    
    // MARK: - Actions
    private func analyzeAndProceed() {
        guard !worryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        // Check if user can burn worry
        guard appState.canBurnWorry(isPremium: premium.isPremium) else {
            // Show message that they've reached their daily limit
            return
        }
        
        isAnalyzing = true
        
        // Store the worry and increment count
        appState.addWorry(worryText, category: "general")
        appState.incrementWorryCount()
        
        // Navigate directly to animation after a brief moment
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isAnalyzing = false
            navigateToAnimation = true
        }
    }
}

#Preview {
    EnhancedBurnView()
        .environmentObject(AppState())
        .environmentObject(PremiumState())
}