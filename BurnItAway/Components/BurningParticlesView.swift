//
//  BurningParticlesView.swift
//  BurnItAway
//
//  Created by Vaibhav Parashar on 9/1/25.
//

import SwiftUI

// MARK: - Burning Particle Model
struct BurningParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGVector
    var life: Double
    var maxLife: Double
    var size: Double
    var heat: Double
    var color: Color
    var opacity: Double
    
    init(position: CGPoint, velocity: CGVector, life: Double, size: Double, heat: Double) {
        self.position = position
        self.velocity = velocity
        self.life = life
        self.maxLife = life
        self.size = size
        self.heat = heat
        self.color = Color.orange
        self.opacity = 1.0
    }
    
    mutating func update(deltaTime: Double) {
        // Physics simulation
        position.x += velocity.dx * deltaTime
        position.y += velocity.dy * deltaTime
        
        // Turbulence effect
        let turbulenceForce = sin(position.x * 0.01 + Date().timeIntervalSince1970 * 2) * 0.5
        velocity.dx += turbulenceForce * deltaTime * 30
        
        // Gravity and upward force
        velocity.dy -= 150 * deltaTime // Gravity
        velocity.dy += 100 * deltaTime * heat // Upward force from heat
        
        // Life decay
        life -= deltaTime
        
        // Size and color changes based on life
        let lifeRatio = life / maxLife
        size = size * (0.7 + 0.3 * lifeRatio)
        opacity = lifeRatio
        
        // Color gradient: white -> yellow -> orange -> red -> dark red
        if lifeRatio > 0.8 {
            color = Color.white
        } else if lifeRatio > 0.6 {
            color = Color.yellow
        } else if lifeRatio > 0.4 {
            color = Color.orange
        } else if lifeRatio > 0.2 {
            color = Color.red
        } else {
            color = Color(red: 0.3, green: 0.1, blue: 0.1)
        }
    }
}

// MARK: - Burning Particles View
struct BurningParticlesView: View {
    let intensity: Double
    
    @State private var particles: [BurningParticle] = []
    @State private var displayLink: CADisplayLink?
    @State private var lastUpdateTime: CFTimeInterval = 0
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .opacity(particle.opacity * intensity)
                    .position(particle.position)
                    .blur(radius: particle.size * 0.1)
            }
        }
        .onAppear {
            startParticleSystem()
        }
        .onDisappear {
            stopParticleSystem()
        }
        .onChange(of: intensity) { newIntensity in
            updateParticleIntensity(newIntensity)
        }
    }
    
    private func startParticleSystem() {
        lastUpdateTime = CACurrentMediaTime()
        
        // Create display link for smooth animation
        displayLink = CADisplayLink(target: DisplayLinkTarget { [weak self] in
            self?.updateParticles()
        }, selector: #selector(DisplayLinkTarget.update))
        displayLink?.add(to: .main, forMode: .common)
        
        // Start generating particles
        generateParticles()
    }
    
    private func stopParticleSystem() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    private func generateParticles() {
        guard intensity > 0 else { return }
        
        // Generate particles based on intensity
        let particleCount = Int(20 * intensity) // 0-20 particles based on intensity
        
        for _ in 0..<particleCount {
            let particle = createRandomParticle()
            particles.append(particle)
        }
        
        // Continue generating particles
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            generateParticles()
        }
    }
    
    private func createRandomParticle() -> BurningParticle {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Random position at bottom of screen
        let x = Double.random(in: 0...screenWidth)
        let y = screenHeight + 50 // Start below screen
        
        // Random velocity (upward with some horizontal variation)
        let velocityX = Double.random(in: -50...50)
        let velocityY = Double.random(in: -200...-100) // Upward
        
        // Random properties
        let life = Double.random(in: 2.0...4.0)
        let size = Double.random(in: 8...20)
        let heat = Double.random(in: 0.5...1.0)
        
        return BurningParticle(
            position: CGPoint(x: x, y: y),
            velocity: CGVector(dx: velocityX, dy: velocityY),
            life: life,
            size: size,
            heat: heat
        )
    }
    
    private func updateParticles() {
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Update existing particles
        for i in stride(from: particles.count - 1, through: 0, by: -1) {
            particles[i].update(deltaTime: deltaTime)
            
            // Remove dead particles
            if particles[i].life <= 0 {
                particles.remove(at: i)
            }
        }
    }
    
    private func updateParticleIntensity(_ newIntensity: Double) {
        // Adjust particle generation based on intensity
        if newIntensity == 0 {
            // Clear all particles when intensity is 0
            particles.removeAll()
        }
    }
}

// MARK: - Display Link Target
class DisplayLinkTarget: NSObject {
    private let callback: () -> Void
    
    init(callback: @escaping () -> Void) {
        self.callback = callback
    }
    
    @objc func update() {
        callback()
    }
}

#Preview {
    BurningParticlesView(intensity: 1.0)
        .background(Color.black)
}
