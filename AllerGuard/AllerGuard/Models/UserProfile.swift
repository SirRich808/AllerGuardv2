import Foundation

/// Represents a user's profile with allergen preferences and settings
struct UserProfile: Identifiable, Codable {
    /// Unique identifier for the user profile
    let id: UUID
    
    /// User's name
    var name: String
    
    /// User's allergens with their sensitivity levels
    var allergens: [UserAllergen]
    
    /// User's dietary preferences (e.g., vegetarian, vegan)
    var dietaryPreferences: [DietaryPreference]
    
    /// User's preferred safety threshold
    var safetyThreshold: SafetyThreshold
    
    /// Whether to show warnings for potential cross-contamination
    var showCrossContaminationWarnings: Bool
    
    /// Whether to show substitution suggestions
    var showSubstitutionSuggestions: Bool
    
    /// Creates a new user profile with a random ID
    init(name: String, 
         allergens: [UserAllergen] = [], 
         dietaryPreferences: [DietaryPreference] = [],
         safetyThreshold: SafetyThreshold = .medium,
         showCrossContaminationWarnings: Bool = true,
         showSubstitutionSuggestions: Bool = true) {
        self.id = UUID()
        self.name = name
        self.allergens = allergens
        self.dietaryPreferences = dietaryPreferences
        self.safetyThreshold = safetyThreshold
        self.showCrossContaminationWarnings = showCrossContaminationWarnings
        self.showSubstitutionSuggestions = showSubstitutionSuggestions
    }
    
    /// Returns all allergens that the user is sensitive to
    var activeAllergens: [UserAllergen] {
        allergens.filter { $0.sensitivityLevel != .none }
    }
    
    /// Returns allergens with high or severe sensitivity
    var severeAllergens: [UserAllergen] {
        allergens.filter { $0.sensitivityLevel == .high || $0.sensitivityLevel == .severe }
    }
}

/// Represents a user's sensitivity to a specific allergen
struct UserAllergen: Identifiable, Codable, Hashable {
    /// Unique identifier for the user allergen
    let id: UUID
    
    /// Reference to the allergen ID
    let allergenId: UUID
    
    /// User's sensitivity level to this allergen
    var sensitivityLevel: SensitivityLevel
    
    /// Additional notes about the user's reaction to this allergen
    var notes: String?
    
    /// Creates a new user allergen with a random ID
    init(allergenId: UUID, sensitivityLevel: SensitivityLevel = .none, notes: String? = nil) {
        self.id = UUID()
        self.allergenId = allergenId
        self.sensitivityLevel = sensitivityLevel
        self.notes = notes
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Equatable conformance
    static func == (lhs: UserAllergen, rhs: UserAllergen) -> Bool {
        lhs.id == rhs.id
    }
}

/// User's sensitivity level to an allergen
enum SensitivityLevel: String, Codable, CaseIterable {
    case none = "None"
    case mild = "Mild"
    case moderate = "Moderate"
    case high = "High"
    case severe = "Severe"
    
    var color: String {
        switch self {
        case .none:
            return "sensitivityNone"
        case .mild:
            return "sensitivityMild"
        case .moderate:
            return "sensitivityModerate"
        case .high:
            return "sensitivityHigh"
        case .severe:
            return "sensitivitySevere"
        }
    }
}

/// User's safety threshold for allergen detection
enum SafetyThreshold: String, Codable, CaseIterable {
    case low = "Low (Most Cautious)"
    case medium = "Medium"
    case high = "High (Least Cautious)"
}

/// Dietary preferences that may affect menu filtering
enum DietaryPreference: String, Codable, CaseIterable {
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case pescatarian = "Pescatarian"
    case glutenFree = "Gluten-Free"
    case dairyFree = "Dairy-Free"
    case kosher = "Kosher"
    case halal = "Halal"
    case lowCarb = "Low Carb"
    case keto = "Keto"
    case paleo = "Paleo"
    
    var description: String {
        switch self {
        case .vegetarian:
            return "No meat, may include dairy and eggs"
        case .vegan:
            return "No animal products"
        case .pescatarian:
            return "No meat except fish"
        case .glutenFree:
            return "No gluten-containing grains"
        case .dairyFree:
            return "No dairy products"
        case .kosher:
            return "Follows kosher dietary laws"
        case .halal:
            return "Follows halal dietary laws"
        case .lowCarb:
            return "Reduced carbohydrate intake"
        case .keto:
            return "Very low carb, high fat diet"
        case .paleo:
            return "Based on foods presumed to be available to paleolithic humans"
        }
    }
} 