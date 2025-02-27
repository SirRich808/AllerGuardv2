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

// Since we're having issues with direct type references, let's temporarily
// keep the type definitions here until the module structure is fixed

// MARK: - Temporary Type Definitions
// These should be replaced with imports from AllerGuardTypes.swift
// once the module structure is fixed

// Camera position (front or back)
enum CameraPosition {
    case front
    case back
}

// Errors that can occur during camera operations
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
}

// Represents a food allergen
struct Allergen: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var description: String
    var commonNames: [String]
    var iconName: String
}

// Represents a user's sensitivity level to allergens
enum SensitivityLevel: String, Codable, CaseIterable {
    case mild = "Mild"
    case moderate = "Moderate"
    case severe = "Severe"
    
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

// Represents a user profile with allergen sensitivities
struct UserProfile: Identifiable, Codable {
    var id: UUID
    var name: String
    var allergenSensitivities: [UUID: SensitivityLevel]
    var createdAt: Date
    var updatedAt: Date
}

// Represents a match between detected text and an allergen
struct AllergenMatch: Identifiable, Hashable, Codable {
    var id: UUID
    var allergen: Allergen
    var matchedText: String
    var sensitivityLevel: SensitivityLevel?
}

// Represents the result of a product scan
struct ScanResult: Identifiable, Codable {
    var id: UUID
    var timestamp: Date
    var productName: String?
    var imageURL: URL?
    var detectedText: String
    var allergenMatches: [AllergenMatch]
    var isSafe: Bool
}

// MARK: - Camera Service Protocol

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
    
    /// Creates a preview layer for displaying the camera feed
    /// - Parameter frame: The frame for the preview layer
    /// - Returns: The configured preview layer
    func makePreviewLayer(frame: CGRect) -> AVCaptureVideoPreviewLayer
}

// MARK: - OCR Service Protocol

/// Protocol for OCR (Optical Character Recognition) service
protocol OCRServiceProtocol {
    /// Recognizes text in an image
    /// - Parameter image: The image to recognize text in
    /// - Returns: The recognized text
    #if os(iOS)
    func recognizeText(in image: UIImage) async throws -> String
    #elseif os(macOS)
    func recognizeText(in image: NSImage) async throws -> String
    #endif
    
    /// Recognizes text in an image at a specific region
    /// - Parameters:
    ///   - image: The image to recognize text in
    ///   - region: The region to recognize text in
    /// - Returns: The recognized text
    #if os(iOS)
    func recognizeText(in image: UIImage, region: CGRect) async throws -> String
    #elseif os(macOS)
    func recognizeText(in image: NSImage, region: CGRect) async throws -> String
    #endif
}

// MARK: - Allergen Service Protocol

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

// MARK: - Storage Service Protocol

/// Protocol for data storage service
protocol StorageServiceProtocol {
    /// Saves a scan result
    /// - Parameter scan: The scan result to save
    /// - Returns: The saved scan result with updated ID
    func saveScan(_ scan: ScanResult) async throws -> ScanResult
    
    /// Gets all scan results
    /// - Returns: Array of all scan results
    func getAllScans() async throws -> [ScanResult]
    
    /// Gets a scan result by ID
    /// - Parameter id: The ID of the scan result
    /// - Returns: The scan result, or nil if not found
    func getScan(byId id: UUID) async throws -> ScanResult?
    
    /// Deletes a scan result
    /// - Parameter id: The ID of the scan result to delete
    func deleteScan(id: UUID) async throws
    
    /// Saves the user profile
    /// - Parameter profile: The user profile to save
    func saveUserProfile(_ profile: UserProfile) async throws
    
    /// Gets the user profile
    /// - Returns: The user profile, or nil if not found
    func getUserProfile() async throws -> UserProfile?
}

// MARK: - Permission Service Protocol

/// Protocol for permission handling service
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

// MARK: - Supporting Types

/// Permission status
enum PermissionStatus: String {
    case notDetermined = "Not Determined"
    case denied = "Denied"
    case restricted = "Restricted"
    case authorized = "Authorized"
    case limited = "Limited"
} 