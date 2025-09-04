//
//  MeltingTextView.swift
//  BurnItAway
//
//  Created by Vaibhav Parashar on 9/1/25.
//

import SwiftUI

// MARK: - Melting Letter Model
struct MeltingLetter: Identifiable {
    let id = UUID()
    let character: Character
    var position: CGPoint
    var originalPosition: CGPoint
    var scale: CGFloat
    var rotation: Double
    var opacity: Double
    var meltingProgress: Double
    var dripParticles: [DripParticle]
    var isMelting: Bool
    var meltStartTime: Date?
    
    init(character: Character, position: CGPoint) {
        self.character = character
        self.position = position
        self.originalPosition = position
        self.scale = 1.0
        self.rotation = 0.0
        self.opacity = 1.0
        self.meltingProgress = 0.0
        self.dripParticles = []
        self.isMelting = false
        self.meltStartTime = nil
    }
}

// MARK: - Drip Particle Model
struct DripParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGVector
    var size: CGFloat
    var opacity: Double
    var life: Double
    var maxLife: Double
    var color: Color
    
    init(position: CGPoint, velocity: CGVector, size: CGFloat, color: Color) {
        self.position = position
        self.velocity = velocity
        self.size = size
        self.opacity = 1.0
        self.life = 2.0
        self.maxLife = 2.0
        self.color = color
    }
    
    mutating func update(deltaTime: Double) {
        position.x += velocity.dx * deltaTime
        position.y += velocity.dy * deltaTime
        
        // Gravity effect
        velocity.dy += 200 * deltaTime
        
        // Life decay
        life -= deltaTime
        let lifeRatio = life / maxLife
        opacity = lifeRatio
        size = size * (0.8 + 0.2 * lifeRatio)
    }
}

// MARK: - Melting Text View
struct MeltingTextView: View {
    let text: String
    let ritualType: String
    let onComplete: () -> Void
    
    @State private var letters: [MeltingLetter] = []
    @State private var isAnimating = false
    @State private var currentLetterIndex = 0
    @State private var displayLink: CADisplayLink?
    @State private var lastUpdateTime: CFTimeInterval = 0
    @State private var animationStartTime: Date = Date()
    
    var body: some View {
        ZStack {
            // Melting letters
            ForEach(letters) { letter in
                MeltingLetterView(
                    letter: letter,
                    ritualType: ritualType
                )
            }
        }
        .onAppear {
            setupLetters()
            startMeltingAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
    }
    
    private func setupLetters() {
        let font = UIFont.systemFont(ofSize: 32, weight: .medium)
        let attributes = [NSAttributedString.Key.font: font]
        
        var currentX: CGFloat = 0
        let lineHeight: CGFloat = 40
        
        letters = text.enumerated().map { index, char in
            let charString = String(char)
            let size = charString.size(withAttributes: attributes)
            
            let letter = MeltingLetter(
                character: char,
                position: CGPoint(x: currentX, y: 0)
            )
            
            currentX += size.width + 2 // Add small spacing
            return letter
        }
    }
    
    private func startMeltingAnimation() {
        isAnimating = true
        animationStartTime = Date()
        lastUpdateTime = CACurrentMediaTime()
        
        // Start display link for smooth animation
        displayLink = CADisplayLink(target: DisplayLinkTarget { [self] in
            updateAnimation()
        }, selector: #selector(DisplayLinkTarget.update))
        displayLink?.add(to: .main, forMode: .common)
        
        // Start melting letters sequentially
        startSequentialMelting()
    }
    
    private func startSequentialMelting() {
        guard currentLetterIndex < letters.count else {
            // All letters started melting, wait for completion
            DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
                onComplete()
            }
            return
        }
        
        // Start melting current letter
        letters[currentLetterIndex].isMelting = true
        letters[currentLetterIndex].meltStartTime = Date()
        
        // Create initial drip particles
        createDripParticles(for: currentLetterIndex)
        
        // Move to next letter with random delay
        currentLetterIndex += 1
        let delay = Double.random(in: 0.1...0.4)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            startSequentialMelting()
        }
    }
    
