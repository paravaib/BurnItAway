//
//  BurnItAwayApp.swift
//  BurnItAway
//
//  Created by Vaibhav Parashar on 9/1/25.
//

import SwiftUI

@main
struct BurnItAwayApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var premium = PremiumState()
    @State private var shouldShowOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    @State private var onboardingObserver: NSObjectProtocol?
    @State private var replayObserver: NSObjectProtocol?
    
    var body: some Scene {
        WindowGroup {
            Group {
                if shouldShowOnboarding {
                    OnboardingView()
                        .environmentObject(appState)
                        .environmentObject(premium)
                        .onAppear {
                            // Listen for onboarding completion
                            onboardingObserver = NotificationCenter.default.addObserver(
                                forName: NSNotification.Name("OnboardingCompleted"),
                                object: nil,
                                queue: .main
                            ) { _ in
                                shouldShowOnboarding = false
                            }
                        }
                        .onDisappear {
                            if let observer = onboardingObserver {
                                NotificationCenter.default.removeObserver(observer)
                            }
                        }
                } else {
                    ContentView()
                        .environmentObject(appState)
                        .environmentObject(premium)
                        .onAppear {
                            // Listen for replay onboarding request
                            replayObserver = NotificationCenter.default.addObserver(
                                forName: NSNotification.Name("ReplayOnboarding"),
                                object: nil,
                                queue: .main
                            ) { _ in
                                shouldShowOnboarding = true
                            }
                        }
                        .onDisappear {
                            if let observer = replayObserver {
                                NotificationCenter.default.removeObserver(observer)
                            }
                        }
                }
            }
        }
    }
}
