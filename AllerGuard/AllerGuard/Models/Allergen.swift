import Foundation

/// Represents a food allergen that users may be sensitive to
struct Allergen: Identifiable, Codable, Hashable {
    /// Unique identifier for the allergen
    let id: UUID
    
    /// Display name of the allergen
    let name: String
    
    /// Description of the allergen
    let description: String
    
    /// Common alternative names for this allergen
    let alternativeNames: [String]
    
    /// Common ingredients that may contain this allergen
    let commonIngredients: [String]
    
    /// Severity level for warning display
    let severityLevel: SeverityLevel
    
    /// Icon name for the allergen (SF Symbol name)
    let iconName: String
    
    /// Creates a new allergen with a random ID
    init(name: String, description: String, alternativeNames: [String] = [], 
         commonIngredients: [String] = [], severityLevel: SeverityLevel = .medium,
         iconName: String) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.alternativeNames = alternativeNames
        self.commonIngredients = commonIngredients
        self.severityLevel = severityLevel
        self.iconName = iconName
    }
}

/// Severity level for allergens
enum SeverityLevel: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case severe = "Severe"
    
    var color: String {
        switch self {
        case .low:
            return "allergenLowSeverity"
        case .medium:
            return "allergenMediumSeverity"
        case .high:
            return "allergenHighSeverity"
        case .severe:
            return "allergenSevereSeverity"
        }
    }
}

/// Common allergen types with predefined data
extension Allergen {
    static let peanuts = Allergen(
        name: "Peanuts",
        description: "A legume commonly used in various food products",
        alternativeNames: ["Arachis oil", "Groundnuts", "Goober peas"],
        commonIngredients: ["Peanut butter", "Peanut oil", "Mixed nuts"],
        severityLevel: .high,
        iconName: "allergen.peanut"
    )
    
    static let treeNuts = Allergen(
        name: "Tree Nuts",
        description: "Various nuts grown on trees, including almonds, walnuts, and cashews",
        alternativeNames: ["Almonds", "Walnuts", "Cashews", "Pistachios", "Hazelnuts"],
        commonIngredients: ["Almond milk", "Walnut oil", "Marzipan", "Nougat"],
        severityLevel: .high,
        iconName: "allergen.treenut"
    )
    
    static let dairy = Allergen(
        name: "Dairy",
        description: "Products containing milk from cows, goats, or sheep",
        alternativeNames: ["Milk", "Lactose", "Casein", "Whey"],
        commonIngredients: ["Butter", "Cheese", "Yogurt", "Cream", "Ice cream"],
        severityLevel: .medium,
        iconName: "allergen.dairy"
    )
    
    static let eggs = Allergen(
        name: "Eggs",
        description: "Eggs from birds, primarily chicken eggs",
        alternativeNames: ["Albumin", "Ovalbumin", "Globulin", "Ovomucin"],
        commonIngredients: ["Mayonnaise", "Meringue", "Some baked goods"],
        severityLevel: .medium,
        iconName: "allergen.egg"
    )
    
    static let wheat = Allergen(
        name: "Wheat",
        description: "A cereal grain used in many food products",
        alternativeNames: ["Gluten", "Flour", "Semolina", "Durum"],
        commonIngredients: ["Bread", "Pasta", "Cereal", "Baked goods"],
        severityLevel: .medium,
        iconName: "allergen.wheat"
    )
    
    static let soy = Allergen(
        name: "Soy",
        description: "Products derived from soybeans",
        alternativeNames: ["Soya", "Edamame", "Tofu", "Tempeh"],
        commonIngredients: ["Soy sauce", "Miso", "Textured vegetable protein"],
        severityLevel: .medium,
        iconName: "allergen.soy"
    )
    
    static let shellfish = Allergen(
        name: "Shellfish",
        description: "Marine animals with shells, including crustaceans and mollusks",
        alternativeNames: ["Crustaceans", "Mollusks", "Shrimp", "Crab", "Lobster"],
        commonIngredients: ["Seafood dishes", "Fish sauce", "Surimi"],
        severityLevel: .high,
        iconName: "allergen.shellfish"
    )
    
    static let fish = Allergen(
        name: "Fish",
        description: "Various species of finned fish",
        alternativeNames: ["Cod", "Salmon", "Tuna", "Tilapia"],
        commonIngredients: ["Fish sauce", "Caesar dressing", "Worcestershire sauce"],
        severityLevel: .high,
        iconName: "allergen.fish"
    )
    
    /// List of common allergens
    static let commonAllergens: [Allergen] = [
        .peanuts, .treeNuts, .dairy, .eggs, .wheat, .soy, .shellfish, .fish
    ]
} 