# AllerGuard

AllerGuard is an iOS application designed to help users with food allergies identify potential allergens in food products by scanning ingredient labels.

## Project Structure

The project follows the MVVM (Model-View-ViewModel) architecture pattern and is organized into the following directories:

- **App**: Contains the main application entry point and configuration
- **Models**: Contains data models and type definitions
- **Views**: Contains SwiftUI views
- **ViewModels**: Contains view models that connect views to models
- **Services**: Contains service protocols and implementations
- **Utilities**: Contains utility functions and extensions

## Centralized Type System

To maintain a clean and maintainable codebase, AllerGuard uses a centralized type system. All shared types are defined in dedicated files in the Models directory:

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

## Features

- **Camera Scanning**: Scan food product labels using the device camera
- **OCR (Optical Character Recognition)**: Extract text from images of food labels
- **Allergen Detection**: Identify potential allergens in the extracted text
- **User Profiles**: Manage user allergen sensitivities
- **Scan History**: View and manage past scans

## Dependencies

- **SwiftUI**: For building the user interface
- **Combine**: For reactive programming
- **Vision**: For OCR functionality
- **AVFoundation**: For camera functionality
- **Core Data**: For local data storage

## Getting Started

1. Clone the repository
2. Open the project in Xcode
3. Build and run the application

## Development Guidelines

- Follow the MVVM architecture pattern
- Use meaningful names for variables and functions
- Comment complex logic or algorithms
- Handle errors gracefully
- Use dependency injection for services
- Write unit tests for all new logic
- Update UI elements only on the main thread
- Follow Apple's Human Interface Guidelines

## Current Status

The project is currently under development. Some features may not be fully implemented or may contain temporary solutions.

## Future Improvements

1. Fix the module structure to allow proper importing of types
2. Consider using Swift packages for more complex module structures
3. Implement proper dependency injection for all services
4. Document the import strategy to aid other developers
5. Improve test coverage
6. Enhance accessibility features
7. Add localization support 