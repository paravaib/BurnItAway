import SwiftUI

struct LanternParticle: Identifiable {
    let id = UUID()
    var x: Double
    var y: Double
    var velocityX: Double
    var velocityY: Double
    var opacity: Double
    var scale: Double
    var glowIntensity: Double
    var color: Color
}

struct LanternParticles: View {
    @State private var particles: [LanternParticle] = []
    @State private var animationTimer: Timer?
    @State private var isActive = false
    
    var body: some View {
        Canvas { context, size in
            for particle in particles {
                let rect = CGRect(
                    x: particle.x - 8,
                    y: particle.y - 8,
                    width: 16,
                    height: 16
                )
                
                // Draw glowing orb
                context.fill(
                    Path(ellipseIn: rect),
                    with: .color(particle.color.opacity(particle.opacity))
                )
                
                // Draw glow effect
                let glowRect = CGRect(
                    x: particle.x - 12,
                    y: particle.y - 12,
                    width: 24,
                    height: 24
                )
                
                context.fill(
                    Path(ellipseIn: glowRect),
                    with: .color(particle.color.opacity(particle.opacity * 0.3))
                )
            }
        }
        .onAppear {
            isActive = true
            startAnimation()
        }
        .onDisappear {
            isActive = false
            stopAnimation()
        }
    }
    
    private func startAnimation() {
        guard isActive else { return }
        
        // Create initial particles
        for _ in 0..<20 {
            particles.append(createRandomParticle())
        }
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            guard self.isActive else {
                self.stopAnimation()
                return
            }
            updateParticles()
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func createRandomParticle() -> LanternParticle {
        let colors: [Color] = [.yellow, .orange, .green, .blue]
        return LanternParticle(
            x: Double.random(in: 150...250),
            y: Double.random(in: 300...500),
            velocityX: Double.random(in: -1...1),
            velocityY: Double.random(in: -2...(-0.5)),
            opacity: Double.random(in: 0.6...1.0),
            scale: Double.random(in: 0.8...1.2),
            glowIntensity: Double.random(in: 0.5...1.0),
            color: colors.randomElement() ?? .yellow
        )
    }
    
    private func updateParticles() {
        for i in particles.indices {
            particles[i].x += particles[i].velocityX
            particles[i].y += particles[i].velocityY
            particles[i].opacity -= 0.005
            particles[i].glowIntensity = sin(Date().timeIntervalSince1970 * 2) * 0.3 + 0.7
            
            // Remove particles that are too transparent or off screen
            if particles[i].opacity <= 0 || particles[i].y < -50 {
                particles[i] = createRandomParticle()
            }
        }
    }
}

#Preview {
    LanternParticles()
        .frame(width: 400, height: 600)
        .background(Color.black)
}
