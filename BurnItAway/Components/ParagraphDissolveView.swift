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
    
    @State private var characters: [DissolveCharacter] = []
    @State private var showFullText = false
    @State private var isDissolving = false
    @State private var currentCharIndex = 0
    @State private var allCharactersDissolved = false
    
    // Animation timing
    private let showDuration: Double = 4.0 // Show full text for 4 seconds
    private let dissolveDelay: Double = 0.08 // Delay between character dissolves
    private let dissolveDuration: Double = 2.0 // Duration for each character to dissolve
    
    var body: some View {
        VStack(spacing: CalmDesignSystem.Spacing.lg) {
            Spacer()
            
            // Full paragraph text display
            VStack(spacing: CalmDesignSystem.Spacing.md) {
                Text("Your Worry")
                    .font(CalmDesignSystem.Typography.headline)
                    .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                    .opacity(showFullText ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8), value: showFullText)
                
                // Paragraph text with letter-by-letter dissolve
                HStack(alignment: .top, spacing: 0) {
                    ForEach(characters) { char in
                        Text(String(char.character))
                            .font(.system(size: 26, weight: .regular, design: .rounded))
                            .foregroundColor(charColor)
                            .opacity(char.opacity)
                            .scaleEffect(char.scale)
                            .blur(radius: char.blur)
                            .offset(x: char.offsetX, y: char.offsetY)
                            .rotationEffect(.degrees(char.rotation))
                            .shadow(
                                color: charColor.opacity(char.opacity * 0.5),
                                radius: char.isDissolving ? 8 : 0
                            )
                            .animation(
                                .easeInOut(duration: dissolveDuration)
                                .delay(char.dissolveDelay),
                                value: char.isDissolving
                            )
                    }
                }
                .multilineTextAlignment(.leading)
                .lineSpacing(8)
                .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                .opacity(showFullText ? 1.0 : 0.0)
                .scaleEffect(showFullText ? 1.0 : 0.95)
                .animation(.easeInOut(duration: 1.2), value: showFullText)
            }
            
            Spacer()
        }
        .onAppear {
            setupCharacters()
            startAnimation()
        }
    }
    
    private func setupCharacters() {
        characters = text.map { char in
            DissolveCharacter(
                character: char,
                opacity: 1.0,
                scale: 1.0,
                blur: 0.0,
                offsetX: 0.0,
                offsetY: 0.0,
                rotation: 0.0,
                isDissolving: false,
                dissolveDelay: 0.0
            )
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
        
        // Dissolve characters one by one
        for (index, _) in characters.enumerated() {
            let delay = Double(index) * dissolveDelay
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: dissolveDuration)) {
                    characters[index].isDissolving = true
                    characters[index].opacity = 0.0
                    characters[index].scale = 0.1
                    characters[index].blur = 5.0
                    characters[index].offsetX = Double.random(in: -30...30)
                    characters[index].offsetY = Double.random(in: -20...20)
                    characters[index].rotation = Double.random(in: -25...25)
                }
            }
        }
        
        // Complete after all characters have started dissolving
        let totalDissolveTime = Double(characters.count) * dissolveDelay + dissolveDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDissolveTime) {
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

// MARK: - Dissolve Character Model
struct DissolveCharacter: Identifiable {
    let id = UUID()
    let character: Character
    var opacity: Double
    var scale: CGFloat
    var blur: CGFloat
    var offsetX: Double
    var offsetY: Double
    var rotation: Double
    var isDissolving: Bool
    var dissolveDelay: Double
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
