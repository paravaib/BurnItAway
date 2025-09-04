//
//  RealAnimationManager.swift
//  BurnItAway
//
//  Created by Vaibhav Parashar on 9/4/25.
//

import SwiftUI
import AVKit
import WebKit

// MARK: - Real Animation Manager
class RealAnimationManager: ObservableObject {
    static let shared = RealAnimationManager()
    
    private init() {}
    
    // MARK: - Animation Types
    enum AnimationType {
        case gif
        case lottie
        case video
        case spriteKit
    }
    
    // MARK: - Animation Sources
    struct AnimationSource {
        let type: AnimationType
        let fileName: String
        let duration: Double?
        let loop: Bool
        
        init(type: AnimationType, fileName: String, duration: Double? = nil, loop: Bool = true) {
            self.type = type
            self.fileName = fileName
            self.duration = duration
            self.loop = loop
        }
    }
    
    // MARK: - Predefined Animation Sources
    static let fireGif = AnimationSource(type: .gif, fileName: "fire_animation", duration: 3.0)
    static let waterGif = AnimationSource(type: .gif, fileName: "water_wave", duration: 4.0)
    static let smokeGif = AnimationSource(type: .gif, fileName: "smoke_animation", duration: 5.0)
    static let earthGif = AnimationSource(type: .gif, fileName: "earth_bury", duration: 6.0)
    
    static let fireLottie = AnimationSource(type: .lottie, fileName: "fire_lottie", duration: 8.0)
    static let waterLottie = AnimationSource(type: .lottie, fileName: "water_lottie", duration: 10.0)
    
    // Video backgrounds (you've added these!) - Extended to 15 seconds
    static let fireVideo = AnimationSource(type: .video, fileName: "fire_background", duration: 15.0, loop: true)
    static let smokeVideo = AnimationSource(type: .video, fileName: "smoke_background", duration: 15.0, loop: true)
    static let soilVideo = AnimationSource(type: .video, fileName: "soil_background", duration: 15.0, loop: true)
    static let waterVideo = AnimationSource(type: .video, fileName: "water_background", duration: 15.0, loop: true)
    
    static let backgroundVideo = AnimationSource(type: .video, fileName: "calm_background", duration: 30.0, loop: true)
}

// MARK: - GIF Animation View
struct GIFAnimationView: UIViewRepresentable {
    let gifName: String
    let duration: Double
    let loop: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.isScrollEnabled = false
        
        if let gifPath = Bundle.main.path(forResource: gifName, ofType: "gif"),
           let gifData = NSData(contentsOfFile: gifPath) {
            let base64 = gifData.base64EncodedString()
            let html = """
            <html>
            <head>
                <style>
                    body { margin: 0; padding: 0; background: transparent; }
                    img { width: 100%; height: 100%; object-fit: cover; }
                </style>
            </head>
            <body>
                <img src="data:image/gif;base64,\(base64)" />
            </body>
            </html>
            """
            webView.loadHTMLString(html, baseURL: nil)
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: - Video Background View
struct VideoBackgroundView: UIViewRepresentable {
    let videoName: String
    let loop: Bool
    
    func makeUIView(context: Context) -> VideoPlayerView {
        let videoView = VideoPlayerView()
        videoView.setupVideo(name: videoName, loop: loop)
        return videoView
    }
    
    func updateUIView(_ uiView: VideoPlayerView, context: Context) {
        // Update frame when view changes
        uiView.updateFrame()
    }
}

// MARK: - Custom Video Player View
class VideoPlayerView: UIView {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var loopObserver: NSObjectProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = UIColor.black
    }
    
    func setupVideo(name: String, loop: Bool) {
        print("🎥 Setting up video: \(name)")
        
        guard let videoPath = Bundle.main.path(forResource: name, ofType: "mp4") else {
            print("❌ Video file not found: \(name).mp4")
            showFallbackMessage()
            return
        }
        
        print("✅ Video file found: \(videoPath)")
        
        // Check file size
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: videoPath)
            if let fileSize = attributes[.size] as? NSNumber {
                let sizeInMB = fileSize.doubleValue / (1024 * 1024)
                print("📊 Video file size: \(String(format: "%.1f", sizeInMB)) MB")
            }
        } catch {
            print("⚠️ Could not get file size: \(error)")
        }
        
        // Create player
        let url = URL(fileURLWithPath: videoPath)
        player = AVPlayer(url: url)
        
        guard let player = player else {
            print("❌ Failed to create player")
            showFallbackMessage()
            return
        }
        
