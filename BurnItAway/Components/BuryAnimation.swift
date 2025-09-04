//
//  BuryAnimation.swift
//  BurnItAway
//
//  Created by Vaibhav Parashar on 9/4/25.
//

import SwiftUI

struct BuryAnimation: View {
    let text: String
    let onComplete: () -> Void
    
    @StateObject private var animationState = RitualAnimationState()
    @State private var showText = true
    @State private var earthParticles: [EarthParticle] = []
    @State private var showSprout = false
    @State private var animationTimer: Timer?
    @State private var startTime: CFTimeInterval = 0
    
    var body: some View {
        ZStack {
            // Background - earth tones
            LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.1, blue: 0.05), // Dark earth
                    Color(red: 0.3, green: 0.2, blue: 0.1),  // Medium earth
                    Color(red: 0.4, green: 0.3, blue: 0.2)   // Light earth
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if showText {
                // Original text
                Text(text)
                    .font(CalmDesignSystem.Typography.largeTitle)
                    .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                    .offset(y: animationState.progress * 200)
                    .opacity(animationState.progress < 0.7 ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8), value: animationState.progress)
            }
            
            // Earth particles falling
            ForEach(earthParticles, id: \.id) { particle in
                EarthParticleView(particle: particle)
            }
            
            // Sprout (optional, appears at the end)
            if showSprout {
                SproutView()
                    .opacity(showSprout ? 1.0 : 0.0)
                    .scaleEffect(showSprout ? 1.0 : 0.1)
                    .animation(.easeInOut(duration: 1.0), value: showSprout)
            }
            
            // Progress indicator
            if animationState.isAnimating {
                VStack {
                    Spacer()
                    VStack(spacing: CalmDesignSystem.Spacing.md) {
                        Text("Burying away...")
                            .font(CalmDesignSystem.Typography.caption)
                            .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                            .opacity(animationState.progress > 0.2 ? 1.0 : 0.0)
                            .animation(.easeInOut(duration: 0.5), value: animationState.progress)
                        
                        Text("Symbolic burying only - your thoughts are safe")
                            .font(CalmDesignSystem.Typography.caption)
                            .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                            .opacity(animationState.progress > 0.2 ? 0.8 : 0.0)
                            .multilineTextAlignment(.center)
                            .animation(.easeInOut(duration: 0.5), value: animationState.progress)
                    }
                    .padding(.bottom, CalmDesignSystem.Spacing.xxxl)
                }
            }
            
            // Completion view
            if animationState.showCompletion {
                completionView
            }
        }
        .onAppear {
            startBuryAnimation()
        }
        .onDisappear {
            animationTimer?.invalidate()
        }
    }
    
    @ViewBuilder
    private var completionView: some View {
        VStack(spacing: 30) {
            Button("Continue") {
                HapticFeedback.light()
                onComplete()
            }
            .buttonStyle(CalmPrimaryButtonStyle(color: .brown))
            .accessibilityLabel("Continue after burying")
            .accessibilityHint("Double tap to proceed after the thought has been buried")
            .accessibilityAddTraits(.isButton)
            
            Text("🌱")
                .font(.system(size: 100))
                .scaleEffect(animationState.showCompletion ? 1.3 : 0.8)
                .animation(.easeInOut(duration: 0.5), value: animationState.showCompletion)
                .accessibilityHidden(true)
            
            Text("Buried")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .allowsTightening(true)
                .accessibilityLabel("Thought buried")
            
            Text("This was a symbolic burying experience. Your thoughts remain safe.")
                .font(.system(size: 16))
                .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(4)
                .minimumScaleFactor(0.6)
                .allowsTightening(true)
                .padding(.horizontal, 16)
                .accessibilityLabel("This was a symbolic burying experience. Your thoughts remain safe.")
        }
        .padding(.horizontal, 32)
        .opacity(animationState.showCompletion ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 1.0), value: animationState.showCompletion)
    }
    
    private func startBuryAnimation() {
        animationState.startAnimation()
        startTime = CACurrentMediaTime()
        createEarthParticles()
        
        // Start animation timer
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            updateAnimation()
        }
    }
    
    private func createEarthParticles() {
        earthParticles = (0..<20).map { _ in
            EarthParticle(
                id: UUID(),
                x: CGFloat.random(in: -200...200),
                y: -100,
                size: CGFloat.random(in: 3...8),
                color: Color(red: 0.4, green: 0.3, blue: 0.2),
                opacity: 1.0
            )
        }
    }
    
    private func updateAnimation() {
        let currentTime = CACurrentMediaTime()
        let elapsedTime = currentTime - startTime
        let totalDuration: Double = 8.0
        
        let progress = min(elapsedTime / totalDuration, 1.0)
        animationState.updateProgress(progress)
        
        // Update earth particles
        for i in earthParticles.indices {
            earthParticles[i].y += 2
            earthParticles[i].opacity = max(0, 1.0 - progress * 1.2)
        }
        
        // Show sprout near the end
        if progress > 0.8 && !showSprout {
            showSprout = true
        }
        
        if progress >= 1.0 {
            animationTimer?.invalidate()
            animationState.completeAnimation()
        }
    }
}

// MARK: - Earth Particle Model
struct EarthParticle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var color: Color
    var opacity: Double
}

// MARK: - Earth Particle View
struct EarthParticleView: View {
    let particle: EarthParticle
    
    var body: some View {
        Circle()
            .fill(particle.color)
            .frame(width: particle.size, height: particle.size)
            .position(x: particle.x, y: particle.y)
            .opacity(particle.opacity)
    }
}

// MARK: - Sprout View
struct SproutView: View {
    @State private var isGrowing = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Stem
            Rectangle()
                .fill(Color.green)
                .frame(width: 4, height: isGrowing ? 30 : 0)
                .animation(.easeInOut(duration: 1.0), value: isGrowing)
            
            // Leaves
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.green)
                    .frame(width: isGrowing ? 12 : 0, height: isGrowing ? 12 : 0)
                    .animation(.easeInOut(duration: 1.0).delay(0.5), value: isGrowing)
                
                Circle()
                    .fill(Color.green)
                    .frame(width: isGrowing ? 12 : 0, height: isGrowing ? 12 : 0)
                    .animation(.easeInOut(duration: 1.0).delay(0.7), value: isGrowing)
            }
        }
        .onAppear {
            isGrowing = true
        }
    }
}

#Preview {
    BuryAnimation(text: "This is a test worry that will be buried in the earth", onComplete: {})
}
