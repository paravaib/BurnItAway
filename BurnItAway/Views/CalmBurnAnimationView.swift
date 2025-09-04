import SwiftUI
import SpriteKit

struct CalmBurnAnimationView: View {
    let worryText: String
    let onComplete: (() -> Void)?
    
    @State private var currentCharIndex = 0
    @State private var burningChars: [BurningCharacter] = []
    @State private var isBurning = false
    @State private var showFire = false
    @State private var showHeatDistortion = false
    @State private var showBreathingIndicator = false
    @State private var fireIntensity: Double = 0.0

    @StateObject private var fireSoundManager = FireSoundManager()
    @EnvironmentObject var appState: AppState
    
    init(worryText: String, onComplete: (() -> Void)? = nil) {
        self.worryText = worryText
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack {
            // Base dark background for burning
            Color.black
                .ignoresSafeArea()
            
            // Breathing indicator
            if showBreathingIndicator {
                BreathingIndicator()
                    .position(x: UIScreen.main.bounds.width / 2, y: 100)
                    .transition(.opacity.combined(with: .scale))
            }
            
            // Heat distortion effect
            if showHeatDistortion {
                HeatDistortionView(isActive: showHeatDistortion, intensity: fireIntensity)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
            
            // Full-screen fire animation
            if showFire {
                AdvancedFireView(isActive: showFire, intensity: fireIntensity)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .ignoresSafeArea()
                    .transition(.opacity.combined(with: .scale))
            }
            
            // Burning text
            VStack(spacing: CalmDesignSystem.Spacing.lg) {
                Spacer()
                
                // Main burning text
                HStack(spacing: 4) {
                    ForEach(Array(worryText.enumerated()), id: \.offset) { index, char in
                        if index < burningChars.count {
                            BurningCharView(
                                char: burningChars[index].char,
                                state: burningChars[index].state,
                                intensity: burningChars[index].intensity
                            )
                        } else {
                            Text(String(char))
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(Color.white)
                                .opacity(0.8)
                        }
                    }
                }
                .padding(.horizontal, CalmDesignSystem.Spacing.xl)

                
                // Calming message
                VStack(spacing: CalmDesignSystem.Spacing.md) {
                    Text("Let it go...")
                        .font(CalmDesignSystem.Typography.quote)
                        .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                        .opacity(isBurning ? 1.0 : 0.0)
                        .animation(CalmDesignSystem.Animations.gentle.delay(1.0), value: isBurning)
                    
                    Text("Feel the warmth of release")
                        .font(CalmDesignSystem.Typography.callout)
                        .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                        .opacity(isBurning ? 1.0 : 0.0)
                        .animation(CalmDesignSystem.Animations.gentle.delay(2.0), value: isBurning)
                    
                    // Burning status text
                    if isBurning {
                        Text("Burning away...")
                            .font(CalmDesignSystem.Typography.caption)
                            .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                            .opacity(isBurning ? 1.0 : 0.0)
                            .animation(CalmDesignSystem.Animations.gentle.delay(3.0), value: isBurning)
                    }
                }
                
                Spacer()
            }
            
            // Completion will be handled by callback
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(.all)
        .statusBarHidden(true)
        .onAppear {
            startBurnSequence()
        }
        .onDisappear {
            // Ensure fire sound stops when view disappears
            fireSoundManager.stopFireSounds()
        }
    }
    
    private func startBurnSequence() {
        // Initialize burning characters
        burningChars = worryText.enumerated().map { index, char in
            BurningCharacter(
                char: char,
                state: .normal,
                intensity: 0.0
            )
        }
        
        // Start the burning sequence
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            startBurning()
        }
    }
    
    private func startBurning() {
        isBurning = true
        showBreathingIndicator = true
        showHeatDistortion = true
        
        // Start fire after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showFire = true
            startFireIntensity()
            // Start fire sound if enabled
            if appState.soundOn {
                fireSoundManager.setSoundscape(appState.soundscape.rawValue)
                fireSoundManager.setMasterVolume(Float(appState.soundVolume))
                fireSoundManager.startFireSounds()
            }
        }
        
        // Start character burning
        burnCharactersSequentially()
    }
    