        // Create player layer
        playerLayer = AVPlayerLayer(player: player)
        guard let playerLayer = playerLayer else {
            print("❌ Failed to create player layer")
            showFallbackMessage()
            return
        }
        
        // Configure player layer
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = bounds
        layer.addSublayer(playerLayer)
        
        print("📐 Player layer frame: \(bounds)")
        print("📐 Player layer added to view layer")
        
        // Add status observer
        player.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
        
        // Setup looping
        if loop {
            loopObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { [weak self] _ in
                print("🔄 Video ended, looping...")
                self?.player?.seek(to: .zero)
                self?.player?.play()
            }
        }
        
        // Start playing
        player.play()
        print("▶️ Video playback started")
        
        // Add a small delay to check if video is actually playing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if player.rate == 0 {
                print("⚠️ Video is not playing (rate: \(player.rate))")
            } else {
                print("✅ Video is playing (rate: \(player.rate))")
            }
        }
    }
    
    private func showFallbackMessage() {
        // Add a label to show that video failed to load
        let label = UILabel()
        label.text = "Video not available\nUsing fallback animation"
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func updateFrame() {
        playerLayer?.frame = bounds
        print("📐 Updated player layer frame: \(bounds)")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if let player = object as? AVPlayer {
                switch player.status {
                case .readyToPlay:
                    print("✅ Video ready to play")
                case .failed:
                    print("❌ Video failed to load: \(player.error?.localizedDescription ?? "Unknown error")")
                case .unknown:
                    print("⏳ Video status unknown")
                @unknown default:
                    print("❓ Unknown video status")
                }
            }
        }
    }
    
    deinit {
        player?.removeObserver(self, forKeyPath: "status")
        if let observer = loopObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

// MARK: - Lottie Animation View (Placeholder - requires Lottie framework)
struct LottieAnimationView: View {
    let animationName: String
    let duration: Double
    let loop: Bool
    
    var body: some View {
        // This would require the Lottie-iOS framework
        // For now, we'll show a placeholder
        VStack {
            Image(systemName: "sparkles")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            Text("Lottie Animation")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}

// MARK: - Real Animation Container
struct RealAnimationContainer: View {
    let source: RealAnimationManager.AnimationSource
    let text: String
    let onComplete: (() -> Void)?
    
    @State private var animationComplete = false
    @State private var textOpacity: Double = 1.0
    @State private var animationStartTime: Date = Date()
    @State private var textParticles: [TextParticle] = []
    @State private var showTextParticles = false
    @State private var textScale: CGFloat = 1.0
    @State private var textRotation: Double = 0.0
    @State private var explosionPhase: ExplosionPhase = .normal
    
    var body: some View {
        ZStack {
            // Background animation
            switch source.type {
            case .gif:
                GIFAnimationView(
                    gifName: source.fileName,
                    duration: source.duration ?? 5.0,
                    loop: source.loop
                )
                .onAppear {
                    print("🎬 Rendering GIF: \(source.fileName)")
                    print("🎬 GIF appeared")
                    startTextDissolutionAnimation()
                    if let duration = source.duration {
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            animationComplete = true
                            onComplete?()
                        }
                    }
                }
                
            case .video:
                VideoBackgroundView(
                    videoName: source.fileName,
                    loop: source.loop
                )
                .onAppear {
                    print("🎬 Rendering Video: \(source.fileName)")
                    print("🎬 Video appeared")
                    startTextDissolutionAnimation()
                    if let duration = source.duration {
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            animationComplete = true
                            onComplete?()
                        }
                    }
                }
                
            case .lottie:
                LottieAnimationView(
                    animationName: source.fileName,
                    duration: source.duration ?? 8.0,
                    loop: source.loop
                )
                .onAppear {
                    print("🎬 Rendering Lottie: \(source.fileName)")
                    print("🎬 Lottie appeared")
                    startTextDissolutionAnimation()
                    if let duration = source.duration {
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            animationComplete = true
                            onComplete?()
                        }
                    }
                }
                
            case .spriteKit:
                // Placeholder for SpriteKit animations
                VStack {
                    Image(systemName: "gamecontroller")
                        .font(.system(size: 50))
                        .foregroundColor(.purple)
                    Text("SpriteKit Animation")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
                .onAppear {
                    print("🎬 Rendering SpriteKit placeholder")
                    startTextDissolutionAnimation()
                }
            }
            
            // Text particles that break off and follow the video theme
            if showTextParticles {
                ForEach(textParticles, id: \.id) { particle in
                    TextParticleView(particle: particle, ritualType: getRitualType())
                }
            }
            
            // Enhanced text overlay with environmental effects
            if !text.isEmpty {
                VStack {
                    Spacer()
                    
                    Text(text)
                        .font(CalmDesignSystem.Typography.largeTitle)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .opacity(textOpacity)
                        .scaleEffect(getTextScale())
                        .rotationEffect(.degrees(textRotation))
                        .blur(radius: getTextBlur())
                        .animation(.easeInOut(duration: 1.0), value: textOpacity)
                        .animation(.easeInOut(duration: 2.0), value: textScale)
                        .animation(.easeInOut(duration: 1.5), value: textRotation)
                        .overlay(
                            // Environmental effect overlay
                            getEnvironmentalEffect()
                                .opacity(textOpacity < 0.7 ? (0.7 - textOpacity) * 2 : 0)
                                .animation(.easeInOut(duration: 1.0), value: textOpacity)
                        )
                    
                    Spacer()
                }
            }
            
            // Progress indicator
            if !animationComplete {
                VStack {
                    Spacer()
                    
                    VStack(spacing: CalmDesignSystem.Spacing.md) {
                        Text(getProgressText())
                            .font(CalmDesignSystem.Typography.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .opacity(textOpacity > 0.5 ? 1.0 : 0.0)
                            .animation(.easeInOut(duration: 1.0), value: textOpacity)
                        
                        Text("Symbolic \(getRitualName()) only - your thoughts are safe")
                            .font(CalmDesignSystem.Typography.caption)
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .opacity(textOpacity > 0.4 ? 0.8 : 0.0)
                            .animation(.easeInOut(duration: 1.0), value: textOpacity)
                    }
                    .padding(.bottom, CalmDesignSystem.Spacing.xxxl)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            print("🎬 RealAnimationContainer appeared with type: \(source.type), file: \(source.fileName)")
            animationStartTime = Date()
        }
    }
    
    private func startTextDissolutionAnimation() {
        // Phase 1: Normal display (0-3 seconds)
        explosionPhase = .normal
        
        // Phase 2: Start slow expansion (3-5 seconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            explosionPhase = .expanding
            withAnimation(.easeOut(duration: 2.0)) {
                textScale = 1.3
                textRotation = Double.random(in: -15...15)
            }
        }
        
        // Phase 3: Explosion begins (5-7 seconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            explosionPhase = .exploding
            withAnimation(.easeOut(duration: 2.0)) {
                textScale = 2.0
                textRotation = Double.random(in: -45...45)
            }
            
            // Create explosion particles
            createExplosionParticles()
            showTextParticles = true
        }
        
        // Phase 4: Final dissolution (7-11 seconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
            explosionPhase = .dissolving
            withAnimation(.easeInOut(duration: 4.0)) {
                textOpacity = 0.0
                textScale = 0.1
                textRotation = Double.random(in: -180...180)
            }
        }
    }
    
    private func createTextParticles() {
        let particleCount = 15
        textParticles = (0..<particleCount).map { _ in
            TextParticle(
                id: UUID(),
                x: CGFloat.random(in: -100...100),
                y: CGFloat.random(in: -50...50),
                size: CGFloat.random(in: 2...6),
                opacity: 1.0,
                velocity: getParticleVelocity(),
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -5...5),
                scale: CGFloat.random(in: 0.5...1.2)
            )
        }
    }
    
    private func createExplosionParticles() {
        let particleCount = 25 // More particles for explosion
        textParticles = (0..<particleCount).map { _ in
            TextParticle(
                id: UUID(),
                x: CGFloat.random(in: -150...150),
                y: CGFloat.random(in: -75...75),
                size: CGFloat.random(in: 3...8),
                opacity: 1.0,
                velocity: getExplosionVelocity(),
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -10...10),
                scale: CGFloat.random(in: 0.8...1.5)
            )
        }
    }
    
    private func getExplosionVelocity() -> CGPoint {
        let angle = Double.random(in: 0...2 * .pi)
        let speed = CGFloat.random(in: 2...6)
        return CGPoint(
            x: cos(angle) * speed,
            y: sin(angle) * speed
        )
    }
    
    private func getTextScale() -> CGFloat {
        switch explosionPhase {
        case .normal:
            return 1.0
        case .expanding:
            return textScale
        case .exploding:
            return textScale
        case .dissolving:
            return textScale
        }
    }
    
    private func getTextBlur() -> CGFloat {
        switch explosionPhase {
        case .normal:
            return 0
        case .expanding:
            return 1.0
        case .exploding:
            return 2.0
        case .dissolving:
            return 4.0
        }
    }
    
    private func getParticleVelocity() -> CGPoint {
        switch getRitualType() {
        case "fire":
            return CGPoint(x: CGFloat.random(in: -2...2), y: CGFloat.random(in: -3...(-1)))
        case "smoke":
            return CGPoint(x: CGFloat.random(in: -1...1), y: CGFloat.random(in: -2...(-0.5)))
        case "bury":
            return CGPoint(x: CGFloat.random(in: -1...1), y: CGFloat.random(in: 1...3))
        case "wash":
            return CGPoint(x: CGFloat.random(in: -2...2), y: CGFloat.random(in: 1...3))
        default:
            return CGPoint(x: CGFloat.random(in: -1...1), y: CGFloat.random(in: -1...1))
        }
    }
    
    private func getRitualType() -> String {
        switch source.fileName {
        case "fire_background":
            return "fire"
        case "smoke_background":
            return "smoke"
        case "soil_background":
            return "bury"
        case "water_background":
            return "wash"
        default:
            return "fire"
        }
    }
    
    @ViewBuilder
    private func getEnvironmentalEffect() -> some View {
        switch getRitualType() {
        case "fire":
            // Fire flicker effect
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.orange.opacity(0.3),
                            Color.red.opacity(0.2),
                            Color.yellow.opacity(0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .blur(radius: 2)
        case "smoke":
            // Smoke wisps effect
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.gray.opacity(0.4),
                            Color.white.opacity(0.2),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .blur(radius: 3)
        case "bury":
            // Earth particles effect
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.brown.opacity(0.3),
                            Color.orange.opacity(0.2),
                            Color.yellow.opacity(0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .blur(radius: 2)
        case "wash":
            // Water ripple effect
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.3),
                            Color.cyan.opacity(0.2),
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .blur(radius: 2)
        default:
            EmptyView()
        }
    }
    
    private func getProgressText() -> String {
        switch source.fileName {
        case "fire_background":
            return "Burning away..."
        case "smoke_background":
            return "Dissolving into smoke..."
        case "soil_background":
            return "Burying in earth..."
        case "water_background":
            return "Washing away..."
        default:
            return "Releasing..."
        }
    }
    
    private func getRitualName() -> String {
        switch source.fileName {
        case "fire_background":
            return "burning"
        case "smoke_background":
            return "smoking"
        case "soil_background":
            return "burying"
        case "water_background":
            return "washing"
        default:
            return "release"
        }
    }
}

