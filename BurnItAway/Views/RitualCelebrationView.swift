import SwiftUI

struct RitualCelebrationView: View {
    let feedback: RitualCompletionFeedback
    let progress: WellnessProgress
    let onContinue: () -> Void
    
    @State private var showCelebration = false
    @State private var showProgress = false
    @State private var showAchievements = false
    @State private var confettiParticles: [ConfettiParticle] = []
    @State private var celebrationScale: CGFloat = 0.5
    @State private var celebrationRotation: Double = 0
    
    var body: some View {
        ZStack {
            // Background with gradient
            LinearGradient(
                colors: [
                    Color.black.opacity(0.8),
                    feedback.color.opacity(0.3),
                    Color.black.opacity(0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Confetti particles
            ForEach(confettiParticles, id: \.id) { particle in
                ConfettiParticleView(particle: particle)
            }
            
            VStack(spacing: 30) {
                Spacer()
                
                // Main celebration message
                VStack(spacing: 20) {
                    Text(feedback.emoji)
                        .font(.system(size: 80))
                        .scaleEffect(celebrationScale)
                        .rotationEffect(.degrees(celebrationRotation))
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: celebrationScale)
                        .animation(.easeInOut(duration: 2.0), value: celebrationRotation)
                    
                    Text(feedback.message)
                        .font(CalmDesignSystem.Typography.title)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(showCelebration ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 1.0).delay(0.5), value: showCelebration)
                }
                
                // Progress stats
                if showProgress {
                    VStack(spacing: 15) {
                        HStack(spacing: 30) {
                            CelebrationStatCard(
                                title: "Streak",
                                value: "\(progress.currentStreak)",
                                subtitle: "days",
                                color: .orange,
                                icon: "flame.fill"
                            )
                            
                            CelebrationStatCard(
                                title: "Total",
                                value: "\(progress.totalWorriesReleased)",
                                subtitle: "released",
                                color: .blue,
                                icon: "heart.fill"
                            )
                        }
                        
                        if progress.longestStreak > progress.currentStreak {
                            Text("Best streak: \(progress.longestStreak) days")
                                .font(CalmDesignSystem.Typography.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .opacity(showProgress ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 1.0).delay(1.0), value: showProgress)
                }
                
                // New achievements
                if !progress.achievements.isEmpty && showAchievements {
                    VStack(spacing: 10) {
                        Text("New Achievement!")
                            .font(CalmDesignSystem.Typography.headline)
                            .foregroundColor(.yellow)
                        
                        ForEach(progress.achievements.suffix(1)) { achievement in
                            CelebrationAchievementCard(achievement: achievement)
                        }
                    }
                    .opacity(showAchievements ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 1.0).delay(1.5), value: showAchievements)
                }
                
                Spacer()
                
                // Continue button
                Button("Continue") {
                    feedback.hapticPattern.play()
                    onContinue()
                }
                .buttonStyle(CalmPrimaryButtonStyle(color: feedback.color))
                .opacity(showCelebration ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 1.0).delay(2.0), value: showCelebration)
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            startCelebration()
        }
    }
    
    private func startCelebration() {
        // Play haptic feedback
        feedback.hapticPattern.play()
        
        // Start celebration animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            celebrationScale = 1.2
        }
        
        withAnimation(.easeInOut(duration: 2.0)) {
            celebrationRotation = 360
        }
        
        // Show celebration message
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showCelebration = true
        }
        
        // Show progress stats
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showProgress = true
        }
        
        // Show achievements
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showAchievements = true
        }
        
        // Create confetti
        createConfetti()
        
        // Scale back down
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                celebrationScale = 1.0
            }
        }
    }
    
    private func createConfetti() {
        confettiParticles = (0..<30).map { _ in
            ConfettiParticle(
                id: UUID(),
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: -50,
                size: CGFloat.random(in: 4...8),
                color: [.red, .blue, .green, .yellow, .purple, .orange].randomElement() ?? .blue,
                velocity: CGPoint(x: CGFloat.random(in: -2...2), y: CGFloat.random(in: 2...5)),
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -5...5)
            )
        }
    }
}

// MARK: - Celebration Stat Card (simplified version for celebrations)
struct CelebrationStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(title)
                .font(CalmDesignSystem.Typography.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Text(subtitle)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Celebration Achievement Card (simplified version for celebrations)
struct CelebrationAchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 12) {
            Text(achievement.emoji)
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.title)
                    .font(CalmDesignSystem.Typography.headline)
                    .foregroundColor(.white)
                
                Text(achievement.description)
                    .font(CalmDesignSystem.Typography.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(achievement.color.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(achievement.color.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

// MARK: - Confetti Particle
struct ConfettiParticle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var color: Color
    var velocity: CGPoint
    var rotation: Double
    var rotationSpeed: Double
}

struct ConfettiParticleView: View {
    let particle: ConfettiParticle
    
    @State private var currentParticle = ConfettiParticle(
        id: UUID(),
        x: 0,
        y: 0,
        size: 0,
        color: .blue,
        velocity: CGPoint(x: 0, y: 0),
        rotation: 0,
        rotationSpeed: 0
    )
    
    var body: some View {
        Rectangle()
            .fill(currentParticle.color)
            .frame(width: currentParticle.size, height: currentParticle.size)
            .position(x: currentParticle.x, y: currentParticle.y)
            .rotationEffect(.degrees(currentParticle.rotation))
            .onAppear {
                currentParticle = particle
                startAnimation()
            }
    }
    
    private func startAnimation() {
        withAnimation(.easeOut(duration: 3.0)) {
            currentParticle.y += currentParticle.velocity.y * 200
            currentParticle.x += currentParticle.velocity.x * 100
            currentParticle.rotation += currentParticle.rotationSpeed * 10
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if currentParticle.y > UIScreen.main.bounds.height + 100 {
                timer.invalidate()
                return
            }
            
            withAnimation(.linear(duration: 0.1)) {
                currentParticle.rotation += currentParticle.rotationSpeed
            }
        }
    }
}

#Preview {
    RitualCelebrationView(
        feedback: RitualCompletionFeedback(
            message: "Amazing! You're on a 7-day streak! 🔥",
            emoji: "🔥",
            color: .orange,
            hapticPattern: .celebration
        ),
        progress: WellnessProgress(),
        onContinue: {}
    )
}
