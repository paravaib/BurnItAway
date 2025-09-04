import SwiftUI

// MARK: - Calm-Inspired Design System
struct CalmDesignSystem {
    
    // MARK: - Colors (Calm-inspired palette)
    struct Colors {
        // Primary colors - warm, calming tones
        static let primary = Color(red: 0.95, green: 0.6, blue: 0.3) // Warm orange
        static let secondary = Color(red: 0.8, green: 0.4, blue: 0.6) // Soft purple
        static let accent = Color(red: 0.9, green: 0.7, blue: 0.4) // Golden yellow
        
        // Background colors - deep, soothing
        static let background = Color(red: 0.05, green: 0.05, blue: 0.1) // Deep navy
        static let surface = Color(red: 0.1, green: 0.1, blue: 0.15) // Dark surface
        static let surfaceElevated = Color(red: 0.15, green: 0.15, blue: 0.2) // Elevated surface
        
        // Text colors - soft, readable
        static let textPrimary = Color(red: 0.95, green: 0.95, blue: 0.98) // Soft white
        static let textSecondary = Color(red: 0.7, green: 0.7, blue: 0.8) // Muted text
        static let textTertiary = Color(red: 0.5, green: 0.5, blue: 0.6) // Subtle text
        
        // Fire colors - realistic flame palette
        static let fireWhite = Color(red: 1.0, green: 1.0, blue: 0.9) // Hot white
        static let fireYellow = Color(red: 1.0, green: 0.9, blue: 0.3) // Bright yellow
        static let fireOrange = Color(red: 1.0, green: 0.6, blue: 0.2) // Hot orange
        static let fireRed = Color(red: 0.9, green: 0.3, blue: 0.1) // Deep red
        static let fireDark = Color(red: 0.3, green: 0.1, blue: 0.05) // Dark ember
        
        // Space colors - cosmic purple palette
        static let spacePurple = Color(red: 0.5, green: 0.3, blue: 0.8) // Cosmic purple
        static let spaceBlue = Color(red: 0.3, green: 0.5, blue: 0.9) // Deep space blue
        static let spaceIndigo = Color(red: 0.4, green: 0.2, blue: 0.7) // Space indigo
        
        // Status colors
        static let success = Color(red: 0.2, green: 0.8, blue: 0.4) // Success green
        static let warning = Color(red: 1.0, green: 0.7, blue: 0.2) // Warning orange
        static let error = Color(red: 0.9, green: 0.3, blue: 0.3) // Error red
        
        // Glassmorphism
        static let glass = Color.white.opacity(0.1)
        static let glassBorder = Color.white.opacity(0.2)
        
        // Shadows
        static let shadow = Color.black.opacity(0.3)
        static let shadowStrong = Color.black.opacity(0.5)
    }
    
    // MARK: - Typography (Calm-inspired fonts with Dynamic Type support)
    struct Typography {
        // Headers - elegant, readable with Dynamic Type
        static let largeTitle = Font.system(size: 34, weight: .light, design: .rounded)
        static let title = Font.system(size: 28, weight: .light, design: .rounded)
        static let headline = Font.system(size: 22, weight: .medium, design: .rounded)
        static let subheadline = Font.system(size: 18, weight: .regular, design: .rounded)
        
        // Body text - comfortable reading with Dynamic Type
        static let body = Font.system(size: 16, weight: .regular, design: .rounded)
        static let bodyEmphasized = Font.system(size: 16, weight: .medium, design: .rounded)
        static let callout = Font.system(size: 14, weight: .regular, design: .rounded)
        static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
        static let caption1 = Font.system(size: 12, weight: .regular, design: .rounded)
        
        // Special text with Dynamic Type
        static let quote = Font.system(size: 20, weight: .light, design: .serif)
        static let button = Font.system(size: 16, weight: .semibold, design: .rounded)
    }
    
    // MARK: - Spacing (Calm-inspired rhythm)
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }
    
    // MARK: - Corner Radius (Calm-inspired curves)
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }
    
    // MARK: - Shadows (Calm-inspired depth)
    struct Shadows {
        static let subtle = Shadow(color: Colors.shadow, radius: 4, x: 0, y: 2)
        static let medium = Shadow(color: Colors.shadow, radius: 8, x: 0, y: 4)
        static let strong = Shadow(color: Colors.shadowStrong, radius: 16, x: 0, y: 8)
        static let glow = Shadow(color: Colors.primary.opacity(0.3), radius: 20, x: 0, y: 0)
    }
    
    // MARK: - Animations (Calm-inspired timing with performance optimization)
    struct Animations {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let gentle = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.8)
        static let breathing = SwiftUI.Animation.easeInOut(duration: 4.0)
        
        // Custom easing curves with performance optimization
        static let calmEase = SwiftUI.Animation.timingCurve(0.25, 0.1, 0.25, 1.0, duration: 0.3)
        static let fireEase = SwiftUI.Animation.timingCurve(0.4, 0.0, 0.2, 1.0, duration: 0.4)
        
        // Performance-optimized animations
        static let optimizedQuick = SwiftUI.Animation.easeInOut(duration: 0.2).speed(1.2)
        static let optimizedSmooth = SwiftUI.Animation.easeInOut(duration: 0.3).speed(1.1)
        static let optimizedGentle = SwiftUI.Animation.easeInOut(duration: 0.5).speed(1.0)
    }
}

// MARK: - Shadow Helper
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Calm-Inspired Button Styles
struct CalmPrimaryButtonStyle: ButtonStyle {
    let color: Color
    
    init(color: Color = CalmDesignSystem.Colors.primary) {
        self.color = color
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(CalmDesignSystem.Typography.button)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.8)
            .allowsTightening(true)
            .padding(.horizontal, CalmDesignSystem.Spacing.xl)
            .padding(.vertical, CalmDesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(CalmDesignSystem.Animations.quick, value: configuration.isPressed)
    }
}

struct CalmSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(CalmDesignSystem.Typography.button)
            .foregroundColor(CalmDesignSystem.Colors.textPrimary)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.8)
            .allowsTightening(true)
            .padding(.horizontal, CalmDesignSystem.Spacing.xl)
            .padding(.vertical, CalmDesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                    .fill(CalmDesignSystem.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                            .stroke(CalmDesignSystem.Colors.glassBorder, lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(CalmDesignSystem.Animations.quick, value: configuration.isPressed)
    }
}

struct CalmFloatingButtonStyle: ButtonStyle {
    let color: Color
    
    init(color: Color = CalmDesignSystem.Colors.primary) {
        self.color = color
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 24, weight: .medium))
            .foregroundColor(.white)
            .frame(width: 60, height: 60)
            .background(
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [color, color.opacity(0.8)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 30
                        )
                    )
                    .shadow(color: color.opacity(0.4), radius: 12, x: 0, y: 6)
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(CalmDesignSystem.Animations.smooth, value: configuration.isPressed)
    }
}

// MARK: - Glassmorphism Card
struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                    .fill(CalmDesignSystem.Colors.glass)
                    .overlay(
                        RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                            .stroke(CalmDesignSystem.Colors.glassBorder, lineWidth: 1)
                    )
                    .shadow(color: CalmDesignSystem.Colors.shadow, radius: 8, x: 0, y: 4)
            )
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCard())
    }
    
    // MARK: - Text Accessibility Helpers
    func accessibleText() -> some View {
        self
            .lineLimit(3)
            .minimumScaleFactor(0.8)
            .allowsTightening(true)
            .multilineTextAlignment(.center)
    }
    
    func accessibleButtonText() -> some View {
        self
            .lineLimit(2)
            .minimumScaleFactor(0.8)
            .allowsTightening(true)
            .multilineTextAlignment(.center)
    }
}

// MARK: - Calm Background
struct CalmBackground<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Base gradient background
            LinearGradient(
                colors: [
                    CalmDesignSystem.Colors.background,
                    CalmDesignSystem.Colors.background.opacity(0.8),
                    CalmDesignSystem.Colors.surface
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Subtle overlay pattern
            RadialGradient(
                colors: [
                    CalmDesignSystem.Colors.primary.opacity(0.05),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 100,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            content
        }
    }
}

// MARK: - Breathing Indicator
struct BreathingIndicator: View {
    @State private var isBreathing = false
    @State private var breathScale: CGFloat = 1.0
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        CalmDesignSystem.Colors.primary.opacity(0.3),
                        CalmDesignSystem.Colors.primary.opacity(0.1),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 10,
                    endRadius: 50
                )
            )
            .frame(width: 100, height: 100)
            .scaleEffect(breathScale)
            .onAppear {
                startBreathing()
            }
    }
    
    private func startBreathing() {
        withAnimation(CalmDesignSystem.Animations.breathing.repeatForever(autoreverses: true)) {
            breathScale = 1.2
        }
    }
}

// MARK: - Haptic Feedback
struct HapticFeedback {
    static func light() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    static func medium() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    static func heavy() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    static func success() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    static func warning() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }
    
    static func error() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
}

// MARK: - Performance Monitoring
struct PerformanceMonitor {
    static func measureAnimation<T>(_ operation: () -> T) -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = operation()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        #if DEBUG
        if timeElapsed > 0.016 { // 60fps threshold
            print("⚠️ Performance: Animation took \(timeElapsed * 1000)ms (target: 16ms)")
        }
        #endif
        
        return result
    }
    
    static func optimizeForDevice() -> Bool {
        // Simple device capability check
        let processInfo = ProcessInfo.processInfo
        return processInfo.processorCount >= 6 // Assume newer devices can handle more
    }
}
