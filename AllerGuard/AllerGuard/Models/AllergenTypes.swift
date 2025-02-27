import Foundation
import SwiftUI

// MARK: - Allergen Types
// This file centralizes allergen-related type definitions for the AllerGuard app.
// To use these types in other files, simply use them directly after importing the standard libraries.
// Since we're in the same module, no special import statement is needed.

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
public struct AllergenMatch: Identifiable, Codable, Hashable {
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
    
    public init(id: UUID = UUID(), name: String, allergenSensitivities: [UUID: SensitivityLevel], createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.allergenSensitivities = allergenSensitivities
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
} 