//
//  SmokeAnimation.swift
//  BurnItAway
//
//  Created by Vaibhav Parashar on 9/4/25.
//

import SwiftUI

struct SmokeAnimation: View {
    let text: String
    let onComplete: () -> Void
    
    @StateObject private var animationState = RitualAnimationState()
    @State private var smokeParticles: [SmokeParticle] = []
    @State private var showText = true
    @State private var animationTimer: Timer?
    @State private var startTime: CFTimeInterval = 0
    
    var body: some View {
        ZStack {
            // Background - smoky atmosphere
            ZStack {
                // Deep smoky gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.1), // Dark base
                        Color(red: 0.2, green: 0.2, blue: 0.2), // Medium gray
                        Color(red: 0.3, green: 0.3, blue: 0.3)  // Light gray
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Atmospheric overlay
                Rectangle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.clear,
                                Color.gray.opacity(0.05)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 400
                        )
                    )
                    .ignoresSafeArea()
            }
            
            if showText {
                // Original text with paper-like appearance
                Text(text)
                    .font(CalmDesignSystem.Typography.largeTitle)
                    .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .opacity(animationState.progress < 0.5 ? 1.0 : 0.0)
                    .scaleEffect(animationState.progress < 0.5 ? 1.0 : 0.8)
                    .animation(.easeInOut(duration: 1.0), value: animationState.progress)
            }
            
            // Smoke particles with realistic physics
            ForEach(smokeParticles, id: \.id) { particle in
                RealisticSmokeParticleView(particle: particle)
            }
            
            // Progress indicator
            if animationState.isAnimating {
                VStack {
                    Spacer()
                    VStack(spacing: CalmDesignSystem.Spacing.md) {
                        Text("Dissolving into smoke...")
                            .font(CalmDesignSystem.Typography.caption)
                            .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                            .opacity(animationState.progress > 0.2 ? 1.0 : 0.0)
                            .animation(.easeInOut(duration: 0.5), value: animationState.progress)
                        
                        Text("Symbolic smoking only - your thoughts are safe")
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
            startSmokeAnimation()
        }
        .onDisappear {
            animationTimer?.invalidate()
        }
    }
    
    @ViewBuilder
    private var completionView: some View {
        VStack(spacing: 30) {
            Button("Continue") {
                HapticFeedback.medium()
                onComplete()
            }
            .buttonStyle(CalmPrimaryButtonStyle(color: CalmDesignSystem.Colors.fireOrange))
            .accessibilityLabel("Continue")
            .accessibilityHint("Double tap to continue")
            .accessibilityAddTraits(.isButton)
        }
        .padding(.horizontal, 32)
        .opacity(animationState.showCompletion ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 1.0), value: animationState.showCompletion)
    }
    
    private func startSmokeAnimation() {
        animationState.startAnimation()
        startTime = CACurrentMediaTime()
        createSmokeParticles()
        
        // Start animation timer
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            updateAnimation()
        }
    }
    
    private func createSmokeParticles() {
        smokeParticles = (0..<25).map { _ in
            SmokeParticle(
                id: UUID(),
                x: CGFloat.random(in: -200...200),
                y: CGFloat.random(in: -50...50),
                size: CGFloat.random(in: 2...8),
                opacity: 1.0,
                velocity: CGPoint(x: CGFloat.random(in: -1...1), y: CGFloat.random(in: -2...(-0.5))),
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -2...2),
                scale: CGFloat.random(in: 0.5...1.5)
            )
        }
    }
    
    private func updateAnimation() {
        let currentTime = CACurrentMediaTime()
        let elapsedTime = currentTime - startTime
        let totalDuration: Double = 10.0
        
        let progress = min(elapsedTime / totalDuration, 1.0)
        animationState.updateProgress(progress)
        
        // Update smoke particles with realistic physics
        for i in smokeParticles.indices {
            smokeParticles[i].y += smokeParticles[i].velocity.y
            smokeParticles[i].x += smokeParticles[i].velocity.x
            smokeParticles[i].rotation += smokeParticles[i].rotationSpeed
            
            // Add upward drift and expansion
            smokeParticles[i].velocity.y -= 0.02 // Upward drift
            smokeParticles[i].velocity.x *= 0.99 // Air resistance
            smokeParticles[i].scale += 0.01 // Expansion
            
            // Fade out as they rise
            if smokeParticles[i].y < -200 {
                smokeParticles[i].opacity = max(0, 1.0 - (-smokeParticles[i].y - 200) / 200)
            }
        }
        
        if progress >= 1.0 {
            animationTimer?.invalidate()
            animationState.completeAnimation()
        }
    }
}

// MARK: - Smoke Particle Model
struct SmokeParticle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
    var velocity: CGPoint
    var rotation: Double
    var rotationSpeed: Double
    var scale: CGFloat
}

// MARK: - Realistic Smoke Particle View
struct RealisticSmokeParticleView: View {
    let particle: SmokeParticle
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.8),
                        Color.gray.opacity(0.6),
                        Color.gray.opacity(0.3),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: particle.size / 2
                )
            )
            .frame(width: particle.size, height: particle.size)
            .position(x: particle.x, y: particle.y)
            .rotationEffect(.degrees(particle.rotation))
            .scaleEffect(particle.scale)
            .opacity(particle.opacity)
            .blur(radius: 1)
    }
}

#Preview {
    SmokeAnimation(text: "This is a test worry that will dissolve into smoke", onComplete: {})
}
