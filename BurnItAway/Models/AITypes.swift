import Foundation

// MARK: - Shared AI Types

struct BreathingRecommendation {
    let inhale: Int
    let hold: Int
    let exhale: Int
    let cycles: Int
    let description: String
}

enum EngagementType {
    case shown
    case shared
    case longView // User stayed on screen for extended time
    case liked
}
