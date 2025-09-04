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
    static let shredGif = AnimationSource(type: .gif, fileName: "paper_shred", duration: 5.0)
    static let earthGif = AnimationSource(type: .gif, fileName: "earth_bury", duration: 6.0)
    
    static let fireLottie = AnimationSource(type: .lottie, fileName: "fire_lottie", duration: 8.0)
    static let waterLottie = AnimationSource(type: .lottie, fileName: "water_lottie", duration: 10.0)
    
    // Video backgrounds (you've added these!)
    static let fireVideo = AnimationSource(type: .video, fileName: "fire_background", duration: 10.0, loop: true)
    static let shredVideo = AnimationSource(type: .video, fileName: "shred_background", duration: 8.0, loop: true)
    static let soilVideo = AnimationSource(type: .video, fileName: "soil_background", duration: 12.0, loop: true)
    static let waterVideo = AnimationSource(type: .video, fileName: "water_background", duration: 10.0, loop: true)
    
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
    let onComplete: (() -> Void)?
    
    @State private var animationComplete = false
    
    var body: some View {
        ZStack {
            // Add a background color to see if the container is rendering
            Color.black.ignoresSafeArea()
            
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
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            print("🎬 RealAnimationContainer appeared with type: \(source.type), file: \(source.fileName)")
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
                RealAnimationContainer(source: source) {
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
        case "shred":
            ShredAnimation(text: text, onComplete: onComplete)
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
        case "shred":
            if let videoPath = Bundle.main.path(forResource: "shred_background", ofType: "mp4") {
                print("✅ Found shred video: \(videoPath)")
                animationSource = RealAnimationManager.shredVideo
                showRealAnimation = true
            } else if let gifPath = Bundle.main.path(forResource: "paper_shred", ofType: "gif") {
                print("✅ Found shred GIF: \(gifPath)")
                animationSource = RealAnimationManager.shredGif
                showRealAnimation = true
            } else {
                print("❌ No shred animation files found - using fallback")
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

#Preview {
    RealAnimationContainer(source: RealAnimationManager.fireGif) {
        print("Animation complete")
    }
}
