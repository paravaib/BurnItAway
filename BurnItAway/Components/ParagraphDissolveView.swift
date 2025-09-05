//
//  ParagraphDissolveView.swift
//  BurnItAway
//
//  Created by Vaibhav Parashar on 9/4/25.
//

import SwiftUI

struct ParagraphDissolveView: View {
    let text: String
    let ritualType: String
    let onComplete: () -> Void
    
    @State private var showFullText = false
    @State private var isDissolving = false
    @State private var dissolveProgress: Double = 0.0
    @State private var allCharactersDissolved = false
    
    // Animation timing
    private let showDuration: Double = 4.0 // Show full text for 4 seconds
    private let dissolveDuration: Double = 3.0 // Duration for dissolve effect
    
    var body: some View {
        VStack(spacing: CalmDesignSystem.Spacing.lg) {
            Spacer()
            
            // Full paragraph text display
            VStack(spacing: CalmDesignSystem.Spacing.md) {
                // Clean text display with mask-based dissolve
                Text(text)
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .kerning(1.5)
                    .foregroundColor(charColor)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(6)
                    .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                    .opacity(showFullText ? 1.0 : 0.0)
                    .scaleEffect(showFullText ? 1.0 : 0.95)
                    .animation(.easeInOut(duration: 1.2), value: showFullText)
                    .mask(
                        // Mask for dissolve effect
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.black,
                                        Color.black.opacity(1.0 - dissolveProgress),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                    .blur(radius: isDissolving ? dissolveProgress * 3.0 : 0.0)
                    .scaleEffect(isDissolving ? 1.0 - (dissolveProgress * 0.1) : 1.0)
                    .offset(y: isDissolving ? dissolveProgress * 20.0 : 0.0)
                    .allowsHitTesting(false)
            }
            
            Spacer()
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // First, show the full text
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 1.0)) {
                showFullText = true
            }
            
            // After showing full text, start dissolving
            DispatchQueue.main.asyncAfter(deadline: .now() + showDuration) {
                startDissolving()
            }
        }
    }
    
    private func startDissolving() {
        isDissolving = true
        
        // Animate dissolve progress
        withAnimation(.easeInOut(duration: dissolveDuration)) {
            dissolveProgress = 1.0
        }
        
        // Complete after dissolve
        DispatchQueue.main.asyncAfter(deadline: .now() + dissolveDuration) {
            allCharactersDissolved = true
            onComplete()
        }
    }
    
    private var charColor: Color {
        switch ritualType.lowercased() {
        case "burn":
            return CalmDesignSystem.Colors.fireOrange
        case "smoke":
            return CalmDesignSystem.Colors.textSecondary
        case "space":
            return CalmDesignSystem.Colors.spacePurple
        case "wash":
            return CalmDesignSystem.Colors.spaceBlue
        default:
            return CalmDesignSystem.Colors.textPrimary
        }
    }
}

// MARK: - Preview
#Preview {
    ParagraphDissolveView(
        text: "I'm worried about my future and what tomorrow will bring. I feel anxious about making the right decisions and fear that I might fail.",
        ritualType: "burn",
        onComplete: {}
    )
    .background(Color.black)
}