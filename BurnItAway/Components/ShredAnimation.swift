//
//  ShredAnimation.swift
//  BurnItAway
//
//  Created by Vaibhav Parashar on 9/4/25.
//

import SwiftUI

struct ShredAnimation: View {
    let text: String
    let onComplete: () -> Void
    
    @StateObject private var animationState = RitualAnimationState()
    @State private var shredStrips: [ShredStrip] = []
    @State private var paperParticles: [PaperParticle] = []
    @State private var showText = true
    @State private var animationTimer: Timer?
    @State private var startTime: CFTimeInterval = 0
    @State private var shredderOffset: CGFloat = 0
    @State private var showShredder = false
    
    var body: some View {
        ZStack {
            // Background with subtle texture
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.1),
                    Color(red: 0.1, green: 0.1, blue: 0.15)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Shredder machine (appears at the bottom)
            if showShredder {
                ShredderMachineView(offset: shredderOffset)
                    .offset(y: 200)
            }
            
            if showText {
                // Original text with realistic paper texture
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
                    .offset(y: animationState.progress < 0.4 ? 0 : -50)
                    .opacity(animationState.progress < 0.4 ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8), value: animationState.progress)
            }
            
            // Shred strips with realistic physics
            ForEach(shredStrips, id: \.id) { strip in
                RealisticShredStripView(strip: strip)
            }
            
            // Paper particles
            ForEach(paperParticles, id: \.id) { particle in
                PaperParticleView(particle: particle)
            }
            
            // Progress indicator
            if animationState.isAnimating {
                VStack {
                    Spacer()
                    VStack(spacing: CalmDesignSystem.Spacing.md) {
                        Text("Shredding away...")
                            .font(CalmDesignSystem.Typography.caption)
                            .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                            .opacity(animationState.progress > 0.2 ? 1.0 : 0.0)
                            .animation(.easeInOut(duration: 0.5), value: animationState.progress)
                        
                        Text("Symbolic shredding only - your thoughts are safe")
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
            startShredAnimation()
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
            .buttonStyle(CalmPrimaryButtonStyle(color: .red))
            .accessibilityLabel("Continue after shredding")
            .accessibilityHint("Double tap to proceed after the thought has been shredded")
            .accessibilityAddTraits(.isButton)
            
            Text("🪓")
                .font(.system(size: 100))
                .scaleEffect(animationState.showCompletion ? 1.3 : 0.8)
                .animation(.easeInOut(duration: 0.5), value: animationState.showCompletion)
                .accessibilityHidden(true)
            
            Text("Shredded")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .allowsTightening(true)
                .accessibilityLabel("Thought shredded")
            
            Text("This was a symbolic shredding experience. Your thoughts remain safe.")
                .font(.system(size: 16))
                .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(4)
                .minimumScaleFactor(0.6)
                .allowsTightening(true)
                .padding(.horizontal, 16)
                .accessibilityLabel("This was a symbolic shredding experience. Your thoughts remain safe.")
        }
        .padding(.horizontal, 32)
        .opacity(animationState.showCompletion ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 1.0), value: animationState.showCompletion)
    }
    
    private func startShredAnimation() {
        animationState.startAnimation()
        startTime = CACurrentMediaTime()
        
        // Show shredder machine
        withAnimation(.easeInOut(duration: 0.5)) {
            showShredder = true
        }
        
        // Start shredding after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            createShredStrips()
            createPaperParticles()
        }
        
