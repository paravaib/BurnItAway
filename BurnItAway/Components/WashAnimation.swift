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
            // Background - water tones
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.3, blue: 0.5), // Deep blue
                    Color(red: 0.2, green: 0.4, blue: 0.6),  // Medium blue
                    Color(red: 0.3, green: 0.5, blue: 0.7)   // Light blue
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
                    .opacity(animationState.progress < 0.6 ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 1.0), value: animationState.progress)
            }
            
            // Water wave
            if animationState.progress > 0.2 {
                WaterWaveView(offset: waveOffset)
                    .opacity(animationState.progress > 0.2 ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.5), value: animationState.progress)
            }
            
            // Water drops
            ForEach(waterDrops, id: \.id) { drop in
                WaterDropView(drop: drop)
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
        waterDrops = (0..<15).map { _ in
            WaterDrop(
                id: UUID(),
                x: CGFloat.random(in: -200...200),
                y: -100,
                size: CGFloat.random(in: 2...6),
                speed: CGFloat.random(in: 1...3),
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
        
        // Update water wave
        waveOffset = progress * 400
        
        // Update water drops
        for i in waterDrops.indices {
            waterDrops[i].y += waterDrops[i].speed
            waterDrops[i].opacity = max(0, 1.0 - progress * 1.3)
            
            // Reset drops that have fallen off screen
            if waterDrops[i].y > 800 {
                waterDrops[i].y = -100
                waterDrops[i].x = CGFloat.random(in: -200...200)
                waterDrops[i].opacity = 1.0
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
}

// MARK: - Water Drop View
struct WaterDropView: View {
    let drop: WaterDrop
    
    var body: some View {
        Circle()
            .fill(Color.blue.opacity(0.7))
            .frame(width: drop.size, height: drop.size)
            .position(x: drop.x, y: drop.y)
            .opacity(drop.opacity)
    }
}

// MARK: - Water Wave View
struct WaterWaveView: View {
    let offset: CGFloat
    
    var body: some View {
        Path { path in
            let width = UIScreen.main.bounds.width
            let height: CGFloat = 100
            
            path.move(to: CGPoint(x: 0, y: height))
            
            for x in stride(from: 0, through: width, by: 1) {
                let y = height + sin((x + offset) * 0.02) * 20
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            path.addLine(to: CGPoint(x: width, y: height + 50))
            path.addLine(to: CGPoint(x: 0, y: height + 50))
            path.closeSubpath()
        }
        .fill(
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.6),
                    Color.blue.opacity(0.3),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .offset(y: 200)
    }
}

#Preview {
    WashAnimation(text: "This is a test worry that will be washed away", onComplete: {})
}
