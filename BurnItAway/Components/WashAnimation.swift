//
//  WashAnimation.swift
//  BurnItAway
//
//  Created by Vaibhav Parashar on 9/4/25.
//

import SwiftUI

struct WashAnimation: View {
    let text: String
    let onComplete: () -> Void
    
    @StateObject private var animationState = RitualAnimationState()
    @State private var showText = true
    @State private var waterDrops: [WaterDrop] = []
    @State private var waveOffset: CGFloat = 0
    @State private var animationTimer: Timer?
    @State private var startTime: CFTimeInterval = 0
    
    var body: some View {
        ZStack {
            // Background - realistic water environment
            ZStack {
                // Deep water gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.2, blue: 0.4), // Deep ocean
                        Color(red: 0.1, green: 0.3, blue: 0.5),  // Medium blue
                        Color(red: 0.2, green: 0.4, blue: 0.6),  // Light blue
                        Color(red: 0.3, green: 0.5, blue: 0.7)   // Surface blue
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Water surface reflection
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.clear,
                                Color.blue.opacity(0.05)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 100)
                    .offset(y: -300)
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
            
            // Multiple water waves for realistic effect
            if animationState.progress > 0.1 {
                RealisticWaterWaveView(offset: waveOffset, intensity: animationState.progress)
                    .opacity(animationState.progress > 0.1 ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.5), value: animationState.progress)
            }
            
            // Secondary wave
            if animationState.progress > 0.3 {
                RealisticWaterWaveView(offset: waveOffset * 1.5, intensity: animationState.progress * 0.7)
                    .opacity(animationState.progress > 0.3 ? 0.6 : 0.0)
                    .animation(.easeInOut(duration: 0.5), value: animationState.progress)
            }
            
            // Water drops with realistic physics
            ForEach(waterDrops, id: \.id) { drop in
                RealisticWaterDropView(drop: drop)
            }
            
            // Water ripples
            if animationState.progress > 0.4 {
                WaterRipplesView(progress: animationState.progress)
                    .opacity(animationState.progress > 0.4 ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.5), value: animationState.progress)
            }
            
            // Progress indicator
            if animationState.isAnimating {
                VStack {
                    Spacer()
                    VStack(spacing: CalmDesignSystem.Spacing.md) {
                        Text("Washing away...")
                            .font(CalmDesignSystem.Typography.caption)
                            .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                            .opacity(animationState.progress > 0.2 ? 1.0 : 0.0)
                            .animation(.easeInOut(duration: 0.5), value: animationState.progress)
                        
                        Text("Symbolic washing only - your thoughts are safe")
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
            startWashAnimation()
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
            .buttonStyle(CalmPrimaryButtonStyle(color: .blue))
            .accessibilityLabel("Continue after washing")
            .accessibilityHint("Double tap to proceed after the thought has been washed away")
            .accessibilityAddTraits(.isButton)
            
            Text("💧")
                .font(.system(size: 100))
                .scaleEffect(animationState.showCompletion ? 1.3 : 0.8)
                .animation(.easeInOut(duration: 0.5), value: animationState.showCompletion)
                .accessibilityHidden(true)
            
            Text("Washed Away")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .allowsTightening(true)
                .accessibilityLabel("Thought washed away")
            
            Text("This was a symbolic washing experience. Your thoughts remain safe.")
                .font(.system(size: 16))
                .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(4)
                .minimumScaleFactor(0.6)
                .allowsTightening(true)
                .padding(.horizontal, 16)
                .accessibilityLabel("This was a symbolic washing experience. Your thoughts remain safe.")
        }
        .padding(.horizontal, 32)
        .opacity(animationState.showCompletion ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 1.0), value: animationState.showCompletion)
    }
    
