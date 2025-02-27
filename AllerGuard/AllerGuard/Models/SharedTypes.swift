import Foundation
import SwiftUI
import Combine

// MARK: - Shared Types Documentation
// This file serves as documentation for type definitions across the AllerGuard app.
// It helps developers understand where each type is defined and how they relate to each other.

/*
 Type Dependency Graph:
 
 CameraTypes.swift:
 - CameraPosition
 - CameraError
 - CameraServiceProtocol
 
 AllergenTypes.swift:
 - Allergen
 - SensitivityLevel
 - AllergenMatch
 - UserProfile
 
 ScanTypes.swift (depends on AllergenTypes.swift):
 - ScanResult (uses AllergenMatch)
 - ScanStatus
 - ScanHistory
 
 Usage in other files:
 
 To use these types, ensure you have the appropriate imports:
 ```
 import Foundation
 import SwiftUI
 // Other imports as needed
 
 // Then use the types directly:
 let allergen = Allergen(name: "Peanut", description: "Common allergen", commonNames: ["peanut", "arachis"], iconName: "peanut-icon")
 ```
 
 Compilation Order:
 For proper compilation, ensure these files are compiled in the following order:
 1. CameraTypes.swift
 2. AllergenTypes.swift
 3. ScanTypes.swift
 
 This ensures that dependent types are available when needed.
 */

// MARK: - Type Usage Examples

/*
 // Camera usage example:
 let cameraService: CameraServiceProtocol = CameraService()
 let position: CameraPosition = .back
 
 // Allergen usage example:
 let allergen = Allergen(name: "Peanut", description: "Common allergen", commonNames: ["peanut", "arachis"], iconName: "peanut-icon")
 let sensitivity: SensitivityLevel = .severe
 let match = AllergenMatch(allergen: allergen, matchedText: "peanut", sensitivityLevel: sensitivity)
 
 // Scan usage example:
 let scanResult = ScanResult(detectedText: "Contains peanuts", allergenMatches: [match], isSafe: false)
 var history = ScanHistory(userId: UUID())
 history.addScan(scanResult)
 */

// Camera Types - Defined in Models/CameraTypes.swift
// - CameraPosition: Enum for camera position (front/back)
// - CameraError: Error enum for camera operations
// - CameraServiceProtocol: Protocol for camera service

// Allergen Types - Defined in Models/AllergenTypes.swift
// - Allergen: Struct for allergen information
// - SensitivityLevel: Enum for allergen sensitivity
// - AllergenMatch: Struct for matched allergens
// - UserProfile: Struct for user profile with allergen sensitivities

// Scan Types - Defined in Models/ScanTypes.swift
// - ScanResult: Struct for scan results

// Note: To use these types, simply use them directly in your files.
// No special import is needed since they're in the same module.
// Example: 
// ```
// func setupCamera(position: CameraPosition) { ... }
// ``` 