    private func startFireIntensity() {
        withAnimation(CalmDesignSystem.Animations.slow) {
            fireIntensity = 1.0
        }
    }
    
    private func burnCharactersSequentially() {
        guard currentCharIndex < worryText.count else {
            // All characters burned, complete the sequence
            completeBurning()
            return
        }
        
        let char = worryText[worryText.index(worryText.startIndex, offsetBy: currentCharIndex)]
        
        // Update character state
        burningChars[currentCharIndex].state = .burning
        burningChars[currentCharIndex].intensity = 1.0
        
        // Haptic feedback
        HapticFeedback.light()
        
        // Animate character burning
        withAnimation(CalmDesignSystem.Animations.fireEase) {
            burningChars[currentCharIndex].intensity = 0.0
        }
        
        // Move to next character
        currentCharIndex += 1
        
        // Continue burning with realistic timing
        let delay = Double.random(in: 0.1...0.3)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            burnCharactersSequentially()
        }
    }
    
    private func completeBurning() {
        // Final haptic feedback
        HapticFeedback.success()
        
        // Complete burning sequence
        
        // Start gradual fire fade-out after 8 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            startFireFadeOut()
        }
        
        // Complete animation after 15 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
            onComplete?()
        }
    }
    
    private func startFireFadeOut() {
        // Gradually reduce fire intensity over 7 seconds
        withAnimation(.easeOut(duration: 7.0)) {
            fireIntensity = 0.0
        }
        
        // Fade out visual elements gradually
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 3.0)) {
                showHeatDistortion = false
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.easeOut(duration: 2.0)) {
                showBreathingIndicator = false
            }
        }
        
        // Stop fire sound gradually
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            fireSoundManager.stopFireSounds()
        }
        
        // Finally fade out the fire completely
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
            withAnimation(.easeOut(duration: 1.0)) {
                showFire = false
            }
        }
    }
}

// MARK: - Burning Character Model
struct BurningCharacter {
    let char: Character
    var state: BurningState
    var intensity: Double
}

enum BurningState {
    case normal
    case burning
    case burned
}

// MARK: - Burning Character View
struct BurningCharView: View {
    let char: Character
    let state: BurningState
    let intensity: Double
    
    var body: some View {
        Text(String(char))
            .font(.system(size: 24, weight: .medium)) // Larger, more visible font
            .foregroundColor(charColor)
            .scaleEffect(scale)
            .blur(radius: blur)
            .opacity(opacity)
            .animation(CalmDesignSystem.Animations.fireEase, value: intensity)

    }
    
    private var charColor: Color {
        switch state {
        case .normal:
            return Color.white // Force white for visibility
        case .burning:
            if intensity > 0.8 {
                return CalmDesignSystem.Colors.fireWhite
            } else if intensity > 0.6 {
                return CalmDesignSystem.Colors.fireYellow
            } else if intensity > 0.4 {
                return CalmDesignSystem.Colors.fireOrange
            } else if intensity > 0.2 {
                return CalmDesignSystem.Colors.fireRed
            } else {
                return CalmDesignSystem.Colors.fireDark
            }
        case .burned:
            return CalmDesignSystem.Colors.textSecondary
        }
    }
    
    private var scale: CGFloat {
        switch state {
        case .normal:
            return 1.0
        case .burning:
            return 1.0 + (intensity * 0.3)
        case .burned:
            return 0.8
        }
    }
    
    private var blur: CGFloat {
        switch state {
        case .normal:
            return 0
        case .burning:
            return intensity * 2
        case .burned:
            return 0
        }
    }
    
    private var opacity: Double {
        switch state {
        case .normal:
            return 1.0
        case .burning:
            return 1.0 - (intensity * 0.3)
        case .burned:
            return 0.3
        }
    }
}

// MARK: - Preview
#Preview {
    CalmBurnAnimationView(worryText: "I'm worried about my future")
}
