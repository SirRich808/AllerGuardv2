import Foundation
import AVFoundation
import Photos

#if os(iOS)
import UIKit
#endif

// Import the file containing the protocol definitions
import SwiftUI

// Define the necessary types locally if they can't be imported
// Permission status
enum PermissionStatus: String {
    case notDetermined = "Not Determined"
    case denied = "Denied"
    case restricted = "Restricted"
    case authorized = "Authorized"
    case limited = "Limited"
}

// Permission service protocol
protocol PermissionServiceProtocol {
    /// The current camera permission status
    var cameraPermissionStatus: PermissionStatus { get }
    
    /// The current photo library permission status
    var photoLibraryPermissionStatus: PermissionStatus { get }
    
    /// Requests camera permission
    /// - Returns: The updated permission status
    func requestCameraPermission() async -> PermissionStatus
    
    /// Requests photo library permission
    /// - Returns: The updated permission status
    func requestPhotoLibraryPermission() async -> PermissionStatus
    
    /// Opens the app settings
    func openAppSettings()
}

/// Service for handling permissions
final class PermissionService {
    // MARK: - Properties
    
    /// The current camera permission status
    var cameraPermissionStatus: PermissionStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        return permissionStatus(from: status)
    }
    
    /// The current photo library permission status
    var photoLibraryPermissionStatus: PermissionStatus {
        let status = PHPhotoLibrary.authorizationStatus()
        return permissionStatus(from: status)
    }
}

// MARK: - PermissionServiceProtocol Implementation
extension PermissionService: PermissionServiceProtocol {
    /// Requests camera permission
    /// - Returns: The updated permission status
    func requestCameraPermission() async -> PermissionStatus {
        let status = await AVCaptureDevice.requestAccess(for: .video)
        return status ? .authorized : .denied
    }
    
    /// Requests photo library permission
    /// - Returns: The updated permission status
    func requestPhotoLibraryPermission() async -> PermissionStatus {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        return permissionStatus(from: status)
    }
    
    /// Opens the app settings
    func openAppSettings() {
        #if os(iOS)
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
        #endif
    }
}

// MARK: - Private Methods
extension PermissionService {
    /// Converts an AVAuthorizationStatus to a PermissionStatus
    /// - Parameter status: The AVAuthorizationStatus to convert
    /// - Returns: The corresponding PermissionStatus
    private func permissionStatus(from status: AVAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        @unknown default:
            return .notDetermined
        }
    }
    
    /// Converts a PHAuthorizationStatus to a PermissionStatus
    /// - Parameter status: The PHAuthorizationStatus to convert
    /// - Returns: The corresponding PermissionStatus
    private func permissionStatus(from status: PHAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        case .limited:
            return .limited
        @unknown default:
            return .notDetermined
        }
    }
} 