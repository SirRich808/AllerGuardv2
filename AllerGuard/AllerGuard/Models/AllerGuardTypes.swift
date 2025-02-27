import Foundation
import SwiftUI
import Combine
import Vision
import AVFoundation

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - AllerGuard Centralized Type Definitions
// This file serves as the single source of truth for all shared types in the AllerGuard app.
// Since all types are defined in a single module, they can be used directly without imports.

// MARK: - Camera Types

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
    
    // Keep LocalizedError conformance
    public var errorDescription: String? {
        title
    }
    
    public var failureReason: String? {
        message
    }
}

// MARK: - Allergen Types

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
public struct AllergenMatch: Identifiable, Hashable, Codable {
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

// MARK: - Scan Types

/// Represents the result of a product scan
public struct ScanResult: Identifiable, Codable {
    public var id: UUID
    public var timestamp: Date
    public var productName: String?
    public var imageURL: URL?
    public var detectedText: String
    public var allergenMatches: [AllergenMatch]
    public var isSafe: Bool
    
    public init(id: UUID = UUID(), timestamp: Date = Date(), productName: String? = nil, imageURL: URL? = nil, detectedText: String, allergenMatches: [AllergenMatch] = [], isSafe: Bool = true) {
        self.id = id
        self.timestamp = timestamp
        self.productName = productName
        self.imageURL = imageURL
        self.detectedText = detectedText
        self.allergenMatches = allergenMatches
        self.isSafe = isSafe
    }
}

// MARK: - Permission Types

/// Permission status
public enum PermissionStatus: String, Codable {
    case notDetermined = "Not Determined"
    case denied = "Denied"
    case restricted = "Restricted"
    case authorized = "Authorized"
    case limited = "Limited"
    
    public var description: String {
        self.rawValue
    }
}

// MARK: - App Types

/// Enum representing the main tabs in the app
public enum Tab: Hashable {
    case scan
    case history
    case profile
    case settings
}

/// App-level errors
public struct AppError: Error, Identifiable {
    /// Unique identifier for the error
    public let id = UUID()
    
    /// The title of the error
    public let title: String
    
    /// The message describing the error
    public let message: String
    
    /// Optional suggestion for recovering from the error
    public let recoverySuggestion: String?
    
    /// Initializes a new app error
    /// - Parameters:
    ///   - title: The title of the error
    ///   - message: The message describing the error
    ///   - recoverySuggestion: Optional suggestion for recovering from the error
    public init(title: String, message: String, recoverySuggestion: String? = nil) {
        self.title = title
        self.message = message
        self.recoverySuggestion = recoverySuggestion
    }
} 