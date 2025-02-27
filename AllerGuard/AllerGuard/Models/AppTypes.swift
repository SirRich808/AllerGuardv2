import Foundation
import SwiftUI
import Combine

// Import camera types from the centralized file
// Since we're in the same module, we don't need to specify the module name

// MARK: - Allergen Types

/// Represents a food allergen
struct Allergen: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var description: String
    var commonNames: [String]
    var iconName: String
    
    init(id: UUID = UUID(), name: String, description: String, commonNames: [String], iconName: String) {
        self.id = id
        self.name = name
        self.description = description
        self.commonNames = commonNames
        self.iconName = iconName
    }
}

/// Represents a user's sensitivity level to allergens
enum SensitivityLevel: String, Codable, CaseIterable {
    case mild = "Mild"
    case moderate = "Moderate"
    case severe = "Severe"
    
    var description: String {
        switch self {
        case .mild:
            return "May cause minor discomfort"
        case .moderate:
            return "Likely to cause significant discomfort"
        case .severe:
            return "Can cause severe reactions requiring immediate attention"
        }
    }
    
    var color: Color {
        switch self {
        case .mild:
            return .yellow
        case .moderate:
            return .orange
        case .severe:
            return .red
        }
    }
}

/// Represents a match between detected text and an allergen
struct AllergenMatch: Identifiable, Hashable, Codable {
    var id: UUID
    var allergen: Allergen
    var matchedText: String
    var sensitivityLevel: SensitivityLevel?
    
    init(id: UUID = UUID(), allergen: Allergen, matchedText: String, sensitivityLevel: SensitivityLevel? = nil) {
        self.id = id
        self.allergen = allergen
        self.matchedText = matchedText
        self.sensitivityLevel = sensitivityLevel
    }
}

// MARK: - Camera Types

/// Camera position (front or back)
enum CameraPosition {
    case front
    case back
}

/// Errors that can occur during camera operations
enum CameraError: Error, LocalizedError, Identifiable {
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
    
    var id: UUID {
        UUID()
    }
    
    var title: String {
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
    
    var message: String {
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
    
    var recoverySuggestion: String? {
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
    var errorDescription: String? {
        title
    }
    
    var failureReason: String? {
        message
    }
}

// MARK: - Service Protocols

/// Protocol for camera operations
protocol CameraServiceProtocol: ObservableObject {
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
}

/// Protocol defining the allergen service interface
protocol AllergenServiceProtocol {
    /// Detects allergens in text
    /// - Parameter text: The text to detect allergens in
    /// - Returns: Array of detected allergens
    func detectAllergens(in text: String) async throws -> [AllergenMatch]
    
    /// Gets all supported allergens
    /// - Returns: Array of all supported allergens
    func getAllergens() async -> [Allergen]
    
    /// Updates the user's allergen preferences
    /// - Parameter allergens: The allergens to update
    func updateUserAllergens(_ allergens: [Allergen]) async
} 