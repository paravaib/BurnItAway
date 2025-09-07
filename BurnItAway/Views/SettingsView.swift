import SwiftUI
import StoreKit

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var premium: PremiumState

    @State private var navigateToHome = false
    @State private var showSubscriptionPaywall = false
    
    var body: some View {
        CalmBackground {
            VStack(spacing: 0) {
                // Header spacing
                Spacer().frame(height: 20)
                
                Form {
                    PremiumSection(showSubscriptionPaywall: $showSubscriptionPaywall)
                    if !premium.isPremium {
                        DailyBurnSection()
                    }
                    AnimationSection()
                    ReminderSection(showSubscriptionPaywall: $showSubscriptionPaywall)
                    PsychologyNavigationSection()
                }
                .scrollContentBackground(.hidden)
                .onAppear {
                    // Initialize settings if needed
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarBackButtonHidden(false)
        .navigationDestination(isPresented: $navigateToHome) { ContentView() }
        .sheet(isPresented: $showSubscriptionPaywall) {
            SubscriptionPaywallView()
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Premium Section
struct PremiumSection: View {
    @EnvironmentObject var premium: PremiumState
    @Binding var showSubscriptionPaywall: Bool
    
    var body: some View {
        Section(header: Text("Premium").foregroundColor(.white)) {
            if premium.isPremium {
                VStack(spacing: CalmDesignSystem.Spacing.md) {
                    // Show trial status if in trial
                    if SubscriptionManager.shared.isInFreeTrial() {
                        TrialStatusView()
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Image(systemName: "checkmark.seal.fill").foregroundColor(.yellow)
                            Text("You have Premium").foregroundColor(.white)
                        }
                        Text("Unlimited Rituals + Photo Release")
                            .font(CalmDesignSystem.Typography.caption)
                            .foregroundColor(CalmDesignSystem.Colors.textTertiary)
                            .opacity(0.8)
                    }
                    
                    Button("Manage Subscription") {
                        openSubscriptionManagement()
                    }
                    .buttonStyle(CalmSecondaryButtonStyle())
                }
            } else {
                Button("Upgrade to Premium") { 
                    showSubscriptionPaywall = true 
                }
                .buttonStyle(CalmPrimaryButtonStyle(color: CalmDesignSystem.Colors.primary))
                
                Button("Restore Purchases") { 
                    Task {
                        await premium.restorePurchases()
                    }
                }
                .buttonStyle(CalmSecondaryButtonStyle())
            }
        }
        .listRowBackground(Color.white.opacity(0.06))
    }
    
    private func openSubscriptionManagement() {
        Task {
            do {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                    print("🔥 No window scene available")
                    return
                }
                try await AppStore.showManageSubscriptions(in: windowScene)
            } catch {
                print("🔥 Failed to open subscription management: \(error)")
            }
        }
    }
}


// MARK: - Animation Section
struct AnimationSection: View {
    var body: some View {
        Section(header: Text("Burn animation").foregroundColor(.white)) {
            HStack {
                Text("Fire").foregroundColor(.white)
                Spacer()
                Image(systemName: "flame.fill").foregroundColor(.orange)
            }
        }
        .listRowBackground(Color.white.opacity(0.06))
    }
}

// MARK: - Reminder Section
struct ReminderSection: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var premium: PremiumState
    @Binding var showSubscriptionPaywall: Bool
    
    var body: some View {
        Section(header: Text("Nightly reminder").foregroundColor(.white)) {
            Toggle("Remind me nightly", isOn: $appState.remindersOn)
                .tint(.green)
            
            DatePicker("Time", selection: $appState.reminderTime, displayedComponents: .hourAndMinute)
                .onChange(of: appState.reminderTime) { _ in
                    if appState.remindersOn { 
                        appState.scheduleAllReminders() 
                    }
                }
            
            if premium.isPremium {
                AdditionalRemindersView()
            } else {
                PremiumReminderLock(showSubscriptionPaywall: $showSubscriptionPaywall)
            }
        }
        .listRowBackground(Color.white.opacity(0.06))
    }
}

// MARK: - Additional Reminders View
struct AdditionalRemindersView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ForEach(appState.additionalReminders.indices, id: \.self) { idx in
            HStack {
                DatePicker(
                    "Extra #\(idx + 1)", 
                    selection: Binding(
                        get: { appState.additionalReminders[idx] }, 
                        set: { appState.additionalReminders[idx] = $0 }
                    ), 
                    displayedComponents: .hourAndMinute
                )
                
                Button(action: {
                    deleteReminder(at: idx)
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.system(size: 16, weight: .medium))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        
        Button("Add Reminder") {
            appState.additionalReminders.append(Date())
        }
        .buttonStyle(CalmSecondaryButtonStyle())
    }
    
    private func deleteReminder(at index: Int) {
        guard index < appState.additionalReminders.count else { return }
        appState.additionalReminders.remove(at: index)
    }
}

// MARK: - Premium Reminder Lock
struct PremiumReminderLock: View {
    @Binding var showSubscriptionPaywall: Bool
    
    var body: some View {
        HStack {
            Text("Additional reminders")
            Spacer()
            Image(systemName: "lock.fill").foregroundColor(.yellow)
            Text("Premium").foregroundColor(.yellow).font(.caption)
        }
        
        Button("Upgrade to add reminders") { 
            showSubscriptionPaywall = true 
        }
        .buttonStyle(CalmSecondaryButtonStyle())
    }
}

// MARK: - Psychology Navigation Section
struct PsychologyNavigationSection: View {
    var body: some View {
        Section(header: Text("The Science Behind BurnItAway").foregroundColor(.white)) {
            NavigationLink(destination: PsychologyEducationView()) {
                HStack {
                    Image(systemName: "brain.head.profile").foregroundColor(.blue)
                    Text("Learn About the Psychology").foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right").foregroundColor(.gray)
                }
            }
        }
        .listRowBackground(Color.white.opacity(0.06))
    }
}

// MARK: - Daily Burn Section
struct DailyBurnSection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Section(header: Text("Daily Burns").foregroundColor(.white)) {
            VStack(alignment: .leading, spacing: CalmDesignSystem.Spacing.sm) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("\(appState.getRemainingFreeBurns()) burns remaining today")
                        .font(CalmDesignSystem.Typography.callout)
                        .foregroundColor(.white)
                }
                
                Text("Your daily burn count resets at midnight every day")
                    .font(CalmDesignSystem.Typography.caption)
                    .foregroundColor(CalmDesignSystem.Colors.textTertiary)
                    .opacity(0.8)
                
                Text("✨ Premium: Unlimited burns + Photo burning")
                    .font(CalmDesignSystem.Typography.caption)
                    .foregroundColor(CalmDesignSystem.Colors.primary)
                    .opacity(0.9)
            }
            .padding(.vertical, CalmDesignSystem.Spacing.xs)
        }
        .listRowBackground(Color.white.opacity(0.06))
    }
}

#Preview {
    SettingsView().environmentObject(AppState()).environmentObject(PremiumState())
}
