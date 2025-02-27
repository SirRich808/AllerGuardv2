import SwiftUI
import AVFoundation
import Combine

/// View for the camera screen
struct CameraView: View {
    // MARK: - Properties
    
    /// The view model
    @StateObject private var viewModel: CameraViewModel
    
    /// Whether the results sheet is presented
    @State private var isResultsPresented = false
    
    // MARK: - Initialization
    
    /// Initializes a new camera view
    /// - Parameter viewModel: The view model
    init(viewModel: CameraViewModel? = nil) {
        // If a view model is provided, use it; otherwise, create a new one
        // using dependency injection from the service registry
        let resolvedViewModel: CameraViewModel
        if let vm = viewModel {
            resolvedViewModel = vm
        } else {
            // Create a mock view model for now
            // In a real implementation, we would resolve services from the registry
            resolvedViewModel = CameraViewModel.createMock()
        }
        
        // Use the _StateObject initializer to set the view model
        _viewModel = StateObject(wrappedValue: resolvedViewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Camera preview
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Camera controls
            VStack {
                Spacer()
                
                // Bottom controls
                HStack {
                    // Switch camera button
                    Button(action: {
                        Task {
                            await viewModel.switchCamera()
                        }
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Capture button
                    Button(action: {
                        Task {
                            await viewModel.capturePhoto()
                            isResultsPresented = true
                        }
                    }) {
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 60, height: 60)
                            )
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Settings button
                    Button(action: {
                        // Show settings
                    }) {
                        Image(systemName: "gear")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                    .padding()
                }
                .padding(.bottom)
            }
            
            // Processing overlay
            if viewModel.isProcessing {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(2)
                    )
            }
            
            // Error overlay
            if let error = viewModel.error {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        VStack {
                            Text("Camera Error")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.bottom, 8)
                            
                            Text(error.localizedDescription)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .padding(.bottom, 16)
                            
                            Button("Try Again") {
                                Task {
                                    await viewModel.setupCamera()
                                }
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.gray.opacity(0.8)))
                        .padding()
                    )
            }
        }
        .onAppear {
            // Set up the camera when the view appears
            Task {
                await viewModel.setupCamera()
            }
        }
        .onDisappear {
            // Stop the camera when the view disappears
            Task {
                await viewModel.stopCamera()
            }
        }
        .sheet(isPresented: $isResultsPresented) {
            // Results view
            ScanResultsView(
                image: viewModel.capturedImage,
                recognizedText: viewModel.recognizedText,
                detectedAllergens: viewModel.detectedAllergens,
                onDismiss: {
                    isResultsPresented = false
                    viewModel.clearCapture()
                }
            )
        }
    }
}

/// View for displaying scan results
struct ScanResultsView: View {
    // MARK: - Properties
    
    /// The captured image
    let image: Image?
    
    /// The recognized text
    let recognizedText: String
    
    /// The detected allergens
    let detectedAllergens: [AllergenMatch]
    
    /// Callback for when the view is dismissed
    let onDismiss: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Image
                    if let image = image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    
                    // Allergen results
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Detected Allergens")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if detectedAllergens.isEmpty {
                            Text("No allergens detected")
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        } else {
                            ForEach(detectedAllergens) { allergen in
                                AllergenMatchView(match: allergen)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Recognized text
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recognized Text")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if recognizedText.isEmpty {
                            Text("No text recognized")
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        } else {
                            Text(recognizedText)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.1)))
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Scan Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        onDismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Save the scan results
                        onDismiss()
                    }
                }
            }
        }
    }
}

/// View for displaying an allergen match
struct AllergenMatchView: View {
    // MARK: - Properties
    
    /// The allergen match
    let match: AllergenMatch
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            // Allergen icon
            Image(systemName: match.allergen.iconName)
                .font(.system(size: 24))
                .foregroundColor(match.sensitivityLevel?.color ?? .orange)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.gray.opacity(0.1)))
            
            VStack(alignment: .leading, spacing: 4) {
                // Allergen name
                Text(match.allergen.name)
                    .font(.headline)
                
                // Matched text
                Text("Found in: \(match.matchedText)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Sensitivity level
            if let sensitivity = match.sensitivityLevel {
                Text(sensitivity.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(sensitivity.color.opacity(0.2)))
                    .foregroundColor(sensitivity.color)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.1)))
    }
}

// MARK: - Previews

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
} 