// MARK: - Enhanced Ritual Views with Real Animations
struct EnhancedRitualView: View {
    let ritualType: String
    let text: String
    let onComplete: () -> Void
    
    @State private var showRealAnimation = false
    @State private var animationSource: RealAnimationManager.AnimationSource?
    
    var body: some View {
        ZStack {
                    if showRealAnimation, let source = animationSource {
            RealAnimationContainer(source: source, text: text) {
                onComplete()
            }
        } else {
            // Fallback to current animations
            fallbackView
        }
        }
        .onAppear {
            loadRealAnimation()
        }
    }
    
    @ViewBuilder
    private var fallbackView: some View {
        switch ritualType {
        case "burn":
            CalmBurnAnimationView(worryText: text, onComplete: onComplete)
        case "smoke":
            SmokeAnimation(text: text, onComplete: onComplete)
        case "bury":
            BuryAnimation(text: text, onComplete: onComplete)
        case "wash":
            WashAnimation(text: text, onComplete: onComplete)
        default:
            CalmBurnAnimationView(worryText: text, onComplete: onComplete)
        }
    }
    
    private func loadRealAnimation() {
        print("🔍 Loading real animation for ritual: \(ritualType)")
        
        // Check if real animation files exist (prioritize videos over GIFs)
        switch ritualType {
        case "burn":
            // Try video first, then GIF
            if let videoPath = Bundle.main.path(forResource: "fire_background", ofType: "mp4") {
                print("✅ Found fire video: \(videoPath)")
                animationSource = RealAnimationManager.fireVideo
                showRealAnimation = true
            } else if let gifPath = Bundle.main.path(forResource: "fire_animation", ofType: "gif") {
                print("✅ Found fire GIF: \(gifPath)")
                animationSource = RealAnimationManager.fireGif
                showRealAnimation = true
            } else {
                print("❌ No fire animation files found - using fallback")
            }
        case "smoke":
            if let videoPath = Bundle.main.path(forResource: "smoke_background", ofType: "mp4") {
                print("✅ Found smoke video: \(videoPath)")
                animationSource = RealAnimationManager.smokeVideo
                showRealAnimation = true
            } else if let gifPath = Bundle.main.path(forResource: "smoke_animation", ofType: "gif") {
                print("✅ Found smoke GIF: \(gifPath)")
                animationSource = RealAnimationManager.smokeGif
                showRealAnimation = true
            } else {
                print("❌ No smoke animation files found - using fallback")
            }
        case "bury":
            if let videoPath = Bundle.main.path(forResource: "soil_background", ofType: "mp4") {
                print("✅ Found soil video: \(videoPath)")
                animationSource = RealAnimationManager.soilVideo
                showRealAnimation = true
            } else if let gifPath = Bundle.main.path(forResource: "earth_bury", ofType: "gif") {
                print("✅ Found earth GIF: \(gifPath)")
                animationSource = RealAnimationManager.earthGif
                showRealAnimation = true
            } else {
                print("❌ No bury animation files found - using fallback")
            }
        case "wash":
            if let videoPath = Bundle.main.path(forResource: "water_background", ofType: "mp4") {
                print("✅ Found water video: \(videoPath)")
                animationSource = RealAnimationManager.waterVideo
                showRealAnimation = true
            } else if let gifPath = Bundle.main.path(forResource: "water_wave", ofType: "gif") {
                print("✅ Found water GIF: \(gifPath)")
                animationSource = RealAnimationManager.waterGif
                showRealAnimation = true
            } else {
                print("❌ No wash animation files found - using fallback")
            }
        default:
            print("❌ Unknown ritual type: \(ritualType)")
            break
        }
        
        print("🎬 Animation source: \(animationSource?.fileName ?? "none")")
        print("🎬 Show real animation: \(showRealAnimation)")
    }
}