    private func startWashAnimation() {
        animationState.startAnimation()
        startTime = CACurrentMediaTime()
        createWaterDrops()
        
        // Start animation timer
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            updateAnimation()
        }
    }
    
    private func createWaterDrops() {
        waterDrops = (0..<20).map { _ in
            WaterDrop(
                id: UUID(),
                x: CGFloat.random(in: -250...250),
                y: CGFloat.random(in: -100...50),
                size: CGFloat.random(in: 1.5...4),
                speed: CGFloat.random(in: 0.8...2.5),
                opacity: 1.0,
                velocity: CGPoint(x: CGFloat.random(in: -0.5...0.5), y: CGFloat.random(in: 0.8...2.5)),
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -2...2)
            )
        }
    }
    
    private func updateAnimation() {
        let currentTime = CACurrentMediaTime()
        let elapsedTime = currentTime - startTime
        let totalDuration: Double = 10.0
        
        let progress = min(elapsedTime / totalDuration, 1.0)
        animationState.updateProgress(progress)
        
        // Update water wave with realistic motion
        waveOffset = sin(elapsedTime * 2) * 50 + progress * 300
        
        // Update water drops with realistic physics
        for i in waterDrops.indices {
            waterDrops[i].y += waterDrops[i].velocity.y
            waterDrops[i].x += waterDrops[i].velocity.x
            waterDrops[i].rotation += waterDrops[i].rotationSpeed
            
            // Add gravity and air resistance
            waterDrops[i].velocity.y += 0.05
            waterDrops[i].velocity.x *= 0.995
            
            // Add some wind effect
            waterDrops[i].velocity.x += sin(elapsedTime + Double(i)) * 0.02
            
            // Fade out as they fall
            if waterDrops[i].y > 400 {
                waterDrops[i].opacity = max(0, 1.0 - (waterDrops[i].y - 400) / 200)
            }
            
            // Reset drops that have fallen off screen
            if waterDrops[i].y > 600 {
                waterDrops[i].y = CGFloat.random(in: -100...50)
                waterDrops[i].x = CGFloat.random(in: -250...250)
                waterDrops[i].opacity = 1.0
                waterDrops[i].velocity = CGPoint(x: CGFloat.random(in: -0.5...0.5), y: CGFloat.random(in: 0.8...2.5))
            }
        }
        
        if progress >= 1.0 {
            animationTimer?.invalidate()
            animationState.completeAnimation()
        }
    }
}

// MARK: - Water Drop Model
struct WaterDrop: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var speed: CGFloat
    var opacity: Double
    var velocity: CGPoint
    var rotation: Double
    var rotationSpeed: Double
}

// MARK: - Realistic Water Drop View
struct RealisticWaterDropView: View {
    let drop: WaterDrop
    
    var body: some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [
                        Color.blue.opacity(0.9),
                        Color.blue.opacity(0.6),
                        Color.blue.opacity(0.3)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: drop.size / 2
                )
            )
            .frame(width: drop.size, height: drop.size * 1.2)
            .position(x: drop.x, y: drop.y)
            .rotationEffect(.degrees(drop.rotation))
            .opacity(drop.opacity)
            .shadow(color: Color.blue.opacity(0.3), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Realistic Water Wave View
struct RealisticWaterWaveView: View {
    let offset: CGFloat
    let intensity: Double
    
    var body: some View {
        Path { path in
            let width = UIScreen.main.bounds.width
            let height: CGFloat = 80
            let waveHeight = height * CGFloat(intensity)
            
            path.move(to: CGPoint(x: 0, y: height))
            
            for x in stride(from: 0, through: width, by: 2) {
                let wave1 = sin((x + offset) * 0.015) * waveHeight * 0.8
                let wave2 = sin((x + offset * 1.5) * 0.025) * waveHeight * 0.4
                let y = height + wave1 + wave2
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            path.addLine(to: CGPoint(x: width, y: height + 60))
            path.addLine(to: CGPoint(x: 0, y: height + 60))
            path.closeSubpath()
        }
        .fill(
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.8),
                    Color.blue.opacity(0.5),
                    Color.blue.opacity(0.2),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .offset(y: 200)
        .shadow(color: Color.blue.opacity(0.2), radius: 3, x: 0, y: 2)
    }
}

// MARK: - Water Ripples View
struct WaterRipplesView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(
                        Color.blue.opacity(0.3),
                        lineWidth: 2
                    )
                    .frame(width: 100 + CGFloat(index) * 50, height: 100 + CGFloat(index) * 50)
                    .scaleEffect(1.0 + CGFloat(progress) * 2)
                    .opacity(max(0, 1.0 - CGFloat(progress) * 1.5))
                    .animation(.easeOut(duration: 2.0).delay(Double(index) * 0.3), value: progress)
            }
        }
        .offset(y: 200)
    }
}

#Preview {
    WashAnimation(text: "This is a test worry that will be washed away", onComplete: {})
}
