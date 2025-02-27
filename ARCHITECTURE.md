# AllerGuard Architecture

*Last Updated: February 27, 2025*

## Overview

AllerGuard is a SwiftUI iOS application that helps users with food allergies navigate restaurant dining experiences safely by scanning menus and identifying safe food options based on their allergen profiles. The application also supports scanning ingredient labels on packaged foods. It follows the MVVM (Model-View-ViewModel) architecture pattern and is designed to work reliably offline.

## Core Architecture Principles

- **Separation of Concerns**: Clear boundaries between data, business logic, and presentation
- **Testability**: All components designed to be testable in isolation
- **Modularity**: Features encapsulated into self-contained modules
- **Extensibility**: Easy to add new allergen detection capabilities or user features
- **Reliability**: Robust error handling and fallback mechanisms
- **Performance**: Efficient processing even on older iOS devices

## Architecture Layers

### 1. Presentation Layer (Views)

The presentation layer consists of SwiftUI views that display information to the user and handle user interactions. Key aspects include:

- **View Organization**: Views are organized by feature (Restaurant, Camera, AllergenDetection, Profile, History)
- **Reusable Components**: Common UI elements are extracted into the Views/Common directory
- **UI State Management**: Views observe ViewModels via Combine publishers
- **Navigation**: Implemented using SwiftUI navigation with coordinators where necessary
- **Accessibility**: All views implement proper accessibility support

### 2. Application Layer (ViewModels)

The ViewModel layer contains the business logic of the application, mediating between Views and Services:

- **ViewModels**: Provide data and commands to Views
- **State Transformation**: Process raw data into view-ready formats
- **User Interactions**: Handle user input and trigger appropriate actions
- **Validation**: Validate user input before processing
- **Error Handling**: Provide user-friendly error messages

### 3. Domain Layer (Services)

The service layer implements the core functionality of the application:

- **CameraService**: Handles camera access, configuration, and image capture
- **OCRService**: Performs text recognition on menus and ingredient labels
- **AllergenService**: Detects allergens in menu items and ingredients
- **MenuParsingService**: Identifies menu structure, items, and descriptions
- **SubstitutionService**: Recommends viable substitutions for allergen-containing items
- **RestaurantService**: Manages restaurant information and menu databases
- **StorageService**: Manages persistence of user data and scan history
- **PermissionService**: Handles system permission requests and status

### 4. Data Layer (Models)

The data layer defines the core data structures and persistence mechanisms:

- **Core Data**: Used for persistent storage of user profiles, restaurant data, and scan history
- **Data Models**: Swift structs/classes that define the application's data structures
- **Data Transfer Objects**: Used for exchanging data between layers
- **Data Validation**: Ensures data integrity at the model level

## Key Components

### AppState

Central state management for the application:

- Maintains global application state
- Implemented as an ObservableObject
- Injected into the view hierarchy via EnvironmentObject
- Facilitates communication between unrelated components

### Service Registry

A central registry for accessing services:

- Provides access to all services from anywhere in the app
- Manages service lifecycles
- Facilitates dependency injection for testing
- Follows the Service Registration Rule to ensure proper service discovery

### Menu Processing Pipeline

The core functionality of the app follows this process:

1. Camera captures image of restaurant menu
2. OCR processes image to extract text
3. Menu parsing identifies items, descriptions, and ingredients
4. Items are matched against user's allergen profile
5. Safe items are highlighted and unsafe items are flagged
6. Substitution recommendations are generated for unsafe items
7. Filtered menu is presented to the user with confidence indicators
8. User reviews and can adjust results before making decisions

This pipeline implements several safety and performance rules:
- OCR Performance Benchmark Rule ensures processing is efficient
- Menu Recognition Validation Rule maintains accurate text extraction
- User Validation Opportunity Rule allows users to verify critical information
- Confidence Visualization Rule communicates result reliability
- Progressive Loading Pattern Rule provides immediate feedback

### Ingredient Label Processing Pipeline

The secondary functionality for packaged foods:

1. Camera captures image of ingredient label
2. OCR processes image to extract text
3. Text is parsed to identify ingredients
4. Ingredients are matched against user's allergen profile
5. Matching allergens are highlighted to the user
6. User reviews and can adjust results before making decisions

## Cross-Cutting Concerns

### Error Handling

- Centralized error types defined in ErrorTypes.swift
- Consistent error handling patterns across the app
- User-friendly error messages with recovery options
- Appropriate logging of errors for debugging
- Safety Warning Consistency Rule ensures clear presentation of allergen warnings
- Graceful degradation for handling processing failures

### Configuration

- Feature flags for enabling/disabling features
- Environment-specific configuration
- User preferences management
- Feature Flag Consistency Rule enables granular feature control

### Localization

- All user-facing strings are localized
- Support for multiple languages and regions
- Culturally appropriate allergen matching and menu interpretation

### Accessibility

- VoiceOver support for all screens
- Dynamic Type for text scaling
- Appropriate contrast ratios
- Haptic feedback for important alerts
- UI Component Consistency Rule ensures consistent accessible design

## Technology Stack

- **UI Framework**: SwiftUI
- **Data Binding**: Combine framework
- **Persistence**: Core Data
- **OCR Technology**: Vision framework
- **Image Processing**: Core Image
- **Machine Learning**: Core ML (for enhanced allergen detection and menu parsing)
- **Animation**: SwiftUI animations with Lottie for complex animations
- **Dependencies**: Swift Package Manager
- **Networking**: Async/await for API calls to restaurant databases

## Data Persistence Strategy

Core Data operations follow the Core Data Concurrency Rule:
- View contexts for UI-related operations
- Background contexts for intensive operations
- Proper merging of contexts to prevent threading issues
- Careful transaction management for database integrity

## Offline Strategy

AllerGuard implements the Offline Functionality Verification Rule:
- All critical features work without network connectivity
- Local database for allergen and ingredient information
- Proper caching of restaurant information when available
- Clear indication when features require connectivity

## Future Architectural Considerations

- Potential migration to Swift Data when appropriate
- Integration with restaurant APIs for enhanced menu information
- Server-side components for allergen database and restaurant menu updates
- Apple Watch companion app for quick scanning and allergen alerts 