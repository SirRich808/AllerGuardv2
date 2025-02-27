import Foundation
import SwiftUI

// MARK: - Scan Types
// This file centralizes scan-related type definitions for the AllerGuard app.
// To use these types in other files, simply use them directly after importing the standard libraries.
// Since we're in the same module, no special import statement is needed.

// Forward reference to AllergenMatch from AllergenTypes.swift
// We need to ensure AllergenTypes.swift is compiled before this file

/// Represents the result of a product scan
public struct ScanResult: Identifiable, Codable {
    public var id: UUID
    public var timestamp: Date
    public var productName: String?
    public var imageURL: URL?
    public var detectedText: String
    public var allergenMatches: [AllergenMatch]
    public var isSafe: Bool
    
    public init(id: UUID = UUID(), timestamp: Date = Date(), productName: String? = nil, imageURL: URL? = nil, detectedText: String, allergenMatches: [AllergenMatch], isSafe: Bool) {
        self.id = id
        self.timestamp = timestamp
        self.productName = productName
        self.imageURL = imageURL
        self.detectedText = detectedText
        self.allergenMatches = allergenMatches
        self.isSafe = isSafe
    }
}

/// Represents the status of a scan
/// Note: This enum is not Codable due to the Error associated value
public enum ScanStatus {
    case ready
    case scanning
    case processing
    case complete(ScanResult)
    case error(Error)
    
    public var isScanning: Bool {
        switch self {
        case .scanning, .processing:
            return true
        default:
            return false
        }
    }
    
    public var isComplete: Bool {
        switch self {
        case .complete:
            return true
        default:
            return false
        }
    }
    
    public var result: ScanResult? {
        switch self {
        case .complete(let result):
            return result
        default:
            return nil
        }
    }
}

/// Represents scan history for a user
public struct ScanHistory: Codable {
    public var userId: UUID
    public var scans: [ScanResult]
    
    public init(userId: UUID, scans: [ScanResult] = []) {
        self.userId = userId
        self.scans = scans
    }
    
    public mutating func addScan(_ scan: ScanResult) {
        scans.append(scan)
    }
} 