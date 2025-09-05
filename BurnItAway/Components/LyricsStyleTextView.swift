//
//  LyricsStyleTextView.swift
//  BurnItAway
//
//  Created by Vaibhav Parashar on 9/4/25.
//

import SwiftUI

struct LyricsStyleTextView: View {
    let text: String
    let ritualType: String
    let onComplete: () -> Void
    
    @State private var words: [LyricsWord] = []
    @State private var currentWordIndex = 0
    @State private var isAnimating = false
    @State private var allWordsShown = false
    
    // Animation timing
    private let wordDelay: Double = 1.2 // Delay between words (slower for therapeutic effect)
    private let fadeInDuration: Double = 0.8
    private let holdDuration: Double = 0.6
    private let charDelay: Double = 0.08 // Delay between characters within a word
    
    var body: some View {
        VStack(spacing: CalmDesignSystem.Spacing.lg) {
            Spacer()
            
            // Lyrics text display
            VStack(spacing: CalmDesignSystem.Spacing.sm) {
                ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                    HStack {
                        ForEach(Array(word.characters.enumerated()), id: \.offset) { charIndex, char in
                            Text(String(char))
                                .font(.system(size: 32, weight: .medium, design: .rounded))
                                .foregroundColor(charColor(for: word, charIndex: charIndex))
                                .opacity(charOpacity(for: word, charIndex: charIndex))
                                .scaleEffect(charScale(for: word, charIndex: charIndex))
                                .shadow(
                                    color: charColor(for: word, charIndex: charIndex).opacity(0.5),
                                    radius: isHighlighted(char: char, word: word, charIndex: charIndex) ? 8 : 0
                                )
                                .animation(
                                    .easeInOut(duration: fadeInDuration)
                                    .delay(word.delay + Double(charIndex) * 0.05),
                                    value: word.isVisible
                                )
                        }
                    }
                    .opacity(word.isVisible ? 1.0 : 0.0)
                    .scaleEffect(word.isVisible ? 1.0 : 0.8)
                    .animation(
                        .easeInOut(duration: fadeInDuration)
                        .delay(word.delay),
                        value: word.isVisible
                    )
                }
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, CalmDesignSystem.Spacing.xl)
            
            Spacer()
        }
        .onAppear {
            setupWords()
            startLyricsAnimation()
        }
    }
    
    private func setupWords() {
        let wordStrings = text.components(separatedBy: .whitespaces)
        words = wordStrings.enumerated().map { index, word in
            LyricsWord(
                text: word,
                characters: Array(word),
                delay: Double(index) * wordDelay,
                isVisible: false
            )
        }
    }
    
    private func startLyricsAnimation() {
        guard !words.isEmpty else { return }
        
        isAnimating = true
        
        // Show words one by one with character-by-character highlighting
        for (wordIndex, _) in words.enumerated() {
            let wordStartTime = Double(wordIndex) * wordDelay
            
            // Show the word
            DispatchQueue.main.asyncAfter(deadline: .now() + wordStartTime) {
                withAnimation(.easeInOut(duration: fadeInDuration)) {
                    words[wordIndex].isVisible = true
                }
                
                // Animate character highlighting within the word
                self.animateCharacterHighlighting(for: wordIndex)
            }
        }
        
        // Mark as complete after all words are shown
        let totalDuration = Double(words.count) * wordDelay + fadeInDuration + holdDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            allWordsShown = true
            onComplete()
        }
    }
    
    private func animateCharacterHighlighting(for wordIndex: Int) {
        guard wordIndex < words.count else { return }
        
        let word = words[wordIndex]
        let characterCount = word.characters.count
        
        // Animate each character highlighting
        for (charIndex, _) in word.characters.enumerated() {
            let characterDelay = Double(charIndex) * charDelay
            
            DispatchQueue.main.asyncAfter(deadline: .now() + characterDelay) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    words[wordIndex].charProgress = Double(charIndex + 1) / Double(characterCount)
                }
            }
        }
    }
    
    private func charColor(for word: LyricsWord, charIndex: Int) -> Color {
        if !word.isVisible {
            return CalmDesignSystem.Colors.textSecondary.opacity(0.3)
        }
        
        // Character-by-character highlighting
        let charProgress = Double(charIndex) / Double(word.characters.count)
        let isHighlighted = charProgress <= word.charProgress
        
        if isHighlighted {
            return getRitualColor()
        } else {
            return CalmDesignSystem.Colors.textPrimary
        }
    }
    
    private func charOpacity(for word: LyricsWord, charIndex: Int) -> Double {
        if !word.isVisible {
            return 0.3
        }
        
        let charProgress = Double(charIndex) / Double(word.characters.count)
        let isHighlighted = charProgress <= word.charProgress
        
        if isHighlighted {
            return 1.0
        } else {
            return 0.7
        }
    }
    
    private func charScale(for word: LyricsWord, charIndex: Int) -> CGFloat {
        if !word.isVisible {
            return 0.8
        }
        
        let charProgress = Double(charIndex) / Double(word.characters.count)
        let isHighlighted = charProgress <= word.charProgress
        
        if isHighlighted {
            return 1.1
        } else {
            return 1.0
        }
    }
    
    private func isHighlighted(char: Character, word: LyricsWord, charIndex: Int) -> Bool {
        let charProgress = Double(charIndex) / Double(word.characters.count)
        return charProgress <= word.charProgress
    }
    
    private func getRitualColor() -> Color {
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
            return CalmDesignSystem.Colors.primary
        }
    }
}

// MARK: - Lyrics Word Model
struct LyricsWord: Identifiable {
    let id = UUID()
    let text: String
    let characters: [Character]
    let delay: Double
    var isVisible: Bool
    var charProgress: Double = 0.0
    
    init(text: String, characters: [Character], delay: Double, isVisible: Bool) {
        self.text = text
        self.characters = characters
        self.delay = delay
        self.isVisible = isVisible
    }
}

// MARK: - Preview
#Preview {
    LyricsStyleTextView(
        text: "I'm worried about my future and what tomorrow will bring",
        ritualType: "burn",
        onComplete: {}
    )
    .background(Color.black)
}