        // Start animation timer
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            updateAnimation()
        }
    }
    
    private func createShredStrips() {
        let stripCount = 12
        shredStrips = (0..<stripCount).map { index in
            ShredStrip(
                id: UUID(),
                width: CGFloat.random(in: 1.5...4),
                height: CGFloat.random(in: 150...250),
                xOffset: CGFloat(index) * 30 - 180,
                yOffset: -100,
                rotation: Double.random(in: -10...10),
                opacity: 1.0,
                color: Color.white.opacity(0.9),
                velocity: CGPoint(x: CGFloat.random(in: -2...2), y: CGFloat.random(in: 3...8)),
                rotationSpeed: Double.random(in: -5...5)
            )
        }
    }
    
    private func createPaperParticles() {
        paperParticles = (0..<25).map { _ in
            PaperParticle(
                id: UUID(),
                x: CGFloat.random(in: -200...200),
                y: -50,
                size: CGFloat.random(in: 1...3),
                opacity: 1.0,
                velocity: CGPoint(x: CGFloat.random(in: -3...3), y: CGFloat.random(in: 2...6)),
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -10...10)
            )
        }
    }
    
    private func updateAnimation() {
        let currentTime = CACurrentMediaTime()
        let elapsedTime = currentTime - startTime
        let totalDuration: Double = 10.0
        
        let progress = min(elapsedTime / totalDuration, 1.0)
        animationState.updateProgress(progress)
        
        // Update shredder animation
        shredderOffset = sin(elapsedTime * 20) * 2
        
        // Update shred strips with realistic physics
        for i in shredStrips.indices {
            shredStrips[i].yOffset += shredStrips[i].velocity.y
            shredStrips[i].xOffset += shredStrips[i].velocity.x
            shredStrips[i].rotation += shredStrips[i].rotationSpeed
            
            // Add some randomness to movement
            shredStrips[i].velocity.x += CGFloat.random(in: -0.1...0.1)
            shredStrips[i].velocity.y += CGFloat.random(in: 0.05...0.15)
            
            // Fade out as they fall
            if shredStrips[i].yOffset > 300 {
                shredStrips[i].opacity = max(0, 1.0 - (shredStrips[i].yOffset - 300) / 200)
            }
        }
        
        // Update paper particles
        for i in paperParticles.indices {
            paperParticles[i].y += paperParticles[i].velocity.y
            paperParticles[i].x += paperParticles[i].velocity.x
            paperParticles[i].rotation += paperParticles[i].rotationSpeed
            
            // Add gravity and air resistance
            paperParticles[i].velocity.y += 0.1
            paperParticles[i].velocity.x *= 0.99
            
            // Fade out as they fall
            if paperParticles[i].y > 400 {
                paperParticles[i].opacity = max(0, 1.0 - (paperParticles[i].y - 400) / 200)
            }
        }
        
        if progress >= 1.0 {
            animationTimer?.invalidate()
            animationState.completeAnimation()
        }
    }
}

// MARK: - Shred Strip Model
struct ShredStrip: Identifiable {
    let id: UUID
    var width: CGFloat
    var height: CGFloat
    var xOffset: CGFloat
    var yOffset: CGFloat
    var rotation: Double
    var opacity: Double
    var color: Color
    var velocity: CGPoint
    var rotationSpeed: Double
}

// MARK: - Paper Particle Model
struct PaperParticle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
    var velocity: CGPoint
    var rotation: Double
    var rotationSpeed: Double
}

// MARK: - Realistic Shred Strip View
struct RealisticShredStripView: View {
    let strip: ShredStrip
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        strip.color,
                        strip.color.opacity(0.8),
                        strip.color.opacity(0.6)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: strip.width, height: strip.height)
            .overlay(
                // Add paper texture
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.clear,
                                Color.black.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .offset(x: strip.xOffset, y: strip.yOffset)
            .rotationEffect(.degrees(strip.rotation))
            .opacity(strip.opacity)
            .shadow(color: Color.black.opacity(0.3), radius: 2, x: 1, y: 1)
    }
}

// MARK: - Paper Particle View
struct PaperParticleView: View {
    let particle: PaperParticle
    
    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.8))
            .frame(width: particle.size, height: particle.size)
            .position(x: particle.x, y: particle.y)
            .rotationEffect(.degrees(particle.rotation))
            .opacity(particle.opacity)
            .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0.5, y: 0.5)
    }
}

// MARK: - Shredder Machine View
struct ShredderMachineView: View {
    let offset: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            // Shredder body
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.gray.opacity(0.8),
                            Color.gray.opacity(0.6)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 200, height: 60)
                .overlay(
                    // Shredder teeth
                    HStack(spacing: 2) {
                        ForEach(0..<20, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.black.opacity(0.7))
                                .frame(width: 3, height: 8)
                                .offset(y: offset)
                        }
                    }
                )
            
            // Shredder base
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.4))
                .frame(width: 220, height: 20)
        }
        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    ShredAnimation(text: "This is a test worry that will be shredded away", onComplete: {})
}
