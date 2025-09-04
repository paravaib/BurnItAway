import SwiftUI

struct Cloud: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var scale: CGFloat
    var opacity: Double
    var speed: CGFloat
}

struct AnimatedSkyBackground: View {
    @State private var clouds: [Cloud] = []
    @State private var animationTimer: Timer?
    @State private var skyGradientShift: Double = 0
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack {
            // Animated sky gradient
            LinearGradient(
                colors: [
                    Color(red: 0.05 + skyGradientShift * 0.02, green: 0.1 + skyGradientShift * 0.03, blue: 0.25 + skyGradientShift * 0.05),
                    Color(red: 0.08 + skyGradientShift * 0.015, green: 0.12 + skyGradientShift * 0.025, blue: 0.22 + skyGradientShift * 0.04),
                    Color(red: 0.02, green: 0.05, blue: 0.15),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .animation(.easeInOut(duration: 8.0), value: skyGradientShift)
            
            // Subtle stars/sparkles
            ForEach(0..<15, id: \.self) { _ in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.1...0.3)))
                    .frame(width: CGFloat.random(in: 1...3), height: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...screenWidth),
                        y: CGFloat.random(in: 0...screenHeight * 0.4)
                    )
                    .opacity(skyGradientShift > 0.3 ? 0.6 : 0.2)
                    .animation(.easeInOut(duration: 4.0), value: skyGradientShift)
            }
            
            // Animated clouds
            ForEach(clouds) { cloud in
                CloudShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(cloud.opacity * 0.8),
                                Color.white.opacity(cloud.opacity * 0.4),
                                Color.white.opacity(cloud.opacity * 0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120 * cloud.scale, height: 60 * cloud.scale)
                    .position(x: cloud.x, y: cloud.y)
                    .blur(radius: 1.5)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            startSkyAnimation()
        }
        .onDisappear {
            stopSkyAnimation()
        }
    }
    
    private func startSkyAnimation() {
        // Create initial clouds
        createClouds()
        
        // Start sky gradient breathing
        withAnimation(.easeInOut(duration: 12.0).repeatForever(autoreverses: true)) {
            skyGradientShift = 0.5
        }
        
        // Start cloud movement animation
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            updateClouds()
        }
    }
    
    private func stopSkyAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func createClouds() {
        clouds.removeAll()
        
        // Create 8-12 clouds at random positions
        for _ in 0..<Int.random(in: 8...12) {
            let cloud = Cloud(
                x: CGFloat.random(in: -100...screenWidth + 100),
                y: CGFloat.random(in: 50...screenHeight * 0.6),
                scale: CGFloat.random(in: 0.6...1.4),
                opacity: Double.random(in: 0.15...0.35),
                speed: CGFloat.random(in: 0.2...0.8)
            )
            clouds.append(cloud)
        }
    }
    
    private func updateClouds() {
        for i in clouds.indices {
            // Move clouds slowly to the right
            clouds[i].x += clouds[i].speed
            
            // Add slight vertical drift
            clouds[i].y += sin(Date().timeIntervalSince1970 * 0.3 + Double(i)) * 0.1
            
            // Wrap around when cloud moves off screen
            if clouds[i].x > screenWidth + 150 {
                clouds[i].x = -150
                clouds[i].y = CGFloat.random(in: 50...screenHeight * 0.6)
                clouds[i].scale = CGFloat.random(in: 0.6...1.4)
                clouds[i].opacity = Double.random(in: 0.15...0.35)
                clouds[i].speed = CGFloat.random(in: 0.2...0.8)
            }
        }
    }
}

struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Create a cloud-like shape with multiple overlapping circles
        path.addEllipse(in: CGRect(x: width * 0.1, y: height * 0.3, width: width * 0.3, height: height * 0.6))
        path.addEllipse(in: CGRect(x: width * 0.25, y: height * 0.1, width: width * 0.4, height: height * 0.7))
        path.addEllipse(in: CGRect(x: width * 0.45, y: height * 0.2, width: width * 0.35, height: height * 0.6))
        path.addEllipse(in: CGRect(x: width * 0.6, y: height * 0.35, width: width * 0.3, height: height * 0.5))
        
        return path
    }
}

#Preview {
    AnimatedSkyBackground()
        .frame(width: 400, height: 600)
}
