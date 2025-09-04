//
//  RitualTypes.swift
//  BurnItAway
//
//  Created by Vaibhav Parashar on 9/4/25.
//

import SwiftUI

// MARK: - Ritual Types
enum RitualType: String, CaseIterable, Identifiable, Hashable {
    case burn = "burn"
    case smoke = "smoke"
    case space = "space"
    case wash = "wash"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .burn: return "Burn"
        case .smoke: return "Smoke"
        case .space: return "Space"
        case .wash: return "Wash"
        }
    }
    
    var emoji: String {
        switch self {
        case .burn: return "🔥"
        case .smoke: return "💨"
        case .space: return "🌌"
        case .wash: return "💧"
        }
    }
    
    var description: String {
        switch self {
        case .burn: return "Watch your worries burn away with fire"
        case .smoke: return "See your thoughts dissolve into gentle smoke and float away"
        case .space: return "Release your worries into the infinite cosmos"
        case .wash: return "Wash away your troubles with water"
        }
    }
    
    var isPremium: Bool {
        switch self {
        case .burn: return false
        case .smoke, .space, .wash: return true
        }
    }
    
    var color: Color {
        switch self {
        case .burn: return .orange
        case .smoke: return .gray
        case .space: return .purple
        case .wash: return .blue
        }
    }
    
    var calmColor: Color {
        switch self {
        case .burn: return CalmDesignSystem.Colors.fireOrange
        case .smoke: return Color(red: 0.6, green: 0.6, blue: 0.6) // Soft gray
        case .space: return Color(red: 0.5, green: 0.3, blue: 0.8) // Cosmic purple
        case .wash: return Color(red: 0.3, green: 0.6, blue: 0.8) // Water blue
        }
    }
}

// MARK: - Ritual Animation State
class RitualAnimationState: ObservableObject {
    @Published var isAnimating = false
    @Published var progress: Double = 0.0
    @Published var phase: String = "preparing"
    @Published var showCompletion = false
    
    func startAnimation() {
        isAnimating = true
        progress = 0.0
        phase = "starting"
    }
    
    func updateProgress(_ newProgress: Double) {
        progress = newProgress
    }
    
    func setPhase(_ newPhase: String) {
        phase = newPhase
    }
    
    func completeAnimation() {
        progress = 1.0
        phase = "completed"
        showCompletion = true
    }
    
    func reset() {
        isAnimating = false
        progress = 0.0
        phase = "preparing"
        showCompletion = false
    }
}
