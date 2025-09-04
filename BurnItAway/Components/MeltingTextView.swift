//
//  MeltingTextView.swift
//  BurnItAway
//
//  Created by Vaibhav Parashar on 9/1/25.
//

import SwiftUI

// MARK: - Fading Letter Model
struct FadingLetter: Identifiable {
    let id = UUID()
    let character: Character
    var opacity: Double
    var isFading: Bool
    var fadeStartTime: Date?
    
    init(character: Character) {
        self.character = character
        self.opacity = 1.0
        self.isFading = false
        self.fadeStartTime = nil
    }
}

// MARK: - Simple Fading Text View
struct MeltingTextView: View {
    let text: String
    let ritualType: String
    let onComplete: () -> Void
    
    @State private var letters: [FadingLetter] = []
    @State private var currentLetterIndex = 0
    @State private var allLettersFaded = false
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(letters) { letter in
                Text(String(letter.character))
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
                    .opacity(letter.opacity)
                    .animation(.easeOut(duration: 2.0), value: letter.opacity)
            }
        }
        .onAppear {
            setupLetters()
            startFadingAnimation()
        }
    }
    
    private func setupLetters() {
        letters = text.map { char in
            FadingLetter(character: char)
        }
    }
    
    private func startFadingAnimation() {
        // Start fading letters sequentially
        fadeNextLetter()
    }
    
    private func fadeNextLetter() {
        guard currentLetterIndex < letters.count else {
            // All letters started fading, wait for completion
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                onComplete()
            }
            return
        }
        
        // Start fading current letter
        letters[currentLetterIndex].isFading = true
        letters[currentLetterIndex].fadeStartTime = Date()
        
        // Fade the letter completely
        withAnimation(.easeOut(duration: 2.0)) {
            letters[currentLetterIndex].opacity = 0.0
        }
        
        // Move to next letter with delay
        currentLetterIndex += 1
        let delay = Double.random(in: 0.2...0.6)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            fadeNextLetter()
        }
    }
}

#Preview {
    MeltingTextView(
        text: "Burn Away",
        ritualType: "fire",
        onComplete: {}
    )
    .background(Color.black)
}
