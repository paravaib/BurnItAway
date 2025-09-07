//
//  ContentView.swift
//  BurnItAway
//
//  Created by Vaibhav Parashar on 9/1/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var premium: PremiumState
    @State private var showBreathingIndicator = false
    @State private var showSubscriptionPaywall = false
    
    var body: some View {
        NavigationStack {
            CalmBackground {
                VStack(spacing: CalmDesignSystem.Spacing.xxl) {
                    // Header with breathing indicator
                    VStack(spacing: CalmDesignSystem.Spacing.lg) {
                        if showBreathingIndicator {
                            BreathingIndicator()
                                .transition(.opacity.combined(with: .scale))
                        }
                        
                        Text("Burn It Away")
                            .font(CalmDesignSystem.Typography.largeTitle)
                            .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                            .opacity(0.9)
                        
                        Text("Release your worries, find your peace")
                            .font(CalmDesignSystem.Typography.subheadline)
                            .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                        
                        // First-time user hint
                        if !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
                            Text("💡 Tap the ? icon below to learn how to use this app")
                                .font(CalmDesignSystem.Typography.caption)
                                .foregroundColor(CalmDesignSystem.Colors.primary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                                .padding(.top, CalmDesignSystem.Spacing.sm)
                        }
                    }
                    .padding(.top, CalmDesignSystem.Spacing.xxxl)
                    
                    Spacer()
                    
                    // Main burn button
                    VStack(spacing: CalmDesignSystem.Spacing.xl) {
                        ZStack {
                            // Subtle floating particles around the button
                            FloatingParticles()
                            
                            NavigationLink("Release Your Worry") { 
                                RitualSelectionView()
                            }
                                .buttonStyle(CalmPrimaryButtonStyle())
                                .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                                .accessibilityLabel("Release your worry")
                                .accessibilityHint("Double tap to choose how to symbolically release your worry")
                                .accessibilityAddTraits(.isButton)
                        }
                        
                        // Premium photo burning option
                        if premium.isPremium {
                            NavigationLink("📸 Burn Your Memory") { PhotoBurnView() }
                                .buttonStyle(CalmPrimaryButtonStyle(color: .purple))
                                .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                                .accessibilityLabel("Burn photo to release visual memories")
                                .accessibilityHint("Premium feature to burn and delete photos")
                        }
                        
                        // Worry count display
                        if !premium.isPremium {
                            VStack(spacing: CalmDesignSystem.Spacing.sm) {
                                Text("Daily Burns: \(appState.getRemainingFreeBurns()) remaining")
                                    .font(CalmDesignSystem.Typography.callout)
                                    .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                                
                                Text("Resets daily at midnight")
                                    .font(CalmDesignSystem.Typography.caption)
                                    .foregroundColor(CalmDesignSystem.Colors.textTertiary)
                                    .opacity(0.8)
                                
                                Text("✨ Premium: Unlimited burns + Photo burning")
                                    .font(CalmDesignSystem.Typography.caption)
                                    .foregroundColor(CalmDesignSystem.Colors.primary)
                                    .opacity(0.9)
                                
                                if appState.getRemainingFreeBurns() <= 3 {
                                    Button(action: {
                                        HapticFeedback.light()
                                        showSubscriptionPaywall = true
                                    }) {
                                        VStack(spacing: 4) {
                                            Text("✨ Start Free Trial")
                                                .font(CalmDesignSystem.Typography.callout)
                                                .fontWeight(.medium)
                                            Text("7 days free, then $2.99/month")
                                                .font(CalmDesignSystem.Typography.caption)
                                                .opacity(0.9)
                                        }
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.7)
                                        .allowsTightening(true)
                                    }
                                    .buttonStyle(CalmSecondaryButtonStyle())
                                    .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                                    .accessibilityLabel("Start free trial")
                                    .accessibilityHint("Double tap to start a 7-day free trial of premium features")
                                    .accessibilityAddTraits(.isButton)
                                }
                            }
                        } else {
                            VStack(spacing: CalmDesignSystem.Spacing.md) {
                                // Show trial status if in trial
                                if SubscriptionManager.shared.isInFreeTrial() {
                                    TrialStatusView()
                                        .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                                }
                                
                                // Premium active status
                                HStack(spacing: CalmDesignSystem.Spacing.sm) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(CalmDesignSystem.Colors.accent)
                                        .font(.system(size: 16, weight: .medium))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Premium Active")
                                            .font(CalmDesignSystem.Typography.callout)
                                            .fontWeight(.medium)
                                            .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                                        Text("Unlimited Burns + Photo Burning")
                                            .font(CalmDesignSystem.Typography.caption)
                                            .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                                            .opacity(0.8)
                                    }
                                }
                                .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                            }
                        }
                    }
                    
                    Spacer()
                    
                                            // Help, Progress, and Settings buttons
                    HStack(spacing: CalmDesignSystem.Spacing.lg) {
                        // Help button
                        NavigationLink {
                            HelpAboutView()
                        } label: {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                                .padding(CalmDesignSystem.Spacing.md)
                                .background(
                                    Circle()
                                        .fill(CalmDesignSystem.Colors.surface.opacity(0.5))
                                )
                        }
                        .accessibilityLabel("Help and information about the app")
                        .accessibilityHint("Learn about how to use BurnItAway and the psychology behind it")
                        
                        Spacer()
                        
                        // Premium button (always visible for reviewers)
                        if !premium.isPremium {
                            Button(action: {
                                HapticFeedback.light()
                                showSubscriptionPaywall = true
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 14, weight: .medium))
                                    Text("Premium")
                                        .font(CalmDesignSystem.Typography.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(CalmDesignSystem.Colors.primary)
                                .padding(.horizontal, CalmDesignSystem.Spacing.md)
                                .padding(.vertical, CalmDesignSystem.Spacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.md)
                                        .fill(CalmDesignSystem.Colors.primary.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.md)
                                                .stroke(CalmDesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .accessibilityLabel("Upgrade to Premium")
                            .accessibilityHint("Double tap to view premium subscription options")
                        }
                        
                        Spacer()
                        
                        // Settings button
                        NavigationLink {
                            SettingsView()
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                                .padding(CalmDesignSystem.Spacing.md)
                                .background(
                                    Circle()
                                        .fill(CalmDesignSystem.Colors.surface.opacity(0.5))
                                )
                        }
                        .accessibilityLabel("App settings")
                        .accessibilityHint("Configure sound, haptics, and other app preferences")
                    }
                    .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                    .padding(.bottom, CalmDesignSystem.Spacing.xxxl)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                // Start breathing indicator after a brief delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(CalmDesignSystem.Animations.gentle) {
                        showBreathingIndicator = true
                    }
                }
                
                // Load subscription products
                Task {
                    await premium.loadProducts()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DismissToHome"))) { _ in
                // Handle dismissal to home - this will be handled by the navigation system
            }
            .sheet(isPresented: $showSubscriptionPaywall) {
                SubscriptionPaywallView()
            }
        }
    }
}

