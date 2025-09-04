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
    @State private var showText = true
    @State private var animationTimer: Timer?
    @State private var startTime: CFTimeInterval = 0
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            if showText {
                // Original text
                Text(text)
                    .font(CalmDesignSystem.Typography.largeTitle)
                    .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                    .opacity(animationState.progress < 0.3 ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.5), value: animationState.progress)
            }
            
            // Shred strips
            ForEach(shredStrips, id: \.id) { strip in
                ShredStripView(strip: strip)
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
        createShredStrips()
        
        // Start animation timer
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            updateAnimation()
        }
    }
    
    private func createShredStrips() {
        let stripCount = 8
        shredStrips = (0..<stripCount).map { index in
            ShredStrip(
                id: UUID(),
                width: CGFloat.random(in: 2...6),
                height: 200,
                xOffset: CGFloat(index) * 40 - 140,
                yOffset: 0,
                rotation: Double.random(in: -5...5),
                opacity: 1.0,
                color: Color.red.opacity(0.8)
            )
        }
    }
    
    private func updateAnimation() {
        let currentTime = CACurrentMediaTime()
        let elapsedTime = currentTime - startTime
        let totalDuration: Double = 8.0
        
        let progress = min(elapsedTime / totalDuration, 1.0)
        animationState.updateProgress(progress)
        
        // Update shred strips
        for i in shredStrips.indices {
            shredStrips[i].yOffset = progress * 400
            shredStrips[i].rotation += 2
            shredStrips[i].opacity = max(0, 1.0 - progress * 1.5)
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
}

// MARK: - Shred Strip View
struct ShredStripView: View {
    let strip: ShredStrip
    
    var body: some View {
        Rectangle()
            .fill(strip.color)
            .frame(width: strip.width, height: strip.height)
            .offset(x: strip.xOffset, y: strip.yOffset)
            .rotationEffect(.degrees(strip.rotation))
            .opacity(strip.opacity)
            .animation(.easeInOut(duration: 0.1), value: strip.yOffset)
    }
}

#Preview {
    ShredAnimation(text: "This is a test worry that will be shredded away", onComplete: {})
}
