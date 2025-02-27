import Foundation
import SwiftUI

/// Constants used throughout the app
enum AppConstants {
    /// App information
    static let appName = "AllerGuard"
    static let appVersion = "1.0.0"
    
    /// Feature flags
    static let enableDebugLogging = true
    
    /// UI Constants
    enum UI {
        static let cornerRadius: CGFloat = 10
        static let standardPadding: CGFloat = 16
        static let buttonHeight: CGFloat = 50
    }
    
    /// Error messages
    enum ErrorMessages {
        static let cameraPermissionDenied = "Camera access is required to scan food labels. Please enable camera access in Settings."
        static let scanningFailed = "Failed to scan the food label. Please try again."
        static let allergenDetectionFailed = "Failed to detect allergens. Please try again."
    }
} 