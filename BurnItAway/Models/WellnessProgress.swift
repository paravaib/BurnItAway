import Foundation
import SwiftUI

// MARK: - Wellness Progress Model
class WellnessProgress: ObservableObject {
    @Published var totalRitualsCompleted: Int = 0
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var lastRitualDate: Date?
    @Published var totalWorriesReleased: Int = 0
    @Published var favoriteRitual: RitualType?
    @Published var achievements: [Achievement] = []
    @Published var dailyGoal: Int = 1
    @Published var todayRitualsCompleted: Int = 0
    
    // MARK: - Progress Tracking
    func completeRitual(_ ritual: RitualType) {
        let today = Calendar.current.startOfDay(for: Date())
        let lastDate = lastRitualDate.map { Calendar.current.startOfDay(for: $0) }
        
        // Update daily count
        if lastDate == today {
            todayRitualsCompleted += 1
        } else {
            todayRitualsCompleted = 1
        }
        
        // Update streak
        if lastDate == today {
            // Same day, maintain streak
        } else if lastDate == Calendar.current.date(byAdding: .day, value: -1, to: today) {
            // Consecutive day, increment streak
            currentStreak += 1
        } else {
            // Streak broken, reset
            currentStreak = 1
        }
        
        // Update longest streak
        longestStreak = max(longestStreak, currentStreak)
        
        // Update totals
        totalRitualsCompleted += 1
        totalWorriesReleased += 1
        lastRitualDate = Date()
        
        // Update favorite ritual
        updateFavoriteRitual(ritual)
        
        // Check for achievements
        checkAchievements()
        
        // Save progress
        saveProgress()
    }
    
    private func updateFavoriteRitual(_ ritual: RitualType) {
        // Simple logic - most used ritual becomes favorite
        // In a real app, you'd track usage counts
        favoriteRitual = ritual
    }
    
    private func checkAchievements() {
        let newAchievements = Achievement.allAchievements.filter { achievement in
            !achievements.contains(achievement) && achievement.isUnlocked(progress: self)
        }
        
        achievements.append(contentsOf: newAchievements)
    }
    
    private func saveProgress() {
        // In a real app, save to UserDefaults or Core Data
        UserDefaults.standard.set(totalRitualsCompleted, forKey: "totalRitualsCompleted")
        UserDefaults.standard.set(currentStreak, forKey: "currentStreak")
        UserDefaults.standard.set(longestStreak, forKey: "longestStreak")
        UserDefaults.standard.set(totalWorriesReleased, forKey: "totalWorriesReleased")
        UserDefaults.standard.set(lastRitualDate, forKey: "lastRitualDate")
    }
    
    func loadProgress() {
        totalRitualsCompleted = UserDefaults.standard.integer(forKey: "totalRitualsCompleted")
        currentStreak = UserDefaults.standard.integer(forKey: "currentStreak")
        longestStreak = UserDefaults.standard.integer(forKey: "longestStreak")
        totalWorriesReleased = UserDefaults.standard.integer(forKey: "totalWorriesReleased")
        lastRitualDate = UserDefaults.standard.object(forKey: "lastRitualDate") as? Date
    }
}

// MARK: - Achievement System
struct Achievement: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let description: String
    let emoji: String
    let color: Color
    let requirement: (WellnessProgress) -> Bool
    
    static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        lhs.title == rhs.title
    }
    
    func isUnlocked(progress: WellnessProgress) -> Bool {
        return requirement(progress)
    }
    
    static let allAchievements: [Achievement] = [
        Achievement(
            title: "First Release",
            description: "You've completed your first worry release ritual",
            emoji: "🌟",
            color: .yellow,
            requirement: { $0.totalRitualsCompleted >= 1 }
        ),
        Achievement(
            title: "Streak Master",
            description: "You've maintained a 7-day streak",
            emoji: "🔥",
            color: .orange,
            requirement: { $0.currentStreak >= 7 }
        ),
        Achievement(
            title: "Century Club",
            description: "You've released 100 worries",
            emoji: "💯",
            color: .purple,
            requirement: { $0.totalWorriesReleased >= 100 }
        ),
        Achievement(
            title: "Zen Master",
            description: "You've completed 30 days of rituals",
            emoji: "🧘‍♀️",
            color: .blue,
            requirement: { $0.totalRitualsCompleted >= 30 }
        ),
        Achievement(
            title: "Ritual Explorer",
            description: "You've tried all ritual types",
            emoji: "🌍",
            color: .green,
            requirement: { $0.totalRitualsCompleted >= 4 }
        )
    ]
}

// MARK: - Ritual Completion Feedback
struct RitualCompletionFeedback {
    let message: String
    let emoji: String
    let color: Color
    let hapticPattern: HapticPattern
    
    static func generateFeedback(for progress: WellnessProgress, ritual: RitualType) -> RitualCompletionFeedback {
        // Generate personalized feedback based on progress
        if progress.currentStreak >= 7 {
            return RitualCompletionFeedback(
                message: "Amazing! You're on a \(progress.currentStreak)-day streak! 🔥",
                emoji: "🔥",
                color: .orange,
                hapticPattern: .celebration
            )
        } else if progress.totalWorriesReleased >= 50 {
            return RitualCompletionFeedback(
                message: "Incredible! You've released \(progress.totalWorriesReleased) worries! 🌟",
                emoji: "🌟",
                color: .purple,
                hapticPattern: .success
            )
        } else if progress.currentStreak >= 3 {
            return RitualCompletionFeedback(
                message: "Great job! \(progress.currentStreak) days in a row! 💪",
                emoji: "💪",
                color: .blue,
                hapticPattern: .success
            )
        } else {
            return RitualCompletionFeedback(
                message: "Beautiful release! You're doing great! ✨",
                emoji: "✨",
                color: .green,
                hapticPattern: .light
            )
        }
    }
}

// MARK: - Haptic Feedback Patterns
enum HapticPattern {
    case light
    case medium
    case heavy
    case success
    case celebration
    
    func play() {
        switch self {
        case .light:
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        case .medium:
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        case .heavy:
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
        case .success:
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
        case .celebration:
            // Celebration pattern: success + heavy + light
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let heavyFeedback = UIImpactFeedbackGenerator(style: .heavy)
                heavyFeedback.impactOccurred()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let lightFeedback = UIImpactFeedbackGenerator(style: .light)
                lightFeedback.impactOccurred()
            }
        }
    }
}