    private func createDripParticles(for letterIndex: Int) {
        guard letterIndex < letters.count else { return }
        
        let letter = letters[letterIndex]
        let particleCount = Int.random(in: 3...8)
        
        for _ in 0..<particleCount {
            let particle = DripParticle(
                position: CGPoint(
                    x: letter.position.x + CGFloat.random(in: -10...10),
                    y: letter.position.y + 20
                ),
                velocity: CGVector(
                    dx: CGFloat.random(in: -30...30),
                    dy: CGFloat.random(in: 20...60)
                ),
                size: CGFloat.random(in: 2...6),
                color: getRitualColor()
            )
            letters[letterIndex].dripParticles.append(particle)
        }
    }
    
    private func updateAnimation() {
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        for i in 0..<letters.count {
            if letters[i].isMelting {
                updateMeltingLetter(at: i, deltaTime: deltaTime)
            }
        }
    }
    
    private func updateMeltingLetter(at index: Int, deltaTime: Double) {
        guard let meltStartTime = letters[index].meltStartTime else { return }
        
        let elapsedTime = Date().timeIntervalSince(meltStartTime)
        let meltDuration: Double = 3.0
        
        // Update melting progress
        letters[index].meltingProgress = min(elapsedTime / meltDuration, 1.0)
        
        // Update letter properties based on melting progress
        let progress = letters[index].meltingProgress
        
        // Scale down as it melts
        letters[index].scale = 1.0 - (progress * 0.3)
        
        // Rotate as it melts
        letters[index].rotation = progress * 15 * (index % 2 == 0 ? 1 : -1)
        
        // Fade out
        letters[index].opacity = 1.0 - (progress * 0.8)
        
        // Move down slightly
        letters[index].position.y = letters[index].originalPosition.y + (progress * 10)
        
        // Update drip particles
        for i in stride(from: letters[index].dripParticles.count - 1, through: 0, by: -1) {
            letters[index].dripParticles[i].update(deltaTime: deltaTime)
            
            // Remove dead particles
            if letters[index].dripParticles[i].life <= 0 {
                letters[index].dripParticles.remove(at: i)
            }
        }
        
        // Add new drip particles occasionally
        if progress > 0.3 && progress < 0.8 && letters[index].dripParticles.count < 5 {
            if Double.random(in: 0...1) < 0.1 {
                let newParticle = DripParticle(
                    position: CGPoint(
                        x: letters[index].position.x + CGFloat.random(in: -8...8),
                        y: letters[index].position.y + 15
                    ),
                    velocity: CGVector(
                        dx: CGFloat.random(in: -20...20),
                        dy: CGFloat.random(in: 30...80)
                    ),
                    size: CGFloat.random(in: 1...4),
                    color: getRitualColor()
                )
                letters[index].dripParticles.append(newParticle)
            }
        }
    }
    
    private func getRitualColor() -> Color {
        switch ritualType {
        case "fire":
            return Color.orange
        case "smoke":
            return Color.gray
        case "space":
            return Color.purple
        case "wash":
            return Color.blue
        default:
            return Color.orange
        }
    }
    
    private func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
    }
}

// MARK: - Melting Letter View
struct MeltingLetterView: View {
    let letter: MeltingLetter
    let ritualType: String
    
    var body: some View {
        ZStack {
            // Drip particles
            ForEach(letter.dripParticles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
                    .blur(radius: particle.size * 0.2)
            }
            
            // Main letter
            Text(String(letter.character))
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(.white)
                .position(letter.position)
                .scaleEffect(letter.scale)
                .rotationEffect(.degrees(letter.rotation))
                .opacity(letter.opacity)
                .overlay(
                    // Melting effect overlay
                    Text(String(letter.character))
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(getRitualColor())
                        .position(letter.position)
                        .scaleEffect(letter.scale)
                        .rotationEffect(.degrees(letter.rotation))
                        .opacity(letter.meltingProgress * 0.3)
                        .blur(radius: letter.meltingProgress * 2)
                )
        }
    }
    
    private func getRitualColor() -> Color {
        switch ritualType {
        case "fire":
            return Color.orange
        case "smoke":
            return Color.gray
        case "space":
            return Color.purple
        case "wash":
            return Color.blue
        default:
            return Color.orange
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
    MeltingTextView(
        text: "Burn Away",
        ritualType: "fire",
        onComplete: {}
    )
    .background(Color.black)
}