// MARK: - Explosion Phase Enum
enum ExplosionPhase {
    case normal
    case expanding
    case exploding
    case dissolving
}

// MARK: - Text Particle Model
struct TextParticle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
    var velocity: CGPoint
    var rotation: Double
    var rotationSpeed: Double
    var scale: CGFloat
}

// MARK: - Text Particle View
struct TextParticleView: View {
    let particle: TextParticle
    let ritualType: String
    
    @State private var currentParticle = TextParticle(
        id: UUID(),
        x: 0,
        y: 0,
        size: 0,
        opacity: 0,
        velocity: CGPoint(x: 0, y: 0),
        rotation: 0,
        rotationSpeed: 0,
        scale: 0
    )
    
    var body: some View {
        Circle()
            .fill(getParticleColor())
            .frame(width: currentParticle.size, height: currentParticle.size)
            .position(x: currentParticle.x, y: currentParticle.y)
            .rotationEffect(.degrees(currentParticle.rotation))
            .scaleEffect(currentParticle.scale)
            .opacity(currentParticle.opacity)
            .blur(radius: getBlurRadius())
            .onAppear {
                currentParticle = particle
                startParticleAnimation()
            }
    }
    
    private func getParticleColor() -> Color {
        switch ritualType {
        case "fire":
            return Color.orange.opacity(0.8)
        case "smoke":
            return Color.gray.opacity(0.6)
        case "bury":
            return Color.brown.opacity(0.7)
        case "wash":
            return Color.blue.opacity(0.6)
        default:
            return Color.white.opacity(0.5)
        }
    }
    
