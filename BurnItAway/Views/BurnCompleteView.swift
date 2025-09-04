import SwiftUI

struct BurnCompleteView: View {
    let animationType: String?
    let worryText: String?
    
    @State private var navigateToHome = false
    @State private var navigateToBurn = false

    @State private var showMessage = false


    
    init(animationType: String? = nil, worryText: String? = nil) {
        self.animationType = animationType
        self.worryText = worryText
    }
    
    var body: some View {
        CalmBackground {
            VStack {
                Spacer()
                
                // Centered content
                VStack(spacing: 30) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.white.opacity(0.9))
                        .accessibilityHidden(true)
                    
                    VStack(spacing: 16) {
                        Text("It's released.")
                            .font(.system(size: 36, weight: .light, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                            .allowsTightening(true)
                        
                        Text("Rest now.")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                            .allowsTightening(true)
                    }
                    .opacity(showMessage ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 1.5), value: showMessage)
                }
                
                Spacer()
                
                // Action buttons at bottom
                VStack(spacing: 16) {
                    Button(action: { navigateToBurn = true }) {
                        Text("Do it again")
                    }
                    .buttonStyle(CalmPrimaryButtonStyle(color: .orange))
                    .accessibilityLabel("Burn another worry")
                    .accessibilityHint("Tap to release another worry")
                    
                    Button("Return Home") { navigateToHome = true }
                        .buttonStyle(CalmSecondaryButtonStyle())
                        .accessibilityLabel("Return to home screen")
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationDestination(isPresented: $navigateToHome) { ContentView() }
        .navigationDestination(isPresented: $navigateToBurn) { EnhancedBurnView() }
        .preferredColorScheme(.dark)
        .onAppear {
            // Show message with a gentle delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { showMessage = true }
            
            // Request review after successful burn (with delay)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                ReviewManager.shared.requestReviewIfAppropriate()
            }
        }
    }
}

#Preview {
    BurnCompleteView()
}
