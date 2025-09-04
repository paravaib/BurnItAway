import SwiftUI

struct SpaceAnimation: View {
    let text: String
    let onComplete: () -> Void
    
    @StateObject private var animationState = RitualAnimationState()
    @State private var spaceParticles: [SpaceParticle] = []
    @State private var animationTimer: Timer?
    @State private var startTime: CFTimeInterval = 0
    
    var body: some View {
        ZStack {
            // Background - cosmic gradient
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.05, blue: 0.2),
                    Color(red: 0.15, green: 0.1, blue: 0.25),
                    Color(red: 0.2, green: 0.15, blue: 0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Stars background
            ForEach(0..<50, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .opacity(animationState.progress > 0.2 ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 2.0), value: animationState.progress)
            }
            
            // Original text (fades out)
            Text(text)
                .font(CalmDesignSystem.Typography.largeTitle)
                .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                        )
                )
                .offset(y: animationState.progress * -50) // Gentle upward drift
                .opacity(animationState.progress < 0.6 ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 1.0), value: animationState.progress)
            
            // Space particles
            ForEach(spaceParticles, id: \.id) { particle in
                CosmicParticleView(particle: particle)
            }
            
            // Progress indicator
            if animationState.isAnimating {
                VStack {
                    Spacer()
                    VStack(spacing: CalmDesignSystem.Spacing.md) {
                        Text("Releasing into space...")
                            .font(CalmDesignSystem.Typography.caption)
                            .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                            .opacity(animationState.progress > 0.2 ? 1.0 : 0.0)
                            .animation(.easeInOut(duration: 0.5), value: animationState.progress)
                        
                        Text("Symbolic space release only - your thoughts are safe")
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
            startSpaceAnimation()
        }
        .onDisappear {
            animationTimer?.invalidate()
        }
    }
    
    @ViewBuilder
    private var completionView: some View {
        VStack(spacing: 30) {
            Text("Released into the Cosmos")
                .font(CalmDesignSystem.Typography.title)
                .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .accessibilityLabel("Your worry has been released into the cosmos.")
            
            Text("This was a symbolic space release experience. Your thoughts remain safe on your device.")
                .font(CalmDesignSystem.Typography.body)
                .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .accessibilityLabel("This was a symbolic space release experience. Your thoughts remain safe on your device.")
            
            Button("Continue") {
                HapticFeedback.medium()
                onComplete()
            }
            .buttonStyle(CalmPrimaryButtonStyle(color: CalmDesignSystem.Colors.spacePurple))
            .accessibilityLabel("Continue")
            .accessibilityHint("Double tap to return to the main screen")
        }
        .padding(.horizontal, 32)
        .opacity(animationState.showCompletion ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 1.0), value: animationState.showCompletion)
    }
    
    private func startSpaceAnimation() {
        animationState.startAnimation()
        startTime = CACurrentMediaTime()
        
        createSpaceParticles()
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            updateAnimation()
        }
    }
    
    private func createSpaceParticles() {
        spaceParticles = (0..<25).map { _ in
            SpaceParticle(
                id: UUID(),
                x: CGFloat.random(in: -200...200),
                y: CGFloat.random(in: -100...100),
                size: CGFloat.random(in: 2...6),
                opacity: 1.0,
                velocity: CGPoint(x: CGFloat.random(in: -1...1), y: CGFloat.random(in: -1...1)),
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -3...3),
                scale: CGFloat.random(in: 0.5...1.5),
                color: getRandomSpaceColor()
            )
        }
    }
    
    private func getRandomSpaceColor() -> Color {
        let colors = [
            Color.purple.opacity(0.8),
            Color.blue.opacity(0.7),
            Color.indigo.opacity(0.6),
            Color.cyan.opacity(0.5),
            Color.white.opacity(0.4)
        ]
        return colors.randomElement() ?? Color.purple
    }
    
    private func updateAnimation() {
        let currentTime = CACurrentMediaTime()
        let elapsedTime = currentTime - startTime
        let totalDuration: Double = 10.0
        
        let progress = min(elapsedTime / totalDuration, 1.0)
        animationState.updateProgress(progress)
        
        // Update space particles with cosmic physics
        for i in spaceParticles.indices {
            spaceParticles[i].y += spaceParticles[i].velocity.y
            spaceParticles[i].x += spaceParticles[i].velocity.x
            spaceParticles[i].rotation += spaceParticles[i].rotationSpeed
            spaceParticles[i].scale += 0.003 // Gentle expansion
            
            // Add cosmic drift
            spaceParticles[i].velocity.x += CGFloat.random(in: -0.02...0.02)
            spaceParticles[i].velocity.y += CGFloat.random(in: -0.02...0.02)
            
            // Fade out as they drift
            if abs(spaceParticles[i].x) > 300 || abs(spaceParticles[i].y) > 300 {
                spaceParticles[i].opacity = max(0, 1.0 - (abs(spaceParticles[i].x) + abs(spaceParticles[i].y)) / 600)
            }
        }
        
        if progress >= 1.0 {
            animationTimer?.invalidate()
            animationState.completeAnimation()
        }
    }
}

// MARK: - Space Particle Model
struct SpaceParticle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
    var velocity: CGPoint
    var rotation: Double
    var rotationSpeed: Double
    var scale: CGFloat
    var color: Color
}

// MARK: - Cosmic Particle View
struct CosmicParticleView: View {
    let particle: SpaceParticle
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        particle.color,
                        particle.color.opacity(0.3),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: particle.size / 2
                )
            )
            .frame(width: particle.size * particle.scale, height: particle.size * particle.scale)
            .position(x: particle.x, y: particle.y)
            .rotationEffect(.degrees(particle.rotation))
            .opacity(particle.opacity)
            .shadow(color: particle.color, radius: 2, x: 0, y: 0)
    }
}

#Preview {
    SpaceAnimation(text: "This is a test worry that will be released into space", onComplete: {})
}
