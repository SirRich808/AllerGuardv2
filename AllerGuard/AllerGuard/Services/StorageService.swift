import Foundation
import Combine
import SwiftUI

#if os(iOS)
import UIKit
typealias PlatformImage = UIImage
#elseif os(macOS)
import AppKit
typealias PlatformImage = NSImage
#endif

// Import model types
// We'll define these types directly to avoid import issues

/// Represents a match between detected text and an allergen
struct AllergenMatch: Identifiable, Codable, Hashable {
    var id: UUID
    var allergen: Allergen
    var matchedText: String
    var sensitivityLevel: SensitivityLevel?
    
    enum CodingKeys: String, CodingKey {
        case id, allergen, matchedText, sensitivityLevel
    }
}

/// Represents a food allergen
struct Allergen: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var description: String
    var commonNames: [String]
    var iconName: String
}

/// Represents a user's sensitivity level to allergens
enum SensitivityLevel: String, Codable, CaseIterable {
    case mild = "Mild"
    case moderate = "Moderate"
    case severe = "Severe"
}

/// Scan result model
struct ScanResult: Identifiable, Codable {
    /// The unique identifier for the scan
    let id: UUID
    
    /// The date the scan was performed
    let date: Date
    
    /// The image path for the scan
    let imagePath: String
    
    /// The recognized text from the scan
    let recognizedText: String
    
    /// The detected allergens from the scan
    let detectedAllergens: [AllergenMatch]
    
    /// User notes about the scan
    var notes: String?
}

/// Represents a user profile with allergen sensitivities
struct UserProfile: Identifiable, Codable {
    var id: UUID
    var name: String
    var allergenSensitivities: [UUID: SensitivityLevel]
    var createdAt: Date
    var updatedAt: Date
}

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

/// Errors that can occur during storage operations
enum StorageError: Error, LocalizedError, Identifiable {
    case fileNotFound
    case saveFailed
    case loadFailed
    case deleteFailed
    case directoryCreationFailed
    case invalidData
    
    var id: UUID {
        UUID()
    }
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "File Not Found"
        case .saveFailed:
            return "Save Failed"
        case .loadFailed:
            return "Load Failed"
        case .deleteFailed:
            return "Delete Failed"
        case .directoryCreationFailed:
            return "Directory Creation Failed"
        case .invalidData:
            return "Invalid Data"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .fileNotFound:
            return "The requested file could not be found."
        case .saveFailed:
            return "Failed to save the data."
        case .loadFailed:
            return "Failed to load the data."
        case .deleteFailed:
            return "Failed to delete the data."
        case .directoryCreationFailed:
            return "Failed to create the directory."
        case .invalidData:
            return "The data is invalid or corrupted."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .fileNotFound:
            return "Check if the file exists and try again."
        case .saveFailed:
            return "Check disk space and permissions, then try again."
        case .loadFailed:
            return "The file may be corrupted. Try again or restore from backup."
        case .deleteFailed:
            return "Check permissions and try again."
        case .directoryCreationFailed:
            return "Check permissions and disk space, then try again."
        case .invalidData:
            return "The data may be corrupted. Try again or restore from backup."
        }
    }
}

/// Service for data storage operations
final class StorageService: StorageServiceProtocol {
    // MARK: - Private Properties
    
    /// The JSON encoder
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    /// The JSON decoder
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    /// The file manager
    private let fileManager = FileManager.default
    
    /// The document directory URL
    private var documentDirectory: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    /// The scans directory URL
    private var scansDirectory: URL? {
        guard let documentDirectory = documentDirectory else { return nil }
        return documentDirectory.appendingPathComponent("Scans", isDirectory: true)
    }
    
    /// The profiles directory URL
    private var profilesDirectory: URL? {
        guard let documentDirectory = documentDirectory else { return nil }
        return documentDirectory.appendingPathComponent("Profiles", isDirectory: true)
    }
    
    // MARK: - Initialization
    
    init() {
        createDirectoriesIfNeeded()
    }
    
    // MARK: - StorageServiceProtocol
    
    /// Saves a scan result
    /// - Parameter scan: The scan result to save
    /// - Returns: The saved scan result with updated ID
    func saveScan(_ scan: ScanResult) async throws -> ScanResult {
        guard let scansDirectory = scansDirectory else {
            throw StorageError.directoryCreationFailed
        }
        
        // Create a new scan with a new ID if needed
        let scanToSave = scan.id == UUID.init() ? ScanResult(
            id: UUID(),
            date: scan.date,
            imagePath: scan.imagePath,
            recognizedText: scan.recognizedText,
            detectedAllergens: scan.detectedAllergens,
            notes: scan.notes
        ) : scan
        
        // Save the scan data
        let scanURL = scansDirectory.appendingPathComponent("\(scanToSave.id.uuidString).json")
        
        do {
            let data = try encoder.encode(scanToSave)
            try data.write(to: scanURL)
            return scanToSave
        } catch {
            throw StorageError.saveFailed
        }
    }
    
