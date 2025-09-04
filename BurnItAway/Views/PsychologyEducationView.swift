import SwiftUI

struct PsychologyEducationView: View {
    @State private var navigateToHome = false
    
    var body: some View {
        CalmBackground {
            ScrollView {
                VStack(spacing: CalmDesignSystem.Spacing.xl) {
                    // Header
                    VStack(spacing: CalmDesignSystem.Spacing.md) {
                        // Header spacing
                        Spacer()
                            .frame(height: 20)
                        
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 60))
                            .foregroundColor(.blue.opacity(0.8))
                        
                        Text("The Science Behind BurnItAway")
                            .font(CalmDesignSystem.Typography.largeTitle)
                            .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                            .accessibleText()
                        
                        Text("Evidence-based psychological techniques for worry release")
                            .font(CalmDesignSystem.Typography.subheadline)
                            .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .minimumScaleFactor(0.8)
                            .allowsTightening(true)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                    
                    // Main content
                    VStack(spacing: CalmDesignSystem.Spacing.xl) {
                        
                        // Symbolic Release Section
                        PsychologySection(
                            icon: "flame.fill",
                            iconColor: .orange,
                            title: "Symbolic Release Therapy",
                            content: """
                            The act of "burning" worries is based on Symbolic Release Therapy, a well-established psychological technique. Research shows that symbolic actions can create powerful psychological effects:
                            
                            • **Cognitive Disengagement**: Writing down worries and then symbolically destroying them helps the brain disengage from repetitive negative thoughts
                            
                            • **Emotional Processing**: The ritual provides a safe way to process and release difficult emotions
                            
                            • **Sense of Control**: The symbolic act gives users a sense of control over their worries
                            """,
                            sources: ["Pennebaker, J.W. (1997). Writing about emotional experiences", "Smyth, J.M. (1998). Written emotional expression"]
                        )
                        
                        // Writing Therapy Section
                        PsychologySection(
                            icon: "pencil.and.outline",
                            iconColor: .green,
                            title: "Expressive Writing Benefits",
                            content: """
                            The process of writing down worries before burning them is based on Expressive Writing Therapy:
                            
                            • **Emotional Regulation**: Writing about emotions helps regulate the amygdala (fear center) and activates the prefrontal cortex (rational thinking)
                            
                            • **Memory Reconsolidation**: The act of writing and then releasing can help "reconsolidate" traumatic or worrying memories in a less distressing way
                            
                            • **Sleep Improvement**: Studies show expressive writing before bed can improve sleep quality by reducing cognitive arousal
                            """,
                            sources: ["Pennebaker & Chung (2007). Expressive writing", "Harvey et al. (2005). Sleep and emotional processing"]
                        )
                        
                        // Ritual and Mindfulness Section
                        PsychologySection(
                            icon: "leaf.fill",
                            iconColor: .mint,
                            title: "Ritual and Mindfulness",
                            content: """
                            The burning ritual incorporates elements of mindfulness and therapeutic ritual:
                            
                            • **Present Moment Awareness**: The visual and tactile experience of the burning animation keeps users focused on the present moment
                            
                            • **Ritual Psychology**: Anthropological research shows that rituals help people process transitions and difficult emotions
                            
                            • **Sensory Grounding**: The visual effects and haptic feedback provide sensory grounding, which is effective for anxiety management
                            """,
                            sources: ["Hobson et al. (2018). The psychology of rituals", "Kabat-Zinn (2003). Mindfulness-based interventions"]
                        )
                        
                        // Sleep and Anxiety Section
                        PsychologySection(
                            icon: "moon.stars.fill",
                            iconColor: .purple,
                            title: "Sleep and Anxiety Management",
                            content: """
                            BurnItAway is specifically designed for nighttime anxiety, based on sleep research:
                            
                            • **Pre-Sleep Worry Processing**: Research shows that processing worries before bed reduces sleep latency and improves sleep quality
                            
                            • **Cognitive Load Reduction**: The ritual helps "empty" the mind of racing thoughts that interfere with sleep
                            
                            • **Relaxation Response**: The calming visual effects and breathing-like animations can trigger the parasympathetic nervous system
                            """,
                            sources: ["Harvey (2002). A cognitive model of insomnia", "Morin et al. (2006). Cognitive-behavioral therapy for insomnia"]
                        )
                        
                        // Disclaimer
                        VStack(spacing: CalmDesignSystem.Spacing.md) {
                            Text("Important Note")
                                .font(CalmDesignSystem.Typography.headline)
                                .foregroundColor(CalmDesignSystem.Colors.warning)
                            
                            Text("BurnItAway is designed as a complementary tool for managing everyday worries and anxiety. It is not a substitute for professional mental health treatment. If you're experiencing severe anxiety, depression, or other mental health concerns, please consult with a qualified mental health professional.")
                                .font(CalmDesignSystem.Typography.body)
                                .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .minimumScaleFactor(0.8)
                                .allowsTightening(true)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(CalmDesignSystem.Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                                .fill(CalmDesignSystem.Colors.warning.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                                        .stroke(CalmDesignSystem.Colors.warning.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                }
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationDestination(isPresented: $navigateToHome) { SettingsView() }
        .preferredColorScheme(.dark)
    }
}

struct PsychologySection: View {
    let icon: String
    let iconColor: Color
    let title: String
    let content: String
    let sources: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: CalmDesignSystem.Spacing.md) {
            HStack(alignment: .top, spacing: CalmDesignSystem.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(iconColor)
                
                Text(title)
                    .font(CalmDesignSystem.Typography.headline)
                    .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .allowsTightening(true)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Text(content)
                .font(CalmDesignSystem.Typography.body)
                .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                .lineSpacing(4)
                .lineLimit(nil)
                .minimumScaleFactor(0.8)
                .allowsTightening(true)
                .fixedSize(horizontal: false, vertical: true)
            
            if !sources.isEmpty {
                VStack(alignment: .leading, spacing: CalmDesignSystem.Spacing.xs) {
                    Text("Research Sources:")
                        .font(CalmDesignSystem.Typography.caption)
                        .foregroundColor(CalmDesignSystem.Colors.textTertiary)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .allowsTightening(true)
                    
                    ForEach(sources, id: \.self) { source in
                        Text("• \(source)")
                            .font(CalmDesignSystem.Typography.caption)
                            .foregroundColor(CalmDesignSystem.Colors.textTertiary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                            .allowsTightening(true)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
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
    PsychologyEducationView()
}
