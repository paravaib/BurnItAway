//
//  PhotoBurnAnimation.swift
//  BurnItAway
//
//  Created by Vaibhav Parashar on 9/1/25.
//

import SwiftUI
import Photos

class PhotoBurnAnimationController: ObservableObject {
    let image: UIImage?
    let onComplete: () -> Void
    
    @Published var burnProgress: Double = 0.0
    @Published var showFire = false
    @Published var imageOpacity: Double = 1.0
    @Published var fireIntensity: Double = 0.0
    @Published var showCompletion = false
    @Published var showHeatDistortion = false
    @Published var showBreathingIndicator = false
    @Published var isAnimating = false
    @Published var animationPhase: String = "preparing"
    @Published var showBurningParticles = false
    @Published var burningParticleIntensity: Double = 0.0
    
    private var animationTimer: Timer?
    private var displayLink: CADisplayLink?
    private var burnStartTime: CFTimeInterval = 0
    private var fireSoundManager = FireSoundManager()
    private var isCleanedUp = false
    
    init(image: UIImage?, onComplete: @escaping () -> Void) {
        self.image = image
        self.onComplete = onComplete
    }
    
    @objc func updateBurnProgress() {
        let currentTime = CACurrentMediaTime()
        let elapsedTime = currentTime - burnStartTime
        let totalDuration: CFTimeInterval = 15.0 // 15 seconds for burn completion
        
        // Smooth progress from 0 to 1
        let progress = min(elapsedTime / totalDuration, 1.0)
        
        // Use smooth easing function for more natural burning
        let easedProgress = easeInOutCubic(progress)
        
        burnProgress = easedProgress
        fireIntensity = min(easedProgress * 1.5, 1.0)
        
        // Smooth image fade - starts fading earlier as flames grow
        // Start fading at 30% progress, more gradual fade
        let fadeStart = 0.3
        let adjustedProgress = max(0, (progress - fadeStart) / (1.0 - fadeStart))
        imageOpacity = max(1.0 - (adjustedProgress * 0.9), 0.1)
        
        if progress >= 1.0 {
            print("🔥 Burn complete, invalidating displayLink...")
            displayLink?.invalidate()
            displayLink = nil
            completeBurning()
        }
    }
    
    // Smooth easing functions for natural animation
    private func easeInOutCubic(_ t: Double) -> Double {
        return t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2
    }
    
    private func easeInOutQuart(_ t: Double) -> Double {
        return t < 0.5 ? 8 * t * t * t * t : 1 - pow(-2 * t + 2, 4) / 2
    }
    
