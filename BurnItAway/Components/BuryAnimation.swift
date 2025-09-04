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
            // Background - realistic earth layers
            ZStack {
                // Deep earth layer
                LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.08, blue: 0.03), // Very dark earth
                        Color(red: 0.25, green: 0.15, blue: 0.08), // Dark earth
                        Color(red: 0.35, green: 0.25, blue: 0.15)  // Medium earth
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Surface texture overlay
                Rectangle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.4, green: 0.3, blue: 0.2).opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 400
                        )
                    )
                    .ignoresSafeArea()
            }
            
            // Ground surface line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.5, green: 0.4, blue: 0.3),
                            Color(red: 0.4, green: 0.3, blue: 0.2)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 4)
                .offset(y: 200)
                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
            
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
                    .offset(y: animationState.progress * 250)
                    .opacity(animationState.progress < 0.6 ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 1.0), value: animationState.progress)
            }
            
            // Earth particles falling with realistic physics
            ForEach(earthParticles, id: \.id) { particle in
                RealisticEarthParticleView(particle: particle)
            }
            
            // Soil mound that grows as text is buried
            if animationState.progress > 0.3 {
                SoilMoundView(progress: animationState.progress)
                    .opacity(animationState.progress > 0.3 ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.5), value: animationState.progress)
            }
            
            // Sprout (optional, appears at the end)
            if showSprout {
                RealisticSproutView()
                    .opacity(showSprout ? 1.0 : 0.0)
                    .scaleEffect(showSprout ? 1.0 : 0.1)
                    .animation(.easeInOut(duration: 1.5), value: showSprout)
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
        earthParticles = (0..<30).map { _ in
            EarthParticle(
                id: UUID(),
                x: CGFloat.random(in: -250...250),
                y: CGFloat.random(in: -50...50),
                size: CGFloat.random(in: 2...6),
                color: Color(red: 0.4, green: 0.3, blue: 0.2),
                opacity: 1.0,
                velocity: CGPoint(x: CGFloat.random(in: -1...1), y: CGFloat.random(in: 1...3)),
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -3...3)
            )
        }
    }
    
    private func updateAnimation() {
        let currentTime = CACurrentMediaTime()
        let elapsedTime = currentTime - startTime
        let totalDuration: Double = 10.0
        
        let progress = min(elapsedTime / totalDuration, 1.0)
        animationState.updateProgress(progress)
        
        // Update earth particles with realistic physics
        for i in earthParticles.indices {
            earthParticles[i].y += earthParticles[i].velocity.y
            earthParticles[i].x += earthParticles[i].velocity.x
            earthParticles[i].rotation += earthParticles[i].rotationSpeed
            
            // Add gravity and air resistance
            earthParticles[i].velocity.y += 0.1
            earthParticles[i].velocity.x *= 0.98
            
            // Fade out as they settle
            if earthParticles[i].y > 250 {
                earthParticles[i].opacity = max(0, 1.0 - (earthParticles[i].y - 250) / 100)
            }
        }
        
        // Show sprout near the end
        if progress > 0.85 && !showSprout {
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
    var velocity: CGPoint
    var rotation: Double
    var rotationSpeed: Double
}

// MARK: - Realistic Earth Particle View
struct RealisticEarthParticleView: View {
    let particle: EarthParticle
    
    var body: some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [
                        particle.color,
                        particle.color.opacity(0.7),
                        particle.color.opacity(0.4)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: particle.size / 2
                )
            )
            .frame(width: particle.size, height: particle.size * 0.8)
            .position(x: particle.x, y: particle.y)
            .rotationEffect(.degrees(particle.rotation))
            .opacity(particle.opacity)
            .shadow(color: Color.black.opacity(0.3), radius: 1, x: 0.5, y: 0.5)
    }
}

// MARK: - Soil Mound View
struct SoilMoundView: View {
    let progress: Double
    
    var body: some View {
        Path { path in
            let width: CGFloat = 300
            let height: CGFloat = 40
            let moundHeight = height * CGFloat(progress - 0.3) / 0.7
            
            path.move(to: CGPoint(x: -width/2, y: 200))
            
            // Create mound shape
            for x in stride(from: -width/2, through: width/2, by: 2) {
                let normalizedX = (x + width/2) / width
                let y = 200 - moundHeight * sin(normalizedX * .pi)
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            path.addLine(to: CGPoint(x: width/2, y: 200))
            path.closeSubpath()
        }
        .fill(
            LinearGradient(
                colors: [
                    Color(red: 0.5, green: 0.4, blue: 0.3),
                    Color(red: 0.4, green: 0.3, blue: 0.2),
                    Color(red: 0.3, green: 0.2, blue: 0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .shadow(color: Color.black.opacity(0.4), radius: 3, x: 0, y: 2)
    }
}

// MARK: - Realistic Sprout View
struct RealisticSproutView: View {
    @State private var isGrowing = false
    @State private var leafGrowth: Double = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Main stem
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.2, green: 0.6, blue: 0.2),
                            Color(red: 0.1, green: 0.4, blue: 0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 3, height: isGrowing ? 35 : 0)
                .animation(.easeInOut(duration: 1.2), value: isGrowing)
            
            // Leaves
            HStack(spacing: 12) {
                // Left leaf
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.3, green: 0.8, blue: 0.3),
                                Color(red: 0.2, green: 0.6, blue: 0.2)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 8
                        )
                    )
                    .frame(width: isGrowing ? 16 : 0, height: isGrowing ? 12 : 0)
                    .rotationEffect(.degrees(-30))
                    .animation(.easeInOut(duration: 0.8).delay(0.6), value: isGrowing)
                
                // Right leaf
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.3, green: 0.8, blue: 0.3),
                                Color(red: 0.2, green: 0.6, blue: 0.2)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 8
                        )
                    )
                    .frame(width: isGrowing ? 16 : 0, height: isGrowing ? 12 : 0)
                    .rotationEffect(.degrees(30))
                    .animation(.easeInOut(duration: 0.8).delay(0.8), value: isGrowing)
            }
            
            // Small center leaf
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.4, green: 0.9, blue: 0.4),
                            Color(red: 0.3, green: 0.7, blue: 0.3)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 6
                    )
                )
                .frame(width: isGrowing ? 12 : 0, height: isGrowing ? 8 : 0)
                .animation(.easeInOut(duration: 0.6).delay(1.0), value: isGrowing)
        }
        .offset(y: 200)
        .onAppear {
            isGrowing = true
        }
    }
}

#Preview {
    BuryAnimation(text: "This is a test worry that will be buried in the earth", onComplete: {})
}
