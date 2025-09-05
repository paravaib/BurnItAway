//
//  PhotoPicker.swift
//  BurnItAway
//
//  Created by Vaibhav Parashar on 9/1/25.
//

import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onComplete: (Bool) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        init(_ parent: PhotoPicker) { self.parent = parent }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let result = results.first,
                  result.itemProvider.canLoadObject(ofClass: UIImage.self) else {
                parent.onComplete(false)
                return
            }
            let provider = result.itemProvider
            provider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    if let uiImage = image as? UIImage {
                        self.parent.image = uiImage
                        self.parent.onComplete(true)
                    } else {
                        self.parent.onComplete(false)
                    }
                }
            }
        }
    }
}

// MARK: - Simple Photo Picker (No Deletion)

// MARK: - Simple Photo Picker (No Deletion)
struct PhotoPickerView: View {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    let onImageSelected: (UIImage) -> Void // Simplified - no asset identifier needed
    
    @State private var showConfirmation = false
    @State private var tempImage: UIImage?
    @State private var showPicker = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "photo.fill")
                    .font(.system(size: 20, weight: .medium))
                Text("Select Memory to Burn")
                    .font(CalmDesignSystem.Typography.body)
            }
            .foregroundColor(CalmDesignSystem.Colors.textPrimary)
            .padding(CalmDesignSystem.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                    .fill(CalmDesignSystem.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: CalmDesignSystem.CornerRadius.lg)
                            .stroke(CalmDesignSystem.Colors.glassBorder, lineWidth: 1)
                    )
            )
            .onTapGesture {
                HapticFeedback.light()
                showPicker = true
            }
            .disabled(isLoading)
            .opacity(isLoading ? 0.6 : 1.0)
        }
        .sheet(isPresented: $showPicker) {
            PhotoPicker(
                image: $tempImage
            ) { success in
                if success, let image = tempImage {
                    HapticFeedback.light()
                    showConfirmation = true
                } else {
                    showError(message: "Failed to load the selected photo. Please try again.")
                }
                showPicker = false
            }
        }
        .confirmationDialog(
            "Confirm Photo Selection",
            isPresented: $showConfirmation,
            titleVisibility: .visible
        ) {
            Button("Burn This Memory") {
                if let image = tempImage {
                    HapticFeedback.medium()
                    selectedImage = image
                    onImageSelected(image)
                    isPresented = false
                }
            }
            .foregroundColor(.orange)
            .accessibilityLabel("Burn this memory")
            .accessibilityHint("Double tap to start burning this memory. Your photo will not be deleted.")
            
            Button("Cancel", role: .cancel) {
                HapticFeedback.light()
                tempImage = nil
            }
            .accessibilityLabel("Cancel photo selection")
        } message: {
            VStack(alignment: .leading, spacing: 8) {
                Text("🔥 SYMBOLIC BURNING")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                Text("Transform this memory into strength. You have the power to heal.")
                    .font(.body)
                
                Text("This is a therapeutic experience - no real deletion occurs.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
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


// MARK: - Usage Example
/*
 Usage in your view:
 
 @State private var selectedImage: UIImage?
 @State private var isPhotoPickerPresented = false
 
 PhotoPickerView(
     selectedImage: $selectedImage,
     isPresented: $isPhotoPickerPresented
 ) { image in
     // Start your burn animation here
     // Photo will not be deleted - this is symbolic burning only
 }
 */

#Preview {
    VStack {
        Text("Photo Picker Preview")
        PhotoPickerView(
            selectedImage: .constant(nil),
            isPresented: .constant(false)
        ) { image in
            print("Selected image: \(image)")
        }
    }
    .padding()
    .background(Color.black)
}
