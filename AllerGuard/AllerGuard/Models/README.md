# AllerGuard Type System

This directory contains the centralized type definitions for the AllerGuard app. The goal is to maintain a single source of truth for all types used throughout the application.

## Type Files

### CameraTypes.swift
Contains camera-related type definitions:
- `CameraPosition`: Enum for camera position (front or back)
- `CameraError`: Error types for camera operations
- `CameraServiceProtocol`: Protocol for camera operations

### AllergenTypes.swift
Contains allergen-related type definitions:
- `Allergen`: Struct representing a food allergen
- `SensitivityLevel`: Enum for allergen sensitivity levels
- `AllergenMatch`: Struct representing a match between detected text and an allergen
- `UserProfile`: Struct representing a user profile with allergen sensitivities

### ScanTypes.swift
Contains scan-related type definitions:
- `ScanResult`: Struct representing the result of a product scan
- `ScanStatus`: Enum representing the status of a scan
- `ScanHistory`: Struct representing scan history for a user

## Usage

To use these types in your code, simply use them directly after importing the standard libraries. Since we're in the same module, no special import statement is needed.

```swift
import Foundation
import SwiftUI
// Other imports as needed

// Then use the types directly:
let allergen = Allergen(name: "Peanut", description: "Common allergen", commonNames: ["peanut", "arachis"], iconName: "peanut-icon")
```

## Type Dependencies

The types have the following dependencies:
1. `CameraTypes.swift`: No dependencies
2. `AllergenTypes.swift`: No dependencies
3. `ScanTypes.swift`: Depends on `AllergenTypes.swift` (uses `AllergenMatch`)

## Current Status

Currently, there are some issues with the module structure that prevent proper importing of these types. As a temporary solution, some files may contain duplicate type definitions with TODO comments indicating that they should be imported from the centralized type files in the future.

## Future Improvements

1. Fix the module structure to allow proper importing of types
2. Consider using Swift packages for more complex module structures
3. Implement proper dependency injection for all services
4. Document the import strategy to aid other developers 