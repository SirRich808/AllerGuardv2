import Foundation
import SwiftUI

// MARK: - Allergen Models

/// Represents a food allergen
public struct Allergen: Identifiable, Codable, Hashable {
    public var id: UUID
    public var name: String
    public var description: String
    public var commonNames: [String]
    public var iconName: String
    
    public init(id: UUID = UUID(), name: String, description: String, commonNames: [String], iconName: String) {
        self.id = id
        self.name = name
        self.description = description
        self.commonNames = commonNames
        self.iconName = iconName
    }
}

/// Represents a user's sensitivity level to allergens
public enum SensitivityLevel: String, Codable, CaseIterable {
    case mild = "Mild"
    case moderate = "Moderate"
    case severe = "Severe"
    
    public var description: String {
        switch self {
        case .mild:
            return "May cause minor discomfort"
        case .moderate:
            return "Likely to cause significant discomfort"
        case .severe:
            return "Can cause severe reactions requiring immediate attention"
        }
    }
    
    public var color: Color {
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
public struct AllergenMatch: Identifiable, Hashable {
    public var id: UUID
    public var allergen: Allergen
    public var matchedText: String
    public var sensitivityLevel: SensitivityLevel?
    
    public init(id: UUID = UUID(), allergen: Allergen, matchedText: String, sensitivityLevel: SensitivityLevel? = nil) {
        self.id = id
        self.allergen = allergen
        self.matchedText = matchedText
        self.sensitivityLevel = sensitivityLevel
    }
}

// MARK: - User Models

/// Represents a user profile with allergen sensitivities
public struct UserProfile: Identifiable, Codable {
    public var id: UUID
    public var name: String
    public var allergenSensitivities: [UUID: SensitivityLevel]
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(id: UUID = UUID(), name: String, allergenSensitivities: [UUID: SensitivityLevel] = [:], createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.allergenSensitivities = allergenSensitivities
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Scan Models

/// Represents the state of a scan
public enum ScanState: Equatable {
    case ready
    case scanning
    case processing
    case completed
    case error
    
    public var description: String {
        switch self {
        case .ready:
            return "Ready to scan"
        case .scanning:
            return "Scanning..."
        case .processing:
            return "Processing..."
        case .completed:
            return "Scan completed"
        case .error:
            return "Scan error"
        }
    }
}

/// Represents the result of a scan
public struct ScanResult: Identifiable {
    public let id: UUID
    public let timestamp: Date
    public let recognizedText: String
    public let allergenMatches: [AllergenMatch]
    public let image: Image
    
    public init(id: UUID = UUID(), timestamp: Date = Date(), recognizedText: String, allergenMatches: [AllergenMatch], image: Image) {
        self.id = id
        self.timestamp = timestamp
        self.recognizedText = recognizedText
        self.allergenMatches = allergenMatches
        self.image = image
    }
}

// MARK: - Camera Models

/// Camera position (front or back)
public enum CameraPosition {
    case front
    case back
}

// MARK: - Error Models

/// Errors that can occur during scanning
public enum ScanError: Error, LocalizedError, Identifiable {
    case captureError
    case noTextDetected
    case processingError
    
    public var id: UUID {
        UUID()
    }
    
    public var title: String {
        switch self {
        case .captureError:
            return "Capture Error"
        case .noTextDetected:
            return "No Text Detected"
        case .processingError:
            return "Processing Error"
        }
    }
    
    public var message: String {
        switch self {
        case .captureError:
            return "Failed to capture a photo."
        case .noTextDetected:
            return "No text was detected in the image."
        case .processingError:
            return "An error occurred while processing the image."
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .captureError:
            return "Try again or check camera permissions."
        case .noTextDetected:
            return "Try scanning an area with clearer text."
        case .processingError:
            return "Try again or restart the app."
        }
    }
    
    public var errorDescription: String? {
        title
    }
    
    public var failureReason: String? {
        message
    }
}

/// Errors that can occur during OCR operations
public enum OCRError: Error, LocalizedError, Identifiable {
    case invalidImage
    case recognitionFailed
    case serviceDeallocated
    case cancelled
    
    public var id: UUID {
        UUID()
    }
    
    public var title: String {
        switch self {
        case .invalidImage:
            return "Invalid Image"
        case .recognitionFailed:
            return "Recognition Failed"
        case .serviceDeallocated:
            return "Service Error"
        case .cancelled:
            return "Operation Cancelled"
        }
    }
    
    public var message: String {
        switch self {
        case .invalidImage:
            return "The provided image could not be processed."
        case .recognitionFailed:
            return "Text recognition failed."
        case .serviceDeallocated:
            return "The OCR service was deallocated during processing."
        case .cancelled:
            return "The OCR operation was cancelled."
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .invalidImage:
            return "Try using a different image or adjusting the lighting."
        case .recognitionFailed:
            return "Try again with a clearer image or better lighting."
        case .serviceDeallocated:
            return "Please try again."
        case .cancelled:
            return "You can try again when ready."
        }
    }
    
    public var errorDescription: String? {
        title
    }
    
    public var failureReason: String? {
        message
    }
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
    
    public var errorDescription: String? {
        title
    }
    
    public var failureReason: String? {
        message
    }
} 