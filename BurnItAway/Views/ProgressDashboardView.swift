import SwiftUI

struct ProgressDashboardView: View {
    @StateObject private var progress = WellnessProgress()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                // Progress Overview
                ProgressOverviewTab(progress: progress)
                    .tabItem {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("Progress")
                    }
                    .tag(0)
                
                // Achievements
                AchievementsTab(progress: progress)
                    .tabItem {
                        Image(systemName: "trophy.fill")
                        Text("Achievements")
                    }
                    .tag(1)
                
                // Insights
                InsightsTab(progress: progress)
                    .tabItem {
                        Image(systemName: "brain.head.profile")
                        Text("Insights")
                    }
                    .tag(2)
            }
            .accentColor(CalmDesignSystem.Colors.primary)
        }
        .onAppear {
            progress.loadProgress()
        }
    }
}

// MARK: - Progress Overview Tab
struct ProgressOverviewTab: View {
    @ObservedObject var progress: WellnessProgress
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Your Wellness Journey")
                        .font(CalmDesignSystem.Typography.largeTitle)
                        .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                    
                    Text("Keep up the amazing work!")
                        .font(CalmDesignSystem.Typography.body)
                        .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                }
                .padding(.top, 20)
                
                // Main Stats Cards
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    StatCard(
                        title: "Current Streak",
                        value: "\(progress.currentStreak)",
                        subtitle: "days",
                        color: .orange,
                        icon: "flame.fill"
                    )
                    
                    StatCard(
                        title: "Total Released",
                        value: "\(progress.totalWorriesReleased)",
                        subtitle: "worries",
                        color: .blue,
                        icon: "heart.fill"
                    )
                    
                    StatCard(
                        title: "Best Streak",
                        value: "\(progress.longestStreak)",
                        subtitle: "days",
                        color: .purple,
                        icon: "star.fill"
                    )
                    
                    StatCard(
                        title: "Total Rituals",
                        value: "\(progress.totalRitualsCompleted)",
                        subtitle: "completed",
                        color: .green,
                        icon: "checkmark.circle.fill"
                    )
                }
                
                // Streak Visualization
                StreakVisualizationView(progress: progress)
                
                // Daily Goal Progress
                DailyGoalView(progress: progress)
                
                // Motivational Message
                MotivationalMessageView(progress: progress)
            }
            .padding(.horizontal, 20)
        }
        .background(CalmDesignSystem.Colors.background)
    }
}

// MARK: - Achievements Tab
struct AchievementsTab: View {
    @ObservedObject var progress: WellnessProgress
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Achievements")
                        .font(CalmDesignSystem.Typography.largeTitle)
                        .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                    
                    Text("Celebrate your milestones!")
                        .font(CalmDesignSystem.Typography.body)
                        .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                }
                .padding(.top, 20)
                
                // Achievements Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(Achievement.allAchievements) { achievement in
                        AchievementCard(achievement: achievement, isUnlocked: progress.achievements.contains(achievement))
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .background(CalmDesignSystem.Colors.background)
    }
}

// MARK: - Insights Tab
struct InsightsTab: View {
    @ObservedObject var progress: WellnessProgress
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Insights")
                        .font(CalmDesignSystem.Typography.largeTitle)
                        .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                    
                    Text("Discover patterns in your wellness journey")
                        .font(CalmDesignSystem.Typography.body)
                        .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                }
                .padding(.top, 20)
                
                // Insights Cards
                VStack(spacing: 16) {
                    InsightCard(
                        title: "Consistency",
                        description: progress.currentStreak >= 7 ? "You're building an amazing habit!" : "Keep going to build a strong habit",
                        icon: "calendar",
                        color: .blue
                    )
                    
                    InsightCard(
                        title: "Progress",
                        description: "You've released \(progress.totalWorriesReleased) worries and counting!",
                        icon: "chart.line.uptrend.xyaxis",
                        color: .green
                    )
                    
                    InsightCard(
                        title: "Favorite Ritual",
                        description: progress.favoriteRitual != nil ? "You love the \(progress.favoriteRitual?.displayName ?? "Burn") ritual" : "Try different rituals to find your favorite",
                        icon: "heart.fill",
                        color: .purple
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .background(CalmDesignSystem.Colors.background)
    }
}

// MARK: - Supporting Views
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(CalmDesignSystem.Colors.textPrimary)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(CalmDesignSystem.Typography.caption)
                    .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(CalmDesignSystem.Colors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(CalmDesignSystem.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct StreakVisualizationView: View {
    @ObservedObject var progress: WellnessProgress
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Streak Progress")
                .font(CalmDesignSystem.Typography.headline)
                .foregroundColor(CalmDesignSystem.Colors.textPrimary)
            
            HStack(spacing: 8) {
                ForEach(0..<7, id: \.self) { day in
                    Circle()
                        .fill(day < progress.currentStreak ? Color.orange : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                        .scaleEffect(day < progress.currentStreak ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3), value: progress.currentStreak)
                }
                
                Spacer()
                
                Text("\(progress.currentStreak)/7")
                    .font(CalmDesignSystem.Typography.caption)
                    .foregroundColor(CalmDesignSystem.Colors.textSecondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(CalmDesignSystem.Colors.surface)
        )
    }
}

struct DailyGoalView: View {
    @ObservedObject var progress: WellnessProgress
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Goal")
                .font(CalmDesignSystem.Typography.headline)
                .foregroundColor(CalmDesignSystem.Colors.textPrimary)
            
            HStack {
                Text("\(progress.todayRitualsCompleted)/\(progress.dailyGoal)")
                    .font(CalmDesignSystem.Typography.title)
                    .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                
                Spacer()
                
                if progress.todayRitualsCompleted >= progress.dailyGoal {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }
            
            ProgressView(value: Double(progress.todayRitualsCompleted), total: Double(progress.dailyGoal))
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(CalmDesignSystem.Colors.surface)
        )
    }
}

struct MotivationalMessageView: View {
    @ObservedObject var progress: WellnessProgress
    
    var motivationalMessage: String {
        if progress.currentStreak >= 7 {
            return "You're on fire! 🔥 Your consistency is inspiring!"
        } else if progress.totalWorriesReleased >= 50 {
            return "Amazing progress! 🌟 You've released so many worries!"
        } else if progress.currentStreak >= 3 {
            return "Great job! 💪 You're building a wonderful habit!"
        } else {
            return "Every step counts! ✨ You're doing great!"
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Daily Motivation")
                .font(CalmDesignSystem.Typography.headline)
                .foregroundColor(CalmDesignSystem.Colors.textPrimary)
            
            Text(motivationalMessage)
                .font(CalmDesignSystem.Typography.body)
                .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(CalmDesignSystem.Colors.surface)
        )
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Text(achievement.emoji)
                .font(.system(size: 32))
                .opacity(isUnlocked ? 1.0 : 0.3)
            
            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(CalmDesignSystem.Typography.headline)
                    .foregroundColor(isUnlocked ? CalmDesignSystem.Colors.textPrimary : CalmDesignSystem.Colors.textTertiary)
                
                Text(achievement.description)
                    .font(CalmDesignSystem.Typography.caption)
                    .foregroundColor(isUnlocked ? CalmDesignSystem.Colors.textSecondary : CalmDesignSystem.Colors.textTertiary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isUnlocked ? achievement.color.opacity(0.1) : CalmDesignSystem.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isUnlocked ? achievement.color.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct InsightCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(color.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(CalmDesignSystem.Typography.headline)
                    .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                
                Text(description)
                    .font(CalmDesignSystem.Typography.body)
                    .foregroundColor(CalmDesignSystem.Colors.textSecondary)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(CalmDesignSystem.Colors.surface)
        )
    }
}

#Preview {
    ProgressDashboardView()
}
