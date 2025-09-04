import SwiftUI

struct AshParticle: Identifiable {
    let id = UUID()
    var x: Double
    var y: Double
    var velocityX: Double
    var velocityY: Double
    var opacity: Double
    var scale: Double
    var rotation: Double
}

struct AshParticles: View {
    @State private var particles: [AshParticle] = []
    @State private var animationTimer: Timer?
    @State private var isActive = false
    
    var body: some View {
        Canvas { context, size in
            for particle in particles {
                let rect = CGRect(
                    x: particle.x - 2,
                    y: particle.y - 2,
                    width: 4,
                    height: 4
                )
                
                context.fill(
                    Path(ellipseIn: rect),
                    with: .color(.gray.opacity(particle.opacity))
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
        for _ in 0..<50 {
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
    
    private func createRandomParticle() -> AshParticle {
        AshParticle(
            x: Double.random(in: 100...300),
            y: Double.random(in: 200...400),
            velocityX: Double.random(in: -2...2),
            velocityY: Double.random(in: -3...(-1)),
            opacity: Double.random(in: 0.3...0.8),
            scale: Double.random(in: 0.5...1.5),
            rotation: Double.random(in: 0...360)
        )
    }
    
    private func updateParticles() {
        for i in particles.indices {
            particles[i].x += particles[i].velocityX
            particles[i].y += particles[i].velocityY
            particles[i].opacity -= 0.01
            particles[i].rotation += 1
            
            // Remove particles that are too transparent or off screen
            if particles[i].opacity <= 0 || particles[i].y < -50 {
                particles[i] = createRandomParticle()
            }
        }
    }
}

#Preview {
    AshParticles()
        .frame(width: 400, height: 600)
        .background(Color.black)
}