    private func getBlurRadius() -> CGFloat {
        switch ritualType {
        case "fire":
            return 1.0
        case "smoke":
            return 2.0
        case "bury":
            return 0.5
        case "wash":
            return 1.5
        default:
            return 1.0
        }
    }
    
    private func startParticleAnimation() {
        // Enhanced explosion animation
        withAnimation(.easeOut(duration: 5.0)) {
            currentParticle.x += currentParticle.velocity.x * 150
            currentParticle.y += currentParticle.velocity.y * 150
            currentParticle.opacity = 0.0
            currentParticle.scale *= 2.0
        }
        
        // Continuous rotation with varying speed
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if currentParticle.opacity <= 0 {
                timer.invalidate()
                return
            }
            
            withAnimation(.linear(duration: 0.05)) {
                currentParticle.rotation += currentParticle.rotationSpeed
            }
        }
        
        // Add gravity effect for some particles
        if ritualType == "bury" {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                if currentParticle.opacity <= 0 {
                    timer.invalidate()
                    return
                }
                
                withAnimation(.linear(duration: 0.1)) {
                    currentParticle.velocity.y += 0.1 // Gravity
                }
            }
        }
    }
}

#Preview {
    RealAnimationContainer(source: RealAnimationManager.fireGif, text: "This is a test worry that will be burned away") {
        print("Animation complete")
    }
}