    // Enhanced fire intensity animation like text burning
    private func startFireIntensityAnimation() {
        // Start with low intensity and build up gradually
        fireIntensity = 0.0
        
        // Build up fire intensity over 3 seconds
        withAnimation(.easeInOut(duration: 3.0)) {
            fireIntensity = 1.0
        }
        
        // Start burning particles after fire intensity builds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            guard !self.isCleanedUp else { return }
            withAnimation(.easeInOut(duration: 0.5)) {
                self.showBurningParticles = true
            }
            self.startBurningParticleAnimation()
        }
    }
    
    // Enhanced burning particle animation
    private func startBurningParticleAnimation() {
        // Animate burning particle intensity
        withAnimation(.easeInOut(duration: 2.0)) {
            burningParticleIntensity = 1.0
        }
    }
    
    func startBurnAnimation() {
        guard !isCleanedUp else { return }
        
        print("🔥 Starting burn animation...")
        isAnimating = true
        animationPhase = "starting"
        
        // Add haptic feedback for animation start
        HapticFeedback.medium()
        
        // Start with breathing indicator (immediate)
        withAnimation(.easeInOut(duration: 1.0)) {
            showBreathingIndicator = true
        }
        print("🔥 Breathing indicator started")
        
        // Start heat distortion after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            guard !self.isCleanedUp else { return }
            print("🔥 Starting heat distortion...")
            withAnimation(.easeInOut(duration: 0.5)) {
                self.showHeatDistortion = true
            }
        }
        
        // Start fire effect and sound together
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            guard !self.isCleanedUp else { return }
            print("🔥 Starting fire effect and sound...")
            withAnimation(.easeInOut(duration: 0.5)) {
                self.showFire = true
            }
            // Start fire sound when fire appears
            self.fireSoundManager.startFireSounds()
            self.animationPhase = "burning"
            
            // Start enhanced fire intensity animation
            self.startFireIntensityAnimation()
        }
        
        // Begin burning process immediately (no delay)
        print("🔥 Starting burn timer...")
        
        // Use CADisplayLink for smooth 60fps animation
        let displayLink = CADisplayLink(target: self, selector: #selector(self.updateBurnProgress))
        displayLink.add(to: .main, forMode: .common)
        
        // Store displayLink for cleanup
        self.displayLink = displayLink
        
        // Start time for smooth progression
        self.burnStartTime = CACurrentMediaTime()
    }
    
    func completeBurning() {
        guard !isCleanedUp else { return }
        
        print("🔥 Completing burn animation...")
        animationPhase = "completing"
        
        // Add haptic feedback for completion
        HapticFeedback.success()
        
        // Start gradual fire fade-out after 8 seconds (same as text burning)
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            guard !self.isCleanedUp else { return }
            self.startFireFadeOut()
        }
        
        // Show completion message after full burning sequence (15s total, same as text burning)
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
            guard !self.isCleanedUp else { return }
            print("🔥 Showing completion message...")
            self.animationPhase = "completed"
            withAnimation(.easeInOut(duration: 1.0)) {
                self.showCompletion = true
            }
        }
    }
    
    private func startFireFadeOut() {
        guard !isCleanedUp else { return }
        
        print("🔥 Starting gradual fire fade-out...")
        animationPhase = "fading"
        
        // Start fading burning particles first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard !self.isCleanedUp else { return }
            print("🔥 Fading out burning particles...")
            withAnimation(.easeOut(duration: 2.0)) {
                self.burningParticleIntensity = 0.0
            }
        }
        
        // Gradually reduce fire intensity over 7 seconds
        withAnimation(.easeOut(duration: 7.0)) {
            fireIntensity = 0.0
        }
        
        // Fade out visual elements gradually
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            guard !self.isCleanedUp else { return }
            print("🔥 Fading out heat distortion...")
            withAnimation(.easeOut(duration: 3.0)) {
                self.showHeatDistortion = false
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            guard !self.isCleanedUp else { return }
            print("🔥 Fading out breathing indicator...")
            withAnimation(.easeOut(duration: 2.0)) {
                self.showBreathingIndicator = false
            }
        }
        
        // Stop fire sound gradually
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            guard !self.isCleanedUp else { return }
            print("🔥 Stopping fire sounds...")
            self.fireSoundManager.stopFireSounds()
        }
        
        // Finally fade out the fire completely
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
            guard !self.isCleanedUp else { return }
            print("🔥 Fading out fire completely...")
            withAnimation(.easeOut(duration: 1.0)) {
                self.showFire = false
            }
        }
        
        // Fade out burning particles completely
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.5) {
            guard !self.isCleanedUp else { return }
            print("🔥 Fading out burning particles completely...")
            withAnimation(.easeOut(duration: 0.5)) {
                self.showBurningParticles = false
            }
        }
        
        // Don't auto-complete - let the user tap Continue button to complete
        
        // Clean up timers after fade-out
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            guard !self.isCleanedUp else { return }
            print("🔥 Cleaning up timers...")
            self.cleanup()
        }
    }
    
    func completeAnimation() {
        print("🔥 Animation completed, calling onComplete...")
        cleanup()
        DispatchQueue.main.async {
            self.onComplete()
        }
    }
    
    private func cleanup() {
        guard !isCleanedUp else { return }
        isCleanedUp = true
        
        print("🔥 Cleaning up animation resources...")
        animationTimer?.invalidate()
        animationTimer = nil
        displayLink?.invalidate()
        displayLink = nil
        fireSoundManager.stopFireSounds()
        isAnimating = false
    }
    
    deinit {
        cleanup()
    }
}

struct PhotoBurnAnimation: View {
    let image: UIImage?
    let onComplete: () -> Void
    
    @StateObject private var controller: PhotoBurnAnimationController
    @EnvironmentObject var appState: AppState
    
    init(image: UIImage?, onComplete: @escaping () -> Void) {
        self.image = image
        self.onComplete = onComplete
        self._controller = StateObject(wrappedValue: PhotoBurnAnimationController(
            image: image,
            onComplete: onComplete
        ))
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if image == nil {
                fallbackView
            } else {
                mainAnimationView
            }
        }
        .ignoresSafeArea(.all)
        .statusBarHidden(true)
        .onAppear(perform: handleAppear)
        .onChange(of: controller.animationPhase, perform: handleAnimationPhaseChange)
    }
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private var fallbackView: some View {
        VStack(spacing: CalmDesignSystem.Spacing.xl) {
            Text("⚠️").font(.system(size: 60))
            Text("No Memory Selected")
                .font(CalmDesignSystem.Typography.largeTitle)
                .foregroundColor(CalmDesignSystem.Colors.textPrimary)
            Text("Please select a memory to burn.")
                .font(CalmDesignSystem.Typography.body)
                .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
            Button("Close", action: onComplete)
                .buttonStyle(CalmPrimaryButtonStyle())
        }
        .padding()
    }
    
    @ViewBuilder
    private var mainAnimationView: some View {
        ZStack {
            // Background effects
            if controller.showBreathingIndicator {
                BreathingIndicator()
                    .position(x: UIScreen.main.bounds.width / 2, y: 100)
                    .transition(.opacity.combined(with: .scale))
            }
            
            if controller.showHeatDistortion {
                HeatDistortionView(isActive: controller.showHeatDistortion, intensity: controller.fireIntensity)
                    .ignoresSafeArea(.all)
                    .transition(.opacity)
            }
            
            if controller.showFire {
                AdvancedFireView(isActive: controller.showFire, intensity: controller.fireIntensity)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .ignoresSafeArea(.all)
                    .transition(.opacity.combined(with: .scale))
            }
            
            // Enhanced burning particles
            if controller.showBurningParticles {
                BurningParticlesView(intensity: controller.burningParticleIntensity)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .ignoresSafeArea(.all)
                    .transition(.opacity)
            }
            
            // Main content
            VStack(spacing: CalmDesignSystem.Spacing.lg) {
                Spacer()
                
                photoDisplayView
                progressIndicatorView
                
                Spacer()
                
                if controller.showCompletion {
                    completionView
                }
            }
            .padding(CalmDesignSystem.Spacing.xl)
        }
    }
    
    @ViewBuilder
    private var photoDisplayView: some View {
        Group {
            if let safeImage = image {
                photoImageView(safeImage)
            } else {
                fallbackImageView()
            }
        }
        .opacity(controller.burnProgress > 0.95 ? 0.0 : 1.0)
        .animation(.easeInOut(duration: 1.0), value: controller.burnProgress)
    }
    
    @ViewBuilder
    private var progressIndicatorView: some View {
        VStack(spacing: CalmDesignSystem.Spacing.md) {
            Text("Burning away...")
                .font(CalmDesignSystem.Typography.caption)
                .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                .opacity(controller.showFire ? 1.0 : 0.0)
                .accessibilityLabel("Burning memory")
                .accessibilityValue("Progress: \(Int(controller.burnProgress * 100)) percent")
            
            Text("Symbolic burning only - your photo is safe")
                .font(CalmDesignSystem.Typography.caption)
                .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                .opacity(controller.showFire ? 0.8 : 0.0)
                .multilineTextAlignment(.center)
                .accessibilityLabel("Symbolic burning only - your photo is safe")
        }
        .animation(.easeInOut(duration: 0.5), value: controller.showFire)
    }
    
    @ViewBuilder
    private var completionView: some View {
        VStack {
            Spacer()
            VStack(spacing: 30) {
                Button("Continue") {
                    HapticFeedback.light()
                    onComplete()
                }
                .buttonStyle(CalmPrimaryButtonStyle(color: .orange))
                .accessibilityLabel("Continue after burning")
                .accessibilityHint("Double tap to proceed after the memory has been burned")
                .accessibilityAddTraits(.isButton)
                
                Text("🔥")
                    .font(.system(size: 100))
                    .scaleEffect(controller.showCompletion ? 1.3 : 0.8)
                    .animation(.easeInOut(duration: 0.5), value: controller.showCompletion)
                    .accessibilityHidden(true)
                
                Text("Released")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .allowsTightening(true)
                    .accessibilityLabel("Memory released")
                
                Text("This was a symbolic burning experience. Your photo remains safe on your device.")
                    .font(.system(size: 16))
                    .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .minimumScaleFactor(0.6)
                    .allowsTightening(true)
                    .padding(.horizontal, 16)
                    .accessibilityLabel("This was a symbolic burning experience. Your photo remains safe on your device.")
            }
            .padding(.horizontal, 32)
            Spacer()
        }
        .opacity(controller.showCompletion ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 1.0), value: controller.showCompletion)
    }
    
    @ViewBuilder
    private func photoImageView(_ safeImage: UIImage) -> some View {
        Image(uiImage: safeImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: 250, maxHeight: 250)
            .clipShape(RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg))
            .opacity(controller.imageOpacity)
            .overlay(burnEffectOverlay)
    }
    
    @ViewBuilder
    private func fallbackImageView() -> some View {
        Image(systemName: "photo")
            .font(.system(size: 80))
            .foregroundColor(.gray)
            .frame(maxWidth: 250, maxHeight: 250)
            .opacity(controller.imageOpacity)
    }
    
    @ViewBuilder
    private var burnEffectOverlay: some View {
        RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
            .fill(burnGradient)
    }
    
    private var burnGradient: LinearGradient {
        LinearGradient(
            colors: burnGradientColors,
            startPoint: .bottom,
            endPoint: .top
        )
    }
    
    private var burnGradientColors: [Color] {
        [
            Color.black.opacity(controller.burnProgress * 0.9),
            Color.orange.opacity(controller.burnProgress * 0.4),
            Color.red.opacity(controller.burnProgress * 0.2),
            Color.clear
        ]
    }
    
    // MARK: - Helper Functions
    
    private func handleAppear() {
        print("🔥 PhotoBurnAnimation appeared with image: \(image != nil ? "present" : "nil")")
        if image != nil {
            controller.startBurnAnimation()
        } else {
            print("🔥 No image provided, showing fallback view")
        }
    }
    
    private func handleAnimationPhaseChange(_ phase: String) {
        switch phase {
        case "starting":
            UIAccessibility.post(notification: .announcement, argument: "Starting to burn memory")
        case "burning":
            UIAccessibility.post(notification: .announcement, argument: "Memory is burning")
        case "completing":
            UIAccessibility.post(notification: .announcement, argument: "Burning is completing")
        case "completed":
            UIAccessibility.post(notification: .announcement, argument: "Memory has been released")
        default:
            break
        }
    }
}

#Preview {
    PhotoBurnAnimation(
        image: UIImage(systemName: "photo"),
        onComplete: {}
    )
}