    /// Gets all scan results
    /// - Returns: Array of all scan results
    func getAllScans() async throws -> [ScanResult] {
        guard let scansDirectory = scansDirectory,
              fileManager.fileExists(atPath: scansDirectory.path) else {
            return []
        }
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(
                at: scansDirectory,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            )
            
            let jsonFiles = fileURLs.filter { $0.pathExtension == "json" }
            
            var scans: [ScanResult] = []
            
            for fileURL in jsonFiles {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let scan = try decoder.decode(ScanResult.self, from: data)
                    scans.append(scan)
                } catch {
                    // Skip files that can't be decoded
                    continue
                }
            }
            
            // Sort by date, newest first
            return scans.sorted { $0.date > $1.date }
        } catch {
            throw StorageError.loadFailed
        }
    }
    
    /// Gets a scan result by ID
    /// - Parameter id: The ID of the scan result
    /// - Returns: The scan result, or nil if not found
    func getScan(byId id: UUID) async throws -> ScanResult? {
        guard let scansDirectory = scansDirectory else {
            throw StorageError.directoryCreationFailed
        }
        
        let scanURL = scansDirectory.appendingPathComponent("\(id.uuidString).json")
        
        guard fileManager.fileExists(atPath: scanURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: scanURL)
            let scan = try decoder.decode(ScanResult.self, from: data)
            return scan
        } catch {
            throw StorageError.loadFailed
        }
    }
    
    /// Deletes a scan result
    /// - Parameter id: The ID of the scan result to delete
    func deleteScan(id: UUID) async throws {
        guard let scansDirectory = scansDirectory else {
            throw StorageError.directoryCreationFailed
        }
        
        let scanURL = scansDirectory.appendingPathComponent("\(id.uuidString).json")
        
        guard fileManager.fileExists(atPath: scanURL.path) else {
            throw StorageError.fileNotFound
        }
        
        do {
            try fileManager.removeItem(at: scanURL)
            
            // Also delete the associated image if it exists
            if let scan = try? await getScan(byId: id),
               !scan.imagePath.isEmpty {
                let imageURL = URL(fileURLWithPath: scan.imagePath)
                if fileManager.fileExists(atPath: imageURL.path) {
                    try fileManager.removeItem(at: imageURL)
                }
            }
        } catch {
            throw StorageError.deleteFailed
        }
    }
    
    /// Saves the user profile
    /// - Parameter profile: The user profile to save
    func saveUserProfile(_ profile: UserProfile) async throws {
        guard let profilesDirectory = profilesDirectory else {
            throw StorageError.directoryCreationFailed
        }
        
        let profileURL = profilesDirectory.appendingPathComponent("userProfile.json")
        
        do {
            let data = try encoder.encode(profile)
            try data.write(to: profileURL)
        } catch {
            throw StorageError.saveFailed
        }
    }
    
    /// Gets the user profile
    /// - Returns: The user profile, or nil if not found
    func getUserProfile() async throws -> UserProfile? {
        guard let profilesDirectory = profilesDirectory else {
            throw StorageError.directoryCreationFailed
        }
        
        let profileURL = profilesDirectory.appendingPathComponent("userProfile.json")
        
        guard fileManager.fileExists(atPath: profileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: profileURL)
            let profile = try decoder.decode(UserProfile.self, from: data)
            return profile
        } catch {
            throw StorageError.loadFailed
        }
    }
    
    // MARK: - Image Storage Methods
    
    /// Saves an image to the document directory
    /// - Parameter image: The image to save
    /// - Returns: The path to the saved image
    func saveImage(_ image: PlatformImage) throws -> String {
        guard let documentDirectory = documentDirectory else {
            throw StorageError.directoryCreationFailed
        }
        
        // Create images directory if needed
        let imagesDirectory = documentDirectory.appendingPathComponent("Images", isDirectory: true)
        if !fileManager.fileExists(atPath: imagesDirectory.path) {
            try fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        }
        
        // Generate a unique filename
        let filename = "\(UUID().uuidString).jpg"
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        
        // Convert image to data and save
        #if os(iOS)
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.invalidData
        }
        #elseif os(macOS)
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw StorageError.invalidData
        }
        
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        guard let data = bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: 0.8]) else {
            throw StorageError.invalidData
        }
        #endif
        
        try data.write(to: fileURL)
        
        return fileURL.path
    }
    
    // MARK: - Private Methods
    
    /// Creates the necessary directories if they don't exist
    private func createDirectoriesIfNeeded() {
        guard let documentDirectory = documentDirectory else { return }
        
        let directories = [
            documentDirectory.appendingPathComponent("Scans", isDirectory: true),
            documentDirectory.appendingPathComponent("Profiles", isDirectory: true),
            documentDirectory.appendingPathComponent("Images", isDirectory: true)
        ]
        
        for directory in directories {
            if !fileManager.fileExists(atPath: directory.path) {
                do {
                    try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
                } catch {
                    print("Failed to create directory: \(directory.path)")
                }
            }
        }
    }
} 