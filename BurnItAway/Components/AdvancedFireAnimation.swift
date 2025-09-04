import SwiftUI
import SpriteKit

// MARK: - Advanced Fire Particle System
struct AdvancedFireParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGVector
    var life: Double
    var maxLife: Double
    var size: Double
    var heat: Double
    var turbulence: Double
    var color: Color
    
    init(position: CGPoint, velocity: CGVector, life: Double, size: Double, heat: Double) {
        self.position = position
        self.velocity = velocity
        self.life = life
        self.maxLife = life
        self.size = size
        self.heat = heat
        self.turbulence = Double.random(in: 0.5...1.5)
        self.color = Color.orange
    }
    
    mutating func update(deltaTime: Double) {
        // Physics simulation
        position.x += velocity.dx * deltaTime
        position.y += velocity.dy * deltaTime
        
        // Turbulence effect
        let turbulenceForce = sin(position.x * 0.01 + Date().timeIntervalSince1970 * 2) * turbulence
        velocity.dx += turbulenceForce * deltaTime * 50
        
        // Gravity and upward force
        velocity.dy -= 200 * deltaTime // Gravity
        velocity.dy += 150 * deltaTime * heat // Upward force from heat
        
        // Life decay
        life -= deltaTime
        
        // Size and color changes based on life
        let lifeRatio = life / maxLife
        size = size * (0.8 + 0.2 * lifeRatio)
        
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

// MARK: - Advanced Fire Scene
class AdvancedFireScene: SKScene {
    private var fireParticles: [SKEmitterNode] = []
    private var emberParticles: [SKEmitterNode] = []
    private var smokeParticles: [SKEmitterNode] = []
    
    override func didMove(to view: SKView) {
        backgroundColor = .clear
        setupFireParticles()
        setupEmberParticles()
        setupSmokeParticles()
    }
    
    private func setupFireParticles() {
        // Create multiple fire emitters across the screen for full coverage
        let emitterPositions = [
            CGPoint(x: size.width * 0.2, y: 0),
            CGPoint(x: size.width * 0.5, y: 0),
            CGPoint(x: size.width * 0.8, y: 0)
        ]
        
        for position in emitterPositions {
            let fireEmitter = SKEmitterNode()
            fireEmitter.particleTexture = createFireTexture()
            fireEmitter.particleBirthRate = 200 // Per emitter
            fireEmitter.numParticlesToEmit = 0 // Continuous
            fireEmitter.particleLifetime = 3.0 // Longer lifetime
            fireEmitter.particleLifetimeRange = 2.0
            
            // Fire colors
            fireEmitter.particleColor = .orange
            fireEmitter.particleColorBlendFactor = 1.0
            fireEmitter.particleColorSequence = createFireColorSequence()
            
            // Fire physics
            fireEmitter.particleSpeed = 50
            fireEmitter.particleSpeedRange = 30
            fireEmitter.emissionAngle = CGFloat.pi / 2 // Upward
            fireEmitter.emissionAngleRange = CGFloat.pi / 4
            
            // Fire size
            fireEmitter.particleSize = CGSize(width: 20, height: 20)
            fireEmitter.particleScale = 1.0
            fireEmitter.particleScaleRange = 0.5
            fireEmitter.particleScaleSpeed = -0.3
            
            // Fire position
            fireEmitter.position = position
            fireEmitter.particlePositionRange = CGVector(dx: size.width * 0.3, dy: 0)
            
            addChild(fireEmitter)
            fireParticles.append(fireEmitter)
        }
    }
    
    private func setupEmberParticles() {
        let emberEmitter = SKEmitterNode()
        emberEmitter.particleTexture = createEmberTexture()
        emberEmitter.particleBirthRate = 150 // Increased for full-screen effect
        emberEmitter.numParticlesToEmit = 0
        emberEmitter.particleLifetime = 4.0 // Longer lifetime
        emberEmitter.particleLifetimeRange = 2.0
        
        // Ember colors
        emberEmitter.particleColor = .red
        emberEmitter.particleColorBlendFactor = 1.0
        
        // Ember physics
        emberEmitter.particleSpeed = 80
        emberEmitter.particleSpeedRange = 40
        emberEmitter.emissionAngle = CGFloat.pi / 2
        emberEmitter.emissionAngleRange = CGFloat.pi / 3
        
        // Ember size
        emberEmitter.particleSize = CGSize(width: 8, height: 8)
        emberEmitter.particleScale = 1.0
        emberEmitter.particleScaleRange = 0.3
        emberEmitter.particleScaleSpeed = -0.2
        
        // Ember position - spread across full width
        emberEmitter.position = CGPoint(x: size.width / 2, y: 0)
        emberEmitter.particlePositionRange = CGVector(dx: size.width * 0.9, dy: 0)
        
        addChild(emberEmitter)
        emberParticles.append(emberEmitter)
    }
    
    private func setupSmokeParticles() {
        let smokeEmitter = SKEmitterNode()
        smokeEmitter.particleTexture = createSmokeTexture()
        smokeEmitter.particleBirthRate = 80 // Increased for full-screen effect
        smokeEmitter.numParticlesToEmit = 0
        smokeEmitter.particleLifetime = 6.0 // Longer lifetime
        smokeEmitter.particleLifetimeRange = 3.0
        
        // Smoke colors
        smokeEmitter.particleColor = .gray
        smokeEmitter.particleColorBlendFactor = 0.7
        smokeEmitter.particleColorSequence = createSmokeColorSequence()
        
        // Smoke physics
        smokeEmitter.particleSpeed = 40
        smokeEmitter.particleSpeedRange = 20
        smokeEmitter.emissionAngle = CGFloat.pi / 2
        smokeEmitter.emissionAngleRange = CGFloat.pi / 6
        
        // Smoke size
        smokeEmitter.particleSize = CGSize(width: 15, height: 15)
        smokeEmitter.particleScale = 0.5
        smokeEmitter.particleScaleRange = 0.3
        smokeEmitter.particleScaleSpeed = 0.5
        
        // Smoke position - spread across full width
        smokeEmitter.position = CGPoint(x: size.width / 2, y: 0)
        smokeEmitter.particlePositionRange = CGVector(dx: size.width * 0.7, dy: 0)
        
        addChild(smokeEmitter)
        smokeParticles.append(smokeEmitter)
    }
    
    private func createFireTexture() -> SKTexture {
        let size = CGSize(width: 20, height: 20)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                    colors: [UIColor.orange.cgColor, UIColor.red.cgColor] as CFArray,
                                    locations: [0.0, 1.0])!
            context.cgContext.drawRadialGradient(gradient,
                                               startCenter: CGPoint(x: size.width/2, y: size.height/2),
                                               startRadius: 0,
                                               endCenter: CGPoint(x: size.width/2, y: size.height/2),
                                               endRadius: size.width/2,
                                               options: [])
        }
        return SKTexture(image: image)
    }
    
    private func createEmberTexture() -> SKTexture {
        let size = CGSize(width: 8, height: 8)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            context.cgContext.setFillColor(UIColor.red.cgColor)
            context.cgContext.fillEllipse(in: rect)
        }
        return SKTexture(image: image)
    }
    
    private func createSmokeTexture() -> SKTexture {
        let size = CGSize(width: 15, height: 15)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            context.cgContext.setFillColor(UIColor.gray.withAlphaComponent(0.3).cgColor)
            context.cgContext.fillEllipse(in: rect)
        }
        return SKTexture(image: image)
    }
    
    private func createFireColorSequence() -> SKKeyframeSequence {
        let sequence = SKKeyframeSequence(keyframeValues: [
            UIColor.white,
            UIColor.yellow,
            UIColor.orange,
            UIColor.red,
            UIColor.darkGray
        ], times: [0.0, 0.2, 0.4, 0.7, 1.0])
        return sequence
    }
    
    private func createSmokeColorSequence() -> SKKeyframeSequence {
        let sequence = SKKeyframeSequence(keyframeValues: [
            UIColor.clear,
            UIColor.gray.withAlphaComponent(0.3),
            UIColor.gray.withAlphaComponent(0.1),
            UIColor.clear
        ], times: [0.0, 0.3, 0.7, 1.0])
        return sequence
    }
    
    func startFire() {
        fireParticles.forEach { $0.particleBirthRate = 200 } // 200 per emitter (3 emitters = 600 total)
        emberParticles.forEach { $0.particleBirthRate = 150 }
        smokeParticles.forEach { $0.particleBirthRate = 80 }
    }
    
    func setFireIntensity(_ intensity: Double) {
        // Gradually reduce particle birth rates based on intensity
        let fireRate = max(0, Int(200 * intensity))
        let emberRate = max(0, Int(150 * intensity))
        let smokeRate = max(0, Int(80 * intensity))
        
        fireParticles.forEach { $0.particleBirthRate = CGFloat(fireRate) }
        emberParticles.forEach { $0.particleBirthRate = CGFloat(emberRate) }
        smokeParticles.forEach { $0.particleBirthRate = CGFloat(smokeRate) }
        
        // Also reduce particle size and speed for low flames
        let sizeMultiplier = 0.5 + (0.5 * intensity) // 0.5 to 1.0
        let speedMultiplier = 0.3 + (0.7 * intensity) // 0.3 to 1.0
        
        fireParticles.forEach { emitter in
            emitter.particleSize = CGSize(width: 20 * sizeMultiplier, height: 20 * sizeMultiplier)
            emitter.particleSpeed = 50 * speedMultiplier
        }
        
        emberParticles.forEach { emitter in
            emitter.particleSize = CGSize(width: 8 * sizeMultiplier, height: 8 * sizeMultiplier)
            emitter.particleSpeed = 80 * speedMultiplier
        }
    }
    
    func stopFire() {
        fireParticles.forEach { $0.particleBirthRate = 0 }
        emberParticles.forEach { $0.particleBirthRate = 0 }
        smokeParticles.forEach { $0.particleBirthRate = 0 }
    }
}

// MARK: - Advanced Fire View
struct AdvancedFireView: UIViewRepresentable {
    let isActive: Bool
    let intensity: Double
    
    init(isActive: Bool, intensity: Double = 1.0) {
        self.isActive = isActive
        self.intensity = intensity
    }
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.backgroundColor = .clear
        view.allowsTransparency = true
        
        let scene = AdvancedFireScene()
        scene.size = CGSize(width: 300, height: 400)
        scene.scaleMode = .aspectFit
        
        view.presentScene(scene)
        context.coordinator.scene = scene
        
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        if isActive {
            context.coordinator.scene?.setFireIntensity(intensity)
        } else {
            context.coordinator.scene?.stopFire()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var scene: AdvancedFireScene?
    }
}

// MARK: - Heat Distortion Effect
struct HeatDistortionView: View {
    let isActive: Bool
    let intensity: Double
    
    init(isActive: Bool, intensity: Double = 1.0) {
        self.isActive = isActive
        self.intensity = intensity
    }
    
    var body: some View {
        if isActive {
            Rectangle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.clear,
                            Color.orange.opacity(0.15 * intensity),
                            Color.red.opacity(0.1 * intensity),
                            Color.yellow.opacity(0.05 * intensity)
                        ],
                        center: .center,
                        startRadius: 100,
                        endRadius: UIScreen.main.bounds.width
                    )
                )
                .blur(radius: 30 * intensity)
                .scaleEffect(1.5 * (0.5 + 0.5 * intensity))
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isActive)
        }
    }
}

// MARK: - Breathing Animation
struct BreathingAnimation: View {
    @State private var isBreathing = false
    @State private var breathScale: CGFloat = 1.0
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.orange.opacity(0.3),
                        Color.red.opacity(0.1),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 20,
                    endRadius: 100
                )
            )
            .scaleEffect(breathScale)
            .onAppear {
                startBreathing()
            }
    }
    
    private func startBreathing() {
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            breathScale = 1.3
        }
    }
}
