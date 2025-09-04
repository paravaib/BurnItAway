import SwiftUI
import UserNotifications



enum Soundscape: String, CaseIterable, Identifiable {
    case fire
    
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .fire: return "Fire"
        }
    }
}

final class AppState: ObservableObject {
    // Lights off + quotes
    @Published var lightsOff: Bool = false {
        didSet {
            if lightsOff {
                refreshQuote()
                startQuoteTimer()
            } else {
                stopQuoteTimer()
            }
        }
    }
    @Published var quote: String = "Breathe in calm, breathe out worry."
    
    // AI Services
    private var recentWorries: [String] = []
    
    // Worry count tracking
    @Published var dailyWorryCount: Int = 0
    @Published var lastWorryDate: Date = Date()
    private let maxFreeWorriesPerDay = 7
    
    // Settings
    @Published var soundOn: Bool = true
    @Published var hapticsOn: Bool = true
    @Published var soundVolume: Double = 0.3 // 0.0...1.0

    @Published var soundscape: Soundscape = .fire
    
    // Nightly reminders
    @Published var remindersOn: Bool = false {
        didSet {
            if remindersOn {
                scheduleAllReminders()
            } else {
                cancelAllReminders()
            }
        }
    }
    @Published var reminderTime: Date = defaultReminderTime() { didSet { if remindersOn { scheduleAllReminders() } } }
    @Published var additionalReminders: [Date] = [] { didSet { if remindersOn { scheduleAllReminders() } } }
    
    // Internal
    private var quotesTimer: Timer?
    
    private let quotes: [String] = [
        "Breathe. You are exactly where you need to be.",
        "Let go of what you can’t control. Rest will come.",
        "In this moment, you are safe, you are enough.",
        "Slow is smooth, and smooth is restful.",
        "The night is for healing. You’re doing your best.",
        "Worries fade when kindness fills the space—start with yourself.",
        "You’ve made it through 100% of your hardest nights.",
        "Exhale the day. Tomorrow can carry its own weight.",
        "You are allowed to pause. Peace grows in the quiet.",
        "Tiny steps are still steps. Be gentle with yourself."
    ]
    
    init() {
        // Load recent worries from UserDefaults
        if let savedWorries = UserDefaults.standard.array(forKey: "recent_worries") as? [String] {
            self.recentWorries = savedWorries
        }
        
        // Load worry count data
        loadWorryCountData()
    }
    
    static func defaultReminderTime() -> Date {
        var comps = DateComponents()
        comps.hour = 22
        comps.minute = 0
        return Calendar.current.date(from: comps) ?? Date()
    }
    
    func refreshQuote() {
        // Select a random calming quote
        quote = quotes.randomElement() ?? "Breathe in calm, breathe out worry."
    }
    
    func addWorry(_ worryText: String, category: String = "general") {
        // Track worry for simple analysis
        recentWorries.append(worryText)
        
        // Keep only last 10 worries
        if recentWorries.count > 10 {
            recentWorries = Array(recentWorries.suffix(10))
        }
        
        // Save to UserDefaults
        UserDefaults.standard.set(recentWorries, forKey: "recent_worries")
    }
    
    // MARK: - Worry Count Management
    
    private func loadWorryCountData() {
        dailyWorryCount = UserDefaults.standard.integer(forKey: "daily_worry_count")
        
        if let savedDate = UserDefaults.standard.object(forKey: "last_worry_date") as? Date {
            lastWorryDate = savedDate
            
            // Reset count if it's a new day
            if !Calendar.current.isDate(lastWorryDate, inSameDayAs: Date()) {
                dailyWorryCount = 0
                saveWorryCountData()
            }
        }
    }
    
    private func saveWorryCountData() {
        UserDefaults.standard.set(dailyWorryCount, forKey: "daily_worry_count")
        UserDefaults.standard.set(lastWorryDate, forKey: "last_worry_date")
    }
    
    func canBurnWorry(isPremium: Bool) -> Bool {
        if isPremium {
            return true // Premium users have unlimited burns
        }
        
        // Check if it's a new day and reset count
        if !Calendar.current.isDate(lastWorryDate, inSameDayAs: Date()) {
            dailyWorryCount = 0
            lastWorryDate = Date()
            saveWorryCountData()
        }
        
        let canBurn = dailyWorryCount < maxFreeWorriesPerDay
        print("🔥 canBurnWorry: isPremium=\(isPremium), dailyWorryCount=\(dailyWorryCount), maxFree=\(maxFreeWorriesPerDay), canBurn=\(canBurn)")
        return canBurn
    }
    
    func getRemainingFreeBurns() -> Int {
        return max(0, maxFreeWorriesPerDay - dailyWorryCount)
    }
    
    func incrementWorryCount() {
        dailyWorryCount += 1
        lastWorryDate = Date()
        saveWorryCountData()
        print("🔥 incrementWorryCount: new count=\(dailyWorryCount)")
        
        // Request review after 3rd burn (user is engaged)
        if dailyWorryCount == 3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                ReviewManager.shared.requestReviewIfAppropriate()
            }
        }
    }
    
    private func startQuoteTimer() {
        stopQuoteTimer()
        quotesTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.refreshQuote()
        }
    }
    
    private func stopQuoteTimer() {
        quotesTimer?.invalidate()
        quotesTimer = nil
    }
    
    // MARK: - Notifications
    func requestNotificationPermissionIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus != .authorized else { return }
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        }
    }
    
    private func schedule(identifier: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Gentle reminder"
        content.body = "Time to release your worries and find peace"
        content.sound = .default
        
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
        dateComponents.second = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func scheduleAllReminders() {
        requestNotificationPermissionIfNeeded()
        cancelAllReminders()
        schedule(identifier: "nightly_reminder_base", date: reminderTime)
        for (idx, date) in additionalReminders.enumerated() {
            schedule(identifier: "nightly_reminder_extra_\(idx)", date: date)
        }
    }
    
    func cancelAllReminders() {
        var ids = ["nightly_reminder_base"]
        ids.append(contentsOf: additionalReminders.enumerated().map { "nightly_reminder_extra_\($0.offset)" })
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
}
