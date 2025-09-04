import SwiftUI

struct GlowingButtonStyle: ButtonStyle {
    let color: Color
    @State private var glowIntensity: CGFloat = 0.3
    @State private var breathingScale: CGFloat = 1.0
    @State private var innerGlow: CGFloat = 0.0
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: .medium, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 56)
            .background(
                ZStack {
                    // Outer glow
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    color.opacity(0.8),
                                    color.opacity(0.4),
                                    color.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: color.opacity(glowIntensity), radius: 20, x: 0, y: 0)
                        .shadow(color: color.opacity(glowIntensity * 0.5), radius: 30, x: 0, y: 0)
                    
                    // Inner glow
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            RadialGradient(
                                colors: [
                                    color.opacity(0.6),
                                    color.opacity(0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 50
                            )
                        )
                        .scaleEffect(innerGlow)
                    
                    // Subtle texture overlay
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.clear,
                                    Color.black.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                color.opacity(0.6),
                                color.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.96 : breathingScale)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
            .onAppear {
                // Gentle breathing animation
                withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                    breathingScale = 1.02
                }
                
                // Pulsing glow
                withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                    glowIntensity = 0.6
                }
                
                // Inner glow pulse
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                    innerGlow = 1.1
                }
            }
            .onChange(of: configuration.isPressed) { isPressed in
                if isPressed {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
            }
    }
}



#Preview {
    VStack(spacing: 20) {
        NavigationLink("🔥 Burn Your Thought", destination: Text("Burn View"))
            .buttonStyle(GlowingButtonStyle(color: .orange))
        
        NavigationLink("🌱 Grow Positivity", destination: Text("Grow View"))
            .buttonStyle(GlowingButtonStyle(color: .green))
        
        Button("🌱 View Garden") { }
            .buttonStyle(CalmSecondaryButtonStyle())
        
        Button("Return Home") { }
            .buttonStyle(CalmSecondaryButtonStyle())
    }
    .padding()
    .background(
        LinearGradient(
            colors: [Color.indigo, Color.black],
            startPoint: .top,
            endPoint: .bottom
        )
    )
}
