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
    @State private var dissolvingChars: Set<String> = []
    @State private var allCharactersDissolved = false
    
    // Animation timing
    private let showDuration: Double = 4.0 // Show full text for 4 seconds
    private let dissolveDuration: Double = 3.0 // Duration for dissolve effect
    
    var body: some View {
        VStack(spacing: CalmDesignSystem.Spacing.lg) {
            Spacer()
            
            // Full paragraph text display
            VStack(spacing: CalmDesignSystem.Spacing.md) {
                // Letter-by-letter dissolve text display
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(createTextLines().enumerated()), id: \.offset) { lineIndex, line in
                        HStack(alignment: .top, spacing: 2) {
                            ForEach(Array(line.enumerated()), id: \.offset) { charIndex, char in
                                Text(String(char))
                                    .font(.system(size: 20, weight: .regular, design: .rounded))
                                    .kerning(1.5)
                                    .foregroundColor(charColor)
                                    .opacity(showFullText ? (dissolvingChars.contains("\(lineIndex)-\(charIndex)") ? 0.0 : 1.0) : 0.0)
                                    .scaleEffect(showFullText ? (dissolvingChars.contains("\(lineIndex)-\(charIndex)") ? 0.1 : 1.0) : 1.0)
                                    .blur(radius: dissolvingChars.contains("\(lineIndex)-\(charIndex)") ? 5.0 : 0.0)
                                    .offset(x: dissolvingChars.contains("\(lineIndex)-\(charIndex)") ? Double.random(in: -30...30) : 0.0, 
                                           y: dissolvingChars.contains("\(lineIndex)-\(charIndex)") ? Double.random(in: -20...20) : 0.0)
                                    .rotationEffect(.degrees(dissolvingChars.contains("\(lineIndex)-\(charIndex)") ? Double.random(in: -25...25) : 0.0))
                                    .shadow(
                                        color: charColor.opacity(dissolvingChars.contains("\(lineIndex)-\(charIndex)") ? 0.5 : 0.0),
                                        radius: dissolvingChars.contains("\(lineIndex)-\(charIndex)") ? 8 : 0
                                    )
                                    .animation(.easeInOut(duration: dissolveDuration), value: dissolvingChars.contains("\(lineIndex)-\(charIndex)"))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .multilineTextAlignment(.leading)
                .lineSpacing(6)
                .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                .opacity(showFullText ? 1.0 : 0.0)
                .scaleEffect(showFullText ? 1.0 : 0.95)
                .animation(.easeInOut(duration: 1.2), value: showFullText)
                    .allowsHitTesting(false)
                
                // Meditation text below
                if showFullText {
                    Text("Close your eyes and imagine it being removed")
                        .font(.system(size: 16, weight: .light, design: .rounded))
                        .foregroundColor(charColor.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                        .padding(.top, CalmDesignSystem.Spacing.lg)
                        .opacity(showFullText ? 1.0 : 0.0)
                        .scaleEffect(showFullText ? 1.0 : 0.9)
                        .animation(.easeInOut(duration: 1.5).delay(1.0), value: showFullText)
                        .opacity(isDissolving ? 0.0 : 1.0)
                        .blur(radius: isDissolving ? 3.0 : 0.0)
                        .allowsHitTesting(false)
                }
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
        
        // Dissolve characters one by one sequentially across all lines
        var charIndex = 0
        for (lineIndex, line) in createTextLines().enumerated() {
            for (charPos, _) in line.enumerated() {
                let delay = Double(charIndex) * 0.08 // 0.08s delay between characters
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeInOut(duration: dissolveDuration)) {
                        _ = dissolvingChars.insert("\(lineIndex)-\(charPos)")
                    }
                }
                charIndex += 1
            }
        }
        
        // Complete after all characters have started dissolving
        let totalChars = createTextLines().flatMap { $0 }.count
        let totalDissolveTime = Double(totalChars) * 0.08 + dissolveDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDissolveTime) {
            allCharactersDissolved = true
            onComplete()
        }
    }
    
    private func createTextLines() -> [[Character]] {
        let words = text.components(separatedBy: .whitespaces)
        var lines: [[Character]] = []
        var currentLine: [Character] = []
        
        for word in words {
            let wordChars = Array(word)
            
            // Check if adding this word would exceed line length (approximately 40 characters per line for better wrapping)
            if currentLine.count + wordChars.count + 1 > 40 && !currentLine.isEmpty {
                lines.append(currentLine)
                currentLine = wordChars
            } else {
                if !currentLine.isEmpty {
                    currentLine.append(" ") // Add space between words
                }
                currentLine.append(contentsOf: wordChars)
            }
        }
        
        if !currentLine.isEmpty {
            lines.append(currentLine)
        }
        
        return lines
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