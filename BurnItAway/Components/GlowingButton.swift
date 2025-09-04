import SwiftUI

struct GlowingButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var glowIntensity: CGFloat = 0.5
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
            
            action()
        }) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(color)
                        .shadow(color: color.opacity(glowIntensity), radius: 20, x: 0, y: 0)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glowIntensity = 0.8
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        GlowingButton(title: "🔥 Burn Your Thought", color: .orange) {
            print("Burn tapped")
        }
        
        GlowingButton(title: "🌱 Store Positivity", color: .green) {
            print("Store tapped")
        }
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
