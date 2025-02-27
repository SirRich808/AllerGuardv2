import Foundation
import SwiftUI
import Combine
import AVFoundation

// MARK: - Camera Types
// This file centralizes camera-related type definitions for the AllerGuard app.
// To use these types in other files, simply import them at the top of the file.
// Since we're in the same module, no special import statement is needed.
// Example: Just use CameraPosition, CameraError, etc. directly after importing the standard libraries.

/// Camera position (front or back)
public enum CameraPosition {
    case front
    case back
}

/// Errors that can occur during camera operations
public enum CameraError: Error, LocalizedError, Identifiable {
    case accessDenied
    case deviceNotAvailable
    case setupFailed
    case inputNotSupported
    case outputNotSupported
    case sessionNotRunning
    case captureFailed
    case invalidPhotoData
    case serviceDeallocated
    case unknown
    
    public var id: UUID {
        UUID()
    }
    
    public var title: String {
        switch self {
        case .accessDenied:
            return "Camera Access Denied"
        case .deviceNotAvailable:
            return "Camera Not Available"
        case .setupFailed:
            return "Camera Setup Failed"
        case .inputNotSupported:
            return "Camera Input Not Supported"
        case .outputNotSupported:
            return "Camera Output Not Supported"
        case .sessionNotRunning:
            return "Camera Not Running"
        case .captureFailed:
            return "Photo Capture Failed"
        case .invalidPhotoData:
            return "Invalid Photo Data"
        case .serviceDeallocated:
            return "Camera Service Error"
        case .unknown:
            return "Unknown Camera Error"
        }
    }
    
    public var message: String {
        switch self {
        case .accessDenied:
            return "AllerGuard needs access to your camera to scan food labels."
        case .deviceNotAvailable:
            return "No camera device is available on this device."
        case .setupFailed:
            return "Failed to set up the camera."
        case .inputNotSupported:
            return "The camera input is not supported."
        case .outputNotSupported:
            return "The camera output is not supported."
        case .sessionNotRunning:
            return "The camera session is not running."
        case .captureFailed:
            return "Failed to capture a photo."
        case .invalidPhotoData:
            return "The captured photo data is invalid."
        case .serviceDeallocated:
            return "The camera service was deallocated during operation."
        case .unknown:
            return "An unknown camera error occurred."
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .accessDenied:
            return "Please enable camera access in Settings."
        case .deviceNotAvailable:
            return "Try using a device with a camera."
        case .setupFailed:
            return "Try restarting the app."
        case .inputNotSupported, .outputNotSupported:
            return "Try using a different device."
        case .sessionNotRunning:
            return "Try starting the camera again."
        case .captureFailed, .invalidPhotoData:
            return "Try taking another photo."
        case .serviceDeallocated:
            return "Try restarting the app."
        case .unknown:
            return "Try restarting the app."
        }
    }
    
    // Keep LocalizedError conformance for backward compatibility
    public var errorDescription: String? {
        title
    }
    
    public var failureReason: String? {
        message
    }
}

// MARK: - Camera Service Protocol

/// Protocol for camera operations
public protocol CameraServiceProtocol: ObservableObject {
    /// Whether the camera is currently active
    var isActive: Bool { get }
    
    /// The current camera position
    var position: CameraPosition { get }
    
    /// The current camera error, if any
    var error: CameraError? { get }
    
    /// Sets up the camera with the specified position
    /// - Parameter position: The camera position to use
    /// - Throws: CameraError if setup fails
    func setupCamera(position: CameraPosition) async throws
    
    /// Starts the camera session
    /// - Throws: CameraError if starting the session fails
    func startSession() async throws
    
    /// Stops the camera session
    func stopSession() async
    
    /// Captures a photo from the camera
    /// - Returns: The captured image, or nil if capture fails
    /// - Throws: CameraError if capturing the photo fails
    func capturePhoto() async throws -> Image?
    
    /// Switches between front and back cameras
    /// - Throws: CameraError if switching cameras fails
    func switchCamera() async throws
    
    /// Creates a preview layer for displaying the camera feed
    /// - Parameter frame: The frame for the preview layer
    /// - Returns: The configured preview layer
    func makePreviewLayer(frame: CGRect) -> AVCaptureVideoPreviewLayer
} 