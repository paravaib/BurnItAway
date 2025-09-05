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
    @State private var dissolvingChars: Set<String> = []
    
    // Animation timing
    private let showDuration: Double = 4.0 // Show full text for 4 seconds
    private let dissolveDelay: Double = 0.08 // Delay between character dissolves
    private let dissolveDuration: Double = 2.0 // Duration for each character to dissolve
    
    var body: some View {
        VStack(spacing: CalmDesignSystem.Spacing.lg) {
            Spacer()
            
            // Full paragraph text display
            VStack(spacing: CalmDesignSystem.Spacing.md) {
                // Paragraph text with letter-by-letter dissolve
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
            }
            
            Spacer()
        }
        .onAppear {
            setupCharacters()
            startAnimation()
        }
    }
    
    private func setupCharacters() {
        let lines = createTextLines()
        characters = []
        
        for (lineIndex, line) in lines.enumerated() {
            for (charIndex, char) in line.enumerated() {
                characters.append(DissolveCharacter(
                    character: char,
                    lineIndex: lineIndex,
                    charIndex: charIndex,
                    opacity: 1.0,
                    scale: 1.0,
                    blur: 0.0,
                    offsetX: 0.0,
                    offsetY: 0.0,
                    rotation: 0.0,
                    isDissolving: false,
                    dissolveDelay: 0.0
                ))
            }
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
        for (lineIndex, line) in createTextLines().enumerated() {
            for (charIndex, _) in line.enumerated() {
                let delay = Double(lineIndex * 100 + charIndex) * dissolveDelay
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeInOut(duration: dissolveDuration)) {
                        dissolvingChars.insert("\(lineIndex)-\(charIndex)")
                    }
                }
            }
        }
        
        // Complete after all characters have started dissolving
        let totalChars = createTextLines().flatMap { $0 }.count
        let totalDissolveTime = Double(totalChars) * dissolveDelay + dissolveDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDissolveTime) {
            allCharactersDissolved = true
            onComplete()
        }
    }
    
    // MARK: - Character Property Helpers
    private func getCharData(lineIndex: Int, charIndex: Int) -> DissolveCharacter? {
        return characters.first(where: { $0.lineIndex == lineIndex && $0.charIndex == charIndex })
    }
    
    private func getCharOpacity(lineIndex: Int, charIndex: Int) -> Double {
        guard let charData = getCharData(lineIndex: lineIndex, charIndex: charIndex) else { return 1.0 }
        return charData.isDissolving ? charData.opacity : 1.0
    }
    
    private func getCharScale(lineIndex: Int, charIndex: Int) -> CGFloat {
        guard let charData = getCharData(lineIndex: lineIndex, charIndex: charIndex) else { return 1.0 }
        return charData.isDissolving ? charData.scale : 1.0
    }
    
    private func getCharBlur(lineIndex: Int, charIndex: Int) -> CGFloat {
        guard let charData = getCharData(lineIndex: lineIndex, charIndex: charIndex) else { return 0.0 }
        return charData.isDissolving ? charData.blur : 0.0
    }
    
    private func getCharOffsetX(lineIndex: Int, charIndex: Int) -> Double {
        guard let charData = getCharData(lineIndex: lineIndex, charIndex: charIndex) else { return 0.0 }
        return charData.isDissolving ? charData.offsetX : 0.0
    }
    
    private func getCharOffsetY(lineIndex: Int, charIndex: Int) -> Double {
        guard let charData = getCharData(lineIndex: lineIndex, charIndex: charIndex) else { return 0.0 }
        return charData.isDissolving ? charData.offsetY : 0.0
    }
    
    private func getCharRotation(lineIndex: Int, charIndex: Int) -> Double {
        guard let charData = getCharData(lineIndex: lineIndex, charIndex: charIndex) else { return 0.0 }
        return charData.isDissolving ? charData.rotation : 0.0
    }
    
    private func getCharIsDissolving(lineIndex: Int, charIndex: Int) -> Bool {
        guard let charData = getCharData(lineIndex: lineIndex, charIndex: charIndex) else { return false }
        return charData.isDissolving
    }
    
    private func getCharDissolveDelay(lineIndex: Int, charIndex: Int) -> Double {
        guard let charData = getCharData(lineIndex: lineIndex, charIndex: charIndex) else { return 0.0 }
        return charData.dissolveDelay
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
    let lineIndex: Int
    let charIndex: Int
    var opacity: Double
    var scale: CGFloat
    var blur: CGFloat
    var offsetX: Double
    var offsetY: Double
    var rotation: Double
    var isDissolving: Bool
    var dissolveDelay: Double
    
    init(character: Character, lineIndex: Int, charIndex: Int, opacity: Double = 1.0, scale: CGFloat = 1.0, blur: CGFloat = 0.0, offsetX: Double = 0.0, offsetY: Double = 0.0, rotation: Double = 0.0, isDissolving: Bool = false, dissolveDelay: Double = 0.0) {
        self.character = character
        self.lineIndex = lineIndex
        self.charIndex = charIndex
        self.opacity = opacity
        self.scale = scale
        self.blur = blur
        self.offsetX = offsetX
        self.offsetY = offsetY
        self.rotation = rotation
        self.isDissolving = isDissolving
        self.dissolveDelay = dissolveDelay
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
