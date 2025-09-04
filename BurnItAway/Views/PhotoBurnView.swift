//
//  PhotoBurnView.swift
//  BurnItAway
//
//  Created by Vaibhav Parashar on 9/1/25.
//

import SwiftUI
import PhotosUI

struct PhotoBurnView: View {
    @EnvironmentObject var premium: PremiumState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImage: UIImage?
    @State private var showBurnAnimation = false
    @State private var showSubscriptionPaywall = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        CalmBackground {
            VStack(spacing: CalmDesignSystem.Spacing.xxl) {
                // Header
                VStack(spacing: CalmDesignSystem.Spacing.lg) {
                    // Header spacing
                    Spacer()
                        .frame(height: 20)
                    
                    Text("📸 Symbolic Memory Burning")
                        .font(CalmDesignSystem.Typography.largeTitle)
                        .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .allowsTightening(true)
                        .multilineTextAlignment(.center)
                    
                    Text("Release visual memories with fire animation. Your photos remain safe.")
                        .font(CalmDesignSystem.Typography.subheadline)
                        .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .minimumScaleFactor(0.7)
                        .allowsTightening(true)
                        .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                }
                
                Spacer()
                
                // Main content
                if !premium.isPremium {
                    // Premium required view
                    VStack(spacing: CalmDesignSystem.Spacing.xl) {
                        VStack(spacing: CalmDesignSystem.Spacing.lg) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 60))
                                .foregroundColor(CalmDesignSystem.Colors.accent)
                            
                            Text("Premium Feature")
                                .font(CalmDesignSystem.Typography.title)
                                .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                                .allowsTightening(true)
                                .multilineTextAlignment(.center)
                            
                            Text("Photo burning is a premium feature that allows you to symbolically release visual memories through fire.")
                                .font(CalmDesignSystem.Typography.body)
                                .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(4)
                                .minimumScaleFactor(0.7)
                                .allowsTightening(true)
                                .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                        }
                        
                        VStack(spacing: CalmDesignSystem.Spacing.lg) {
                            FeatureRow(
                                icon: "photo.fill",
                                title: "Visual Memory Release",
                                description: "Burn photos to symbolically let go of visual memories"
                            )
                            
                            FeatureRow(
                                icon: "flame.fill",
                                title: "Fire Animation",
                                description: "Watch your photo burn away with realistic fire effects"
                            )
                            
                            FeatureRow(
                                icon: "heart.fill",
                                title: "Symbolic Release",
                                description: "Photos remain safe while you symbolically release the memory"
                            )
                        }
                        .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                        
                        Button("Upgrade to Premium") {
                            showSubscriptionPaywall = true
                        }
                        .buttonStyle(CalmPrimaryButtonStyle())
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .allowsTightening(true)
                        .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                    }
                } else {
                    // Premium user view
                    VStack(spacing: CalmDesignSystem.Spacing.xl) {
                        if selectedImage == nil {
                            // Photo selection
                            VStack(spacing: CalmDesignSystem.Spacing.lg) {
                                Image(systemName: "photo.circle")
                                    .font(.system(size: 80))
                                    .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                                    .opacity(0.6)
                                
                                Text("Select a Memory to Burn")
                                    .font(CalmDesignSystem.Typography.headline)
                                    .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)
                                    .allowsTightening(true)
                                    .multilineTextAlignment(.center)
                                
                                Text("Choose a memory you want to symbolically release. This is a symbolic burning experience only.")
                                    .font(CalmDesignSystem.Typography.body)
                                    .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(3)
                                    .minimumScaleFactor(0.7)
                                    .allowsTightening(true)
                                    .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                                
                                PhotoPickerView(
                                    selectedImage: $selectedImage,
                                    isPresented: .constant(false)
                                ) { image in
                                    // Photo selected - start burn animation
                                    showBurnAnimation = true
                                }
                                .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                            }
                        } else {
                            // Photo preview and burn
                            VStack(spacing: CalmDesignSystem.Spacing.lg) {
                                Text("Selected Memory")
                                    .font(CalmDesignSystem.Typography.headline)
                                    .foregroundColor(CalmDesignSystem.Colors.textPrimary)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)
                                    .allowsTightening(true)
                                    .multilineTextAlignment(.center)
                                
                                // Photo preview
                                Image(uiImage: selectedImage!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: 250, maxHeight: 250)
                                    .clipShape(RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                                            .stroke(CalmDesignSystem.Colors.glassBorder, lineWidth: 2)
                                    )
                                
                                VStack(spacing: CalmDesignSystem.Spacing.md) {
                                    Text("⚠️ Final Warning")
                                        .font(CalmDesignSystem.Typography.headline)
                                        .foregroundColor(.red)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.8)
                                        .allowsTightening(true)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("This is a symbolic burning experience. Your photo will remain safe on your device.")
                                        .font(CalmDesignSystem.Typography.body)
                                        .foregroundColor(CalmDesignSystem.Colors.textSecondary)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(4)
                                        .minimumScaleFactor(0.7)
                                        .allowsTightening(true)
                                        .padding(.horizontal, CalmDesignSystem.Spacing.lg)
                                }
                                .padding(CalmDesignSystem.Spacing.lg)
                                .background(
                                    RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                                        .fill(Color.red.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                
                                HStack(spacing: CalmDesignSystem.Spacing.lg) {
                                    Button("Choose Different Memory") {
                                        HapticFeedback.light()
                                        selectedImage = nil
                                    }
                                    .buttonStyle(CalmSecondaryButtonStyle())
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)
                                    .allowsTightening(true)
                                    .accessibilityLabel("Choose different memory")
                                    .accessibilityHint("Double tap to select a different photo to burn")
                                    .accessibilityAddTraits(.isButton)
                                    
                                    Button("Burn This Memory") {
                                        HapticFeedback.medium()
                                        showBurnAnimation = true
                                    }
                                    .buttonStyle(CalmPrimaryButtonStyle(color: .red))
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)
                                    .allowsTightening(true)
                                    .accessibilityLabel("Burn this memory")
                                    .accessibilityHint("Double tap to start burning this memory. This action cannot be undone.")
                                    .accessibilityAddTraits(.isButton)
                                }
                                .padding(.horizontal, CalmDesignSystem.Spacing.xl)
                            }
                        }
                    }
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(false)
        .fullScreenCover(isPresented: $showBurnAnimation) {
            PhotoBurnAnimation(
                image: selectedImage,
                onComplete: {
                    showBurnAnimation = false
                    // Reset for next use
                    selectedImage = nil
                    // Go back to main home screen
                    dismiss()
                }
            )
            .ignoresSafeArea(.all)
        }
        .sheet(isPresented: $showSubscriptionPaywall) {
            SubscriptionPaywallView()
        }

        .alert("Photo Access Required", isPresented: $showError) {
            Button("Open Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    

}

#Preview {
    NavigationStack {
        PhotoBurnView()
            .environmentObject(PremiumState())
    }
}