// MARK: - Floating Particles Animation
struct FloatingParticles: View {
    @State private var particles: [Particle] = []
    @State private var animationTimer: Timer?
    @State private var isActive = false
    
    var body: some View {
        ZStack {
            ForEach(particles, id: \.id) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
                    .blur(radius: particle.blur)
            }
        }
        .onAppear {
            isActive = true
            createParticles()
            startFloatingAnimation()
        }
        .onDisappear {
            isActive = false
            stopFloatingAnimation()
        }
    }
    
    private func createParticles() {
        particles = (0..<8).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 50...300),
                    y: CGFloat.random(in: 50...200)
                ),
                color: CalmDesignSystem.Colors.fireOrange.opacity(0.3),
                size: CGFloat.random(in: 2...4),
                opacity: Double.random(in: 0.2...0.6),
                blur: CGFloat.random(in: 0.5...1.5)
            )
        }
    }
    
    private func startFloatingAnimation() {
        guard isActive else { return }
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard self.isActive else {
                self.stopFloatingAnimation()
                return
            }
            withAnimation(.easeInOut(duration: 0.1)) {
                for i in particles.indices {
                    particles[i].position.x += CGFloat.random(in: -1...1)
                    particles[i].position.y += CGFloat.random(in: -0.5...0.5)
                    particles[i].opacity = Double.random(in: 0.2...0.6)
                }
            }
        }
    }
    
    private func stopFloatingAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
}

struct Particle {
    let id = UUID()
    var position: CGPoint
    let color: Color
    let size: CGFloat
    var opacity: Double
    let blur: CGFloat
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(PremiumState())
}
