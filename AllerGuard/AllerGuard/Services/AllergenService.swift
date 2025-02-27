import Foundation
import Combine
import SwiftUI

// MARK: - Models

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

/// Represents a user profile with allergen sensitivities
struct UserProfile: Identifiable, Codable {
    var id: UUID
    var name: String
    var allergenSensitivities: [UUID: SensitivityLevel]
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), name: String, allergenSensitivities: [UUID: SensitivityLevel] = [:], createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.allergenSensitivities = allergenSensitivities
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Represents a match between detected text and an allergen
struct AllergenMatch: Identifiable, Hashable {
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

/// Service for managing allergens and detecting them in text
final class AllergenService: ObservableObject {
    // MARK: - AllergenServiceProtocol
    
    /// Detects allergens in text
    /// - Parameter text: The text to detect allergens in
    /// - Returns: Array of detected allergens
    func detectAllergens(in text: String) async throws -> [AllergenMatch] {
        // This is a stub implementation
        // In a real implementation, we would use NLP to detect allergens
        return []
    }
    
    /// Gets all supported allergens
    /// - Returns: Array of all supported allergens
    func getAllergens() async -> [Allergen] {
        // This is a stub implementation
        // In a real implementation, we would fetch allergens from a database
        return []
    }
    
    /// Updates the user's allergen preferences
    /// - Parameter allergens: The allergens to update
    func updateUserAllergens(_ allergens: [Allergen]) async {
        // This is a stub implementation
        // In a real implementation, we would update the user's allergen preferences in a database
    }
    
    // MARK: - Published Properties
    
    /// The list of all available allergens
    @Published private(set) var allergens: [Allergen] = []
    
    /// The current user profile
    @Published private(set) var userProfile: UserProfile
    
    // MARK: - Private Properties
    
    /// Subject for allergen updates
    private let allergenSubject = PassthroughSubject<[Allergen], Never>()
    
    /// Subject for user profile updates
    private let userProfileSubject = PassthroughSubject<UserProfile, Never>()
    
    /// Set of cancellables for managing subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(userProfile: UserProfile = UserProfile(name: "Default User")) {
        self.userProfile = userProfile
        
        // Load default allergens
        self.allergens = Self.defaultAllergens
        
        // Set up publishers
        setupPublishers()
    }
    
    // MARK: - Public Methods
    
    /// Updates the user's sensitivity level for an allergen
    /// - Parameters:
    ///   - allergenId: The ID of the allergen to update
    ///   - level: The new sensitivity level
    func updateSensitivity(for allergenId: UUID, to level: SensitivityLevel?) {
        var updatedProfile = userProfile
        
        if let level = level {
            updatedProfile.allergenSensitivities[allergenId] = level
        } else {
            updatedProfile.allergenSensitivities.removeValue(forKey: allergenId)
        }
        
        updatedProfile.updatedAt = Date()
        userProfile = updatedProfile
        userProfileSubject.send(updatedProfile)
        
        // In a real app, we would save the profile to persistent storage here
    }
    
    /// Adds a new allergen to the list
    /// - Parameter allergen: The allergen to add
    func addAllergen(_ allergen: Allergen) {
        var updatedAllergens = allergens
        updatedAllergens.append(allergen)
        allergens = updatedAllergens
        allergenSubject.send(updatedAllergens)
        
        // In a real app, we would save the allergens to persistent storage here
    }
    
    /// Removes an allergen from the list
    /// - Parameter id: The ID of the allergen to remove
    func removeAllergen(withId id: UUID) {
        var updatedAllergens = allergens
        updatedAllergens.removeAll { $0.id == id }
        allergens = updatedAllergens
        allergenSubject.send(updatedAllergens)
        
        // In a real app, we would save the allergens to persistent storage here
    }
    
    // MARK: - Private Methods
    
    /// Sets up publishers for allergens and user profile
    private func setupPublishers() {
        allergenSubject
            .sink { [weak self] allergens in
                self?.allergens = allergens
            }
            .store(in: &cancellables)
        
        userProfileSubject
            .sink { [weak self] profile in
                self?.userProfile = profile
            }
            .store(in: &cancellables)
    }
}

// MARK: - Default Data

extension AllergenService {
    /// Default allergens for the app
    static var defaultAllergens: [Allergen] {
        [
            Allergen(
                name: "Peanuts",
                description: "A legume commonly used in various food products.",
                commonNames: ["peanut", "arachis", "groundnut", "goober", "monkey nut"],
                iconName: "allergen.peanut"
            ),
            Allergen(
                name: "Tree Nuts",
                description: "Includes almonds, walnuts, cashews, and more.",
                commonNames: ["almond", "walnut", "cashew", "pecan", "hazelnut", "macadamia"],
                iconName: "allergen.treenut"
            ),
            Allergen(
                name: "Milk",
                description: "Dairy products from cows and other animals.",
                commonNames: ["dairy", "lactose", "whey", "casein", "butter", "cheese", "cream"],
                iconName: "allergen.milk"
            ),
            Allergen(
                name: "Eggs",
                description: "Eggs from birds, commonly chicken eggs.",
                commonNames: ["egg", "albumin", "globulin", "ovomucoid", "ovalbumin", "lysozyme"],
                iconName: "allergen.egg"
            ),
            Allergen(
                name: "Wheat",
                description: "A cereal grain used in many food products.",
                commonNames: ["flour", "gluten", "semolina", "spelt", "farina", "durum"],
                iconName: "allergen.wheat"
            ),
            Allergen(
                name: "Soy",
                description: "A legume used in many processed foods.",
                commonNames: ["soya", "soybean", "tofu", "edamame", "miso", "tempeh"],
                iconName: "allergen.soy"
            ),
            Allergen(
                name: "Fish",
                description: "Various species of fish.",
                commonNames: ["cod", "salmon", "tuna", "haddock", "mackerel", "bass", "anchovy"],
                iconName: "allergen.fish"
            ),
            Allergen(
                name: "Shellfish",
                description: "Includes crustaceans and mollusks.",
                commonNames: ["shrimp", "crab", "lobster", "prawn", "clam", "mussel", "oyster"],
                iconName: "allergen.shellfish"
            )
        ]
    }
}

// MARK: - Allergen Errors

/// Errors that can occur during allergen operations
enum AllergenError: Error, LocalizedError, Identifiable {
    case detectionFailed(Error)
    case noIngredientsFound
    case ingredientParsingFailed
    case databaseUpdateFailed
    
    var id: UUID {
        UUID()
    }
    
    var title: String {
        switch self {
        case .detectionFailed:
            return "Allergen Detection Failed"
        case .noIngredientsFound:
            return "No Ingredients Found"
        case .ingredientParsingFailed:
            return "Ingredient Parsing Failed"
        case .databaseUpdateFailed:
            return "Allergen Database Update Failed"
        }
    }
    
    var message: String {
        switch self {
        case .detectionFailed:
            return "There was a problem detecting allergens."
        case .noIngredientsFound:
            return "No ingredients could be identified in the text."
        case .ingredientParsingFailed:
            return "The ingredients could not be properly parsed."
        case .databaseUpdateFailed:
            return "The allergen database could not be updated."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .detectionFailed:
            return "Try scanning again with a clearer image."
        case .noIngredientsFound:
            return "Ensure you are scanning an ingredient list."
        case .ingredientParsingFailed:
            return "Try scanning again or manually check ingredients."
        case .databaseUpdateFailed:
            return "Check your internet connection and try again later."
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

/// Represents a match for a specific term in text
struct TermMatch {
    /// The term that matched
    let term: String
    
    /// The range where the match was found
    let range: Range<String.Index>
} 