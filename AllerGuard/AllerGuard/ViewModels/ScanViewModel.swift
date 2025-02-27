import Foundation
import SwiftUI
import Combine

/// View model for the scanning screen
final class ScanViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// Whether the camera is currently active
    @Published var isCameraActive = false
    
    // MARK: - Initialization
    
    init() {
        // Initialize the view model
    }
    
    // MARK: - Public Methods
    
    /// Starts a new scan
    func startScan() {
        // Set camera active
        isCameraActive = true
    }
    
    /// Cancels the current scan
    func cancelScan() {
        // Set camera inactive
        isCameraActive = false
    }
} 