import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showMainApp = false
    
    private let pages = [
        OnboardingPage(
            icon: "flame.fill",
            title: "Welcome to BurnItAway",
            subtitle: "Release your worries through fire",
            description: "A therapeutic app that helps you let go of anxiety and stress through a calming fire ritual.",
            color: CalmDesignSystem.Colors.primary
        ),
        OnboardingPage(
            icon: "brain.head.profile",
            title: "The Science of Release",
            subtitle: "Based on proven psychology",
            description: "Writing down worries and watching them burn creates powerful psychological release and helps you externalize your concerns.",
            color: CalmDesignSystem.Colors.secondary
        ),
        OnboardingPage(
            icon: "hand.tap.fill",
            title: "How It Works",
            subtitle: "Simple and effective",
            description: "1. Write your worry\n2. Watch it burn away\n3. Feel the release\n4. Rest and reflect",
            color: CalmDesignSystem.Colors.accent
        ),
        OnboardingPage(
            icon: "lock.shield.fill",
            title: "Your Privacy Matters",
            subtitle: "Completely private and secure",
            description: "Your worries are never saved or shared. Everything stays on your device, and no internet connection is required.",
            color: CalmDesignSystem.Colors.success
        ),
        OnboardingPage(
            icon: "exclamationmark.triangle.fill",
            title: "Important Notice",
            subtitle: "Wellness tool, not medical treatment",
            description: "This app is for relaxation and wellness only. It's not a medical device or therapy. Always consult healthcare providers for medical concerns.",
            color: CalmDesignSystem.Colors.warning
        )
    ]
    
    var body: some View {
        if showMainApp {
            ContentView()
        } else {
            CalmBackground {
                VStack(spacing: 0) {
                    // Page Content
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            OnboardingPageView(page: pages[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentPage)
                    
                    // Bottom Controls
                    VStack(spacing: CalmDesignSystem.Spacing.lg) {
                        // Page Indicators
                        HStack(spacing: CalmDesignSystem.Spacing.sm) {
                            ForEach(0..<pages.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentPage ? CalmDesignSystem.Colors.primary : CalmDesignSystem.Colors.textTertiary)
                                    .frame(width: 8, height: 8)
                                    .animation(.easeInOut, value: currentPage)
                            }
                        }
                        
                        // Action Buttons
                        HStack(spacing: CalmDesignSystem.Spacing.md) {
                            if currentPage > 0 {
                                Button("Back") {
                                    withAnimation(.easeInOut) {
                                        currentPage -= 1
                                    }
                                }
                                .buttonStyle(CalmSecondaryButtonStyle())
                            }
                            
                            Spacer()
                            
                            if currentPage < pages.count - 1 {
                                Button("Next") {
                                    withAnimation(.easeInOut) {
                                        currentPage += 1
                                    }
                                }
                                .buttonStyle(CalmPrimaryButtonStyle())
                            } else {
                                Button("Get Started") {
                                    withAnimation(.easeInOut) {
                                        showMainApp = true
                                    }
                                    // Mark onboarding as completed
                                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                                    // Notify app that onboarding is completed
                                    NotificationCenter.default.post(name: NSNotification.Name("OnboardingCompleted"), object: nil)
                                }
                                .buttonStyle(CalmPrimaryButtonStyle())
                            }
                        }
                        .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                    }
                    .padding(.bottom, CalmDesignSystem.Spacing.xxxl)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Onboarding Page Data
struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let color: Color
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: CalmDesignSystem.Spacing.xxl) {
            Spacer()
            
            // Icon
            Image(systemName: page.icon)
                .font(.system(size: 80, weight: .light))
                .foregroundColor(page.color)
                .scaleEffect(1.0)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: page.icon)
            
            // Content
            VStack(spacing: CalmDesignSystem.Spacing.lg) {
                Text(page.title)
                    .font(CalmDesignSystem.Typography.largeTitle)
                    .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .allowsTightening(true)
                
                Text(page.subtitle)
                    .font(CalmDesignSystem.Typography.title)
                    .foregroundColor(page.color)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .allowsTightening(true)
                
                Text(page.description)
                    .font(CalmDesignSystem.Typography.body)
                    .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, CalmDesignSystem.Spacing.lg)
            }
            
            Spacer()
        }
        .padding(.horizontal, CalmDesignSystem.Spacing.xl)
    }
}

#Preview {
    OnboardingView()
}
