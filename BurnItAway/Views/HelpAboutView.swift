import SwiftUI

struct HelpAboutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    
    var body: some View {
        CalmBackground {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: CalmDesignSystem.Spacing.lg) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, CalmDesignSystem.Spacing.lg)
                    
                    Text("About BurnItAway")
                        .font(CalmDesignSystem.Typography.largeTitle)
                        .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                
                // Content
                ScrollView {
                    VStack(spacing: CalmDesignSystem.Spacing.xl) {
                        // What is BurnItAway
                        HelpSection(
                            icon: "flame.fill",
                            title: "What is BurnItAway?",
                            content: "BurnItAway is a wellness app designed to help you release worries and anxiety through a calming fire ritual. Write down what's troubling you, then watch it symbolically burn away with beautiful animations.\n\nNote: This is a wellness tool for relaxation, not a medical treatment or therapy."
                        )
                        
                        // The Psychology
                        HelpSection(
                            icon: "brain.head.profile",
                            title: "The Psychology Behind It",
                            content: "This app is based on several proven psychological techniques:\n\n• Symbolic Release: Writing down worries and watching them 'burn' creates a powerful psychological release\n\n• Mindfulness Practice: The ritual encourages present-moment awareness and intentional letting go\n\n• Cognitive Reframing: The act of externalizing worries helps you see them as separate from yourself\n\n• Ritual Therapy: Structured rituals provide comfort and a sense of control during difficult times"
                        )
                        
                        // How to Use
                        HelpSection(
                            icon: "hand.tap.fill",
                            title: "How to Use",
                            content: "1. Write Your Worry: Tap 'Burn Your Thought' and write what's on your mind\n\n2. Watch It Burn: See your words transform into flames and ash particles\n\n3. Feel the Release: Take deep breaths as you watch your worry disappear\n\n4. Rest and Reflect: Use the calming completion message to center yourself"
                        )
                        
                        // Premium Features
                        HelpSection(
                            icon: "crown.fill",
                            title: "Premium Features",
                            content: "• Unlimited Rituals: No daily limits on worry release\n\n• Multiple Rituals: Choose from Burn, Smoke, Space, and Wash rituals\n\n• Photo Release: Symbolically release visual memories by transforming photos\n\n• Enhanced Experience: Priority support and advanced features"
                        )
                        
                        // Tips for Best Results
                        HelpSection(
                            icon: "lightbulb.fill",
                            title: "Tips for Best Results",
                            content: "• Use at Night: Many find this most helpful before bed\n\n• Be Specific: Write detailed worries rather than vague concerns\n\n• Take Your Time: Don't rush the burning animation\n\n• Practice Regularly: Use daily for maximum benefit\n\n• Combine with Breathing: Focus on slow, deep breaths during the ritual"
                        )
                        
                        // Privacy & Safety
                        HelpSection(
                            icon: "lock.shield.fill",
                            title: "Privacy & Safety",
                            content: "• Completely Private: Your worries are never saved or shared\n\n• Offline First: Works without internet connection\n\n• No Accounts: No registration or personal data required\n\n• Local Only: Everything stays on your device\n\n• Not Medical Advice: This app is for wellness, not therapy"
                        )
                        
                        // When to Seek Help
                        HelpSection(
                            icon: "heart.fill",
                            title: "When to Seek Professional Help",
                            content: "While BurnItAway can help with daily worries, please seek professional help if you experience:\n\n• Persistent anxiety or depression\n• Thoughts of self-harm\n• Difficulty functioning in daily life\n• Overwhelming stress or trauma\n\nCrisis Resources:\n• National Suicide Prevention Lifeline: 988\n• Crisis Text Line: Text HOME to 741741"
                        )
                        
                        // Important Disclaimer
                        HelpSection(
                            icon: "exclamationmark.triangle.fill",
                            title: "Important Disclaimer",
                            content: "BurnItAway is not a medical device, therapy, or treatment.\n\n• This app is for wellness and relaxation purposes only\n• It is not intended to diagnose, treat, cure, or prevent any medical condition\n• It does not replace professional medical advice, diagnosis, or treatment\n• Always consult with qualified healthcare providers for medical concerns\n• If you have serious mental health issues, please seek professional help\n• The app's effectiveness is not guaranteed and results may vary\n• Use at your own discretion and stop if it causes distress\n\nBy using this app, you acknowledge and agree to these terms."
                        )
                        
                        // Legal Links
                        VStack(spacing: CalmDesignSystem.Spacing.md) {
                            Button(action: {
                                if let url = URL(string: "https://paravaib.github.io/burnitaway-legal/privacy-policy.html") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack(spacing: CalmDesignSystem.Spacing.sm) {
                                    Image(systemName: "doc.text.fill")
                                        .font(.system(size: 20, weight: .medium))
                                    Text("Privacy Policy")
                                        .font(CalmDesignSystem.Typography.button)
                                }
                                .foregroundColor(CalmDesignSystem.Colors.primary)
                                .padding(CalmDesignSystem.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.md)
                                        .fill(CalmDesignSystem.Colors.primary.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.md)
                                                .stroke(CalmDesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .accessibilityLabel("View privacy policy")
                            .accessibilityHint("Opens privacy policy in web browser")
                            
                            Button(action: {
                                if let url = URL(string: "https://paravaib.github.io/burnitaway-legal/terms-of-service.html") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack(spacing: CalmDesignSystem.Spacing.sm) {
                                    Image(systemName: "doc.text.fill")
                                        .font(.system(size: 20, weight: .medium))
                                    Text("Terms of Service")
                                        .font(CalmDesignSystem.Typography.button)
                                }
                                .foregroundColor(CalmDesignSystem.Colors.primary)
                                .padding(CalmDesignSystem.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.md)
                                        .fill(CalmDesignSystem.Colors.primary.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.md)
                                                .stroke(CalmDesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .accessibilityLabel("View terms of service")
                            .accessibilityHint("Opens terms of service in web browser")
                            
                            Button(action: {
                                if let url = URL(string: "https://paravaib.github.io/burnitaway-legal/copyright.html") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack(spacing: CalmDesignSystem.Spacing.sm) {
                                    Image(systemName: "c.circle.fill")
                                        .font(.system(size: 20, weight: .medium))
                                    Text("Copyright")
                                        .font(CalmDesignSystem.Typography.button)
                                }
                                .foregroundColor(CalmDesignSystem.Colors.primary)
                                .padding(CalmDesignSystem.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.md)
                                        .fill(CalmDesignSystem.Colors.primary.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.md)
                                                .stroke(CalmDesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .accessibilityLabel("View copyright information")
                            .accessibilityHint("Opens copyright information in web browser")
                        }
                        .padding(CalmDesignSystem.Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                                .fill(CalmDesignSystem.Colors.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                                        .stroke(CalmDesignSystem.Colors.glassBorder, lineWidth: 1)
                                )
                        )
                        
                        // Review and Onboarding
                        VStack(spacing: CalmDesignSystem.Spacing.md) {
                            Button(action: {
                                ReviewManager.shared.forceRequestReview()
                            }) {
                                HStack(spacing: CalmDesignSystem.Spacing.sm) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 20, weight: .medium))
                                    Text("Rate BurnItAway")
                                        .font(CalmDesignSystem.Typography.button)
                                }
                                .foregroundColor(CalmDesignSystem.Colors.primary)
                                .padding(CalmDesignSystem.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.md)
                                        .fill(CalmDesignSystem.Colors.primary.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.md)
                                                .stroke(CalmDesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .accessibilityLabel("Rate the app")
                            .accessibilityHint("Opens the App Store rating dialog")
                            
                            Button(action: {
                                // Reset onboarding flag to show onboarding again
                                UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                                // Notify app to show onboarding
                                NotificationCenter.default.post(name: NSNotification.Name("ReplayOnboarding"), object: nil)
                                dismiss()
                            }) {
                                HStack(spacing: CalmDesignSystem.Spacing.sm) {
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 20, weight: .medium))
                                    Text("Replay Introduction")
                                        .font(CalmDesignSystem.Typography.button)
                                }
                                .foregroundColor(CalmDesignSystem.Colors.primary)
                                .padding(CalmDesignSystem.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.md)
                                        .fill(CalmDesignSystem.Colors.primary.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.md)
                                                .stroke(CalmDesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .accessibilityLabel("Replay the app introduction")
                            .accessibilityHint("Show the onboarding flow again to learn about the app")
                            
                            Text("Help us improve by rating the app or watch the introduction again")
                                .font(CalmDesignSystem.Typography.caption)
                                .foregroundColor(CalmDesignSystem.Colors.textTertiary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(CalmDesignSystem.Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                                .fill(CalmDesignSystem.Colors.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                                        .stroke(CalmDesignSystem.Colors.glassBorder, lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                    .padding(.bottom, CalmDesignSystem.Spacing.xxxl)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Help Section Component
struct HelpSection: View {
    let icon: String
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: CalmDesignSystem.Spacing.md) {
            HStack(spacing: CalmDesignSystem.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(CalmDesignSystem.Colors.primary)
                    .frame(width: 30)
                
                Text(title)
                    .font(CalmDesignSystem.Typography.headline)
                    .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                    .multilineTextAlignment(.leading)
            }
            
            Text(content)
                .font(CalmDesignSystem.Typography.body)
                .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
        }
        .padding(CalmDesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                .fill(CalmDesignSystem.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                        .stroke(CalmDesignSystem.Colors.glassBorder, lineWidth: 1)
                )
        )
    }
}

#Preview {
    HelpAboutView()
}
