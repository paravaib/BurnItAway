import SwiftUI

struct CalmingBackgroundView<Content: View>: View {
    let content: Content
    let emotion: String
    let intensity: Double
    @EnvironmentObject var appState: AppState
    
    init(
        emotion: String = "calm",
        intensity: Double = 0.5,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.emotion = emotion
        self.intensity = intensity
    }
    
    var body: some View {
        ZStack {
            // Animated sky background
            AnimatedSkyBackground()
            
            // Optional overlay for lights-off mode
            if appState.lightsOff {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.8), value: appState.lightsOff)
            }
            
            // Content
            content
        }
    }
}

#Preview {
    CalmingBackgroundView {
        VStack {
            Text("Sample Content")
                .foregroundColor(.white)
                .font(.largeTitle)
        }
    }
    .environmentObject(AppState())
}
