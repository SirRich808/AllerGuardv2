import Foundation

/// Represents a match of an allergen in scanned text
struct AllergenMatch: Identifiable, Hashable {
    /// Unique identifier for the match
    let id: UUID
    
    /// The allergen that was matched
    let allergen: Allergen
    
    /// The user's sensitivity level to this allergen
    let userSensitivity: SensitivityLevel
    
    /// The terms that were matched in the text
    let matchedTerms: [String]
    
    /// The ranges in the original text where matches were found
    let matchedRanges: [Range<String.Index>]
    
    /// Confidence score for the match (0.0 to 1.0)
    let confidence: Double
    
    /// Initializes a new allergen match
    /// - Parameters:
    ///   - id: Unique identifier (defaults to a new UUID)
    ///   - allergen: The allergen that was matched
    ///   - userSensitivity: The user's sensitivity level to this allergen
    ///   - matchedTerms: The terms that were matched in the text
    ///   - matchedRanges: The ranges in the original text where matches were found
    ///   - confidence: Confidence score for the match (0.0 to 1.0)
    init(
        id: UUID = UUID(),
        allergen: Allergen,
        userSensitivity: SensitivityLevel,
        matchedTerms: [String],
        matchedRanges: [Range<String.Index>],
        confidence: Double
    ) {
        self.id = id
        self.allergen = allergen
        self.userSensitivity = userSensitivity
        self.matchedTerms = matchedTerms
        self.matchedRanges = matchedRanges
        self.confidence = confidence
    }
    
    /// Whether this match represents a severe allergen for the user
    var isSevere: Bool {
        userSensitivity == .high || userSensitivity == .severe
    }
    
    /// Risk level based on user sensitivity and confidence
    var riskLevel: RiskLevel {
        // Calculate risk based on sensitivity and confidence
        switch userSensitivity {
        case .severe:
            return confidence > 0.5 ? .high : .medium
        case .high:
            return confidence > 0.7 ? .high : .medium
        case .moderate:
            return confidence > 0.8 ? .medium : .low
        case .mild:
            return confidence > 0.9 ? .medium : .low
        case .none:
            return .none
        }
    }
    
    // MARK: - Hashable Conformance
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AllergenMatch, rhs: AllergenMatch) -> Bool {
        lhs.id == rhs.id
    }
}

/// Risk level for an allergen match
enum RiskLevel: String, CaseIterable {
    case none = "None"
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    /// Color associated with the risk level
    var color: String {
        switch self {
        case .none:
            return "riskNone"
        case .low:
            return "riskLow"
        case .medium:
            return "riskMedium"
        case .high:
            return "riskHigh"
        }
    }
    
    /// Icon name associated with the risk level
    var iconName: String {
        switch self {
        case .none:
            return "checkmark.circle"
        case .low:
            return "exclamationmark.triangle"
        case .medium:
            return "exclamationmark.triangle.fill"
        case .high:
            return "exclamationmark.octagon.fill"
        }
    }
}

/// Represents a specific term match in text
struct TermMatch {
    /// The term that was matched
    let term: String
    
    /// The range in the original text where the match was found
    let range: Range<String.Index>
} 