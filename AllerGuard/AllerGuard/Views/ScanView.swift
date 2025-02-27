import SwiftUI
import AVFoundation

/// View for scanning restaurant menus
struct ScanView: View {
    // MARK: - Properties
    
    /// View model for scan functionality
    @StateObject private var viewModel = ScanViewModel()
    
    /// Whether to show the camera permission alert
    @State private var showPermissionAlert = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main content
                VStack {
                    // Camera preview
                    ZStack {
                        // Camera preview placeholder
                        Rectangle()
                            .fill(Color.black)
                            .aspectRatio(3/4, contentMode: .fit)
                            .overlay(
                                Group {
                                    if viewModel.isScanning {
                                        // Show progress indicator when scanning
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(2)
                                    } else {
                                        // Show camera icon when not scanning
                                        Image(systemName: "camera.viewfinder")
                                            .resizable()
                                            .scaledToFit()
                                            .padding(80)
                                            .foregroundColor(.white.opacity(0.3))
                                    }
                                }
                            )
                        
                        // TODO: Replace with actual camera preview
                        // CameraPreviewView(session: viewModel.cameraService.captureSession)
                    }
                    .cornerRadius(12)
                    .padding()
                    
                    // Scan button
                    Button(action: {
                        viewModel.scanMenu()
                    }) {
                        HStack {
                            Image(systemName: "doc.text.viewfinder")
                            Text("Scan Menu")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .disabled(viewModel.isScanning)
                    
                    Spacer()
                }
                
                // Alert overlay
                if let alertItem = viewModel.alertItem {
                    AlertOverlayView(alertItem: alertItem) {
                        // Dismiss action
                        viewModel.alertItem = nil
                    }
                }
            }
            .navigationTitle("Menu Scanner")
            .alert(isPresented: $showPermissionAlert) {
                Alert(
                    title: Text("Camera Access Required"),
                    message: Text("AllerGuard needs camera access to scan menus. Please enable it in Settings."),
                    primaryButton: .default(Text("Settings"), action: {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }),
                    secondaryButton: .cancel()
                )
            }
            .onAppear {
                // Check camera permissions when view appears
                checkCameraPermissions()
            }
        }
    }
    
    // MARK: - Methods
    
    /// Check camera permissions and request if needed
    private func checkCameraPermissions() {
        Task {
            if !viewModel.cameraService.isCameraAuthorized {
                let authorized = await viewModel.cameraService.requestCameraAuthorization()
                if !authorized {
                    await MainActor.run {
                        showPermissionAlert = true
                    }
                }
            }
        }
    }
}

/// Overlay view for displaying alerts
struct AlertOverlayView: View {
    // MARK: - Properties
    
    /// Alert item to display
    let alertItem: AlertItem
    
    /// Action to perform when dismissed
    let dismissAction: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    dismissAction()
                }
            
            // Alert content
            VStack(spacing: 20) {
                // Icon
                Image(systemName: alertItem.isCritical ? "exclamationmark.triangle.fill" : "info.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(alertItem.isCritical ? .red : .blue)
                
                // Title
                Text(alertItem.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                // Message
                Text(alertItem.message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                
                // Recovery suggestion
                if let recoverySuggestion = alertItem.recoverySuggestion {
                    Text(recoverySuggestion)
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Dismiss button
                Button(action: {
                    dismissAction()
                }) {
                    Text("Dismiss")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .shadow(radius: 10)
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - Preview

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
} 