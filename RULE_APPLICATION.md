# AllerGuard Rule Application Map

*Last Updated: February 27, 2025*

This document maps Cursor rules to specific features and components in AllerGuard, helping identify which rules are most relevant in different contexts.

## Core Features

### Restaurant Menu Scanning & Filtering

**Primary Rules:**
- #1 MVVM Architecture
- #14 Menu Recognition Validation
- #15 Substitution Algorithm Testing
- #16 OCR Performance Benchmark
- #19 Safety Warning Consistency
- #21 Progressive Loading Pattern
- #25 User Validation Opportunity
- #26 Confidence Visualization

**Secondary Rules:**
- #4 Swift Concurrency
- #11 Resource Optimization
- #17 Offline Functionality
- #18 Edge Case Database
- #20 Restaurant Data Freshness
- #22 Core Data Concurrency

**Code Areas:**
- `RestaurantMenuView`
- `RestaurantMenuViewModel`
- `MenuService`
- `OCRService` (menu-specific methods)
- `SubstitutionService`

### Camera Scanning

**Primary Rules:**
- #1 MVVM Architecture
- #4 Swift Concurrency 
- #8 Privacy Compliance
- #21 Progressive Loading Pattern

**Secondary Rules:**
- #5 Version Compatibility
- #11 Resource Optimization
- #12 UI Component Consistency

**Code Areas:**
- `CameraView`
- `CameraViewModel`
- `CameraService`
- `PermissionService` (camera permissions)

### OCR Processing

**Primary Rules:**
- #1 MVVM Architecture
- #4 Swift Concurrency
- #16 OCR Performance Benchmark
- #18 Edge Case Database
- #26 Confidence Visualization

**Secondary Rules:**
- #5 Version Compatibility
- #11 Resource Optimization
- #17 Offline Functionality
- #22 Core Data Concurrency

**Code Areas:**
- `OCRService`
- `TextRecognitionManager`
- `LanguageDetectionService`

### Allergen Detection

**Primary Rules:**
- #1 MVVM Architecture
- #15 Substitution Algorithm Testing
- #19 Safety Warning Consistency
- #25 User Validation Opportunity
- #26 Confidence Visualization

**Secondary Rules:**
- #17 Offline Functionality
- #18 Edge Case Database
- #22 Core Data Concurrency

**Code Areas:**
- `AllergenDetectionService`
- `AllergenMatchingAlgorithm`
- `IngredientParsingService`
- `AllergenDatabase`

### User Profiles

**Primary Rules:**
- #1 MVVM Architecture
- #8 Privacy Compliance
- #22 Core Data Concurrency

**Secondary Rules:**
- #3 Service Registration
- #17 Offline Functionality
- #12 UI Component Consistency

**Code Areas:**
- `ProfileView`
- `ProfileViewModel`
- `ProfileService`
- `AllergenProfileStore`

### Scan History

**Primary Rules:**
- #1 MVVM Architecture
- #11 Resource Optimization
- #20 Restaurant Data Freshness
- #22 Core Data Concurrency

**Secondary Rules:**
- #12 UI Component Consistency
- #17 Offline Functionality

**Code Areas:**
- `ScanHistoryView`
- `ScanHistoryViewModel`
- `ScanHistoryService`
- `MenuScanResult`
- `ProductScanResult`

## Enhanced Features (Phase 2)

### Allergen Education

**Primary Rules:**
- #1 MVVM Architecture
- #17 Offline Functionality
- #19 Safety Warning Consistency

**Secondary Rules:**
- #12 UI Component Consistency
- #22 Core Data Concurrency

**Code Areas:**
- `AllergenEducationView`
- `AllergenEducationViewModel`
- `AllergenInformationService`

### Emergency Contacts

**Primary Rules:**
- #1 MVVM Architecture
- #8 Privacy Compliance
- #17 Offline Functionality

**Secondary Rules:**
- #5 Version Compatibility
- #12 UI Component Consistency

**Code Areas:**
- `EmergencyContactsView`
- `EmergencyContactsViewModel`
- `EmergencyService`

### Alternative Suggestions

**Primary Rules:**
- #1 MVVM Architecture
- #15 Substitution Algorithm Testing
- #19 Safety Warning Consistency
- #25 User Validation Opportunity

**Secondary Rules:**
- #17 Offline Functionality
- #18 Edge Case Database

**Code Areas:**
- `AlternativeSuggestionsView`
- `AlternativeSuggestionsViewModel`
- `SubstitutionService`
- `AlternativeProductDatabase`

## Cross-Cutting Concerns

### App Architecture

**Primary Rules:**
- #1 MVVM Architecture
- #2 Code Organization
- #3 Service Registration
- #7 Phased Feature Integration
- #23 Feature Flag Consistency
- #24 Dependency Change Impact

**Code Areas:**
- `AppState`
- `ServiceRegistry`
- Project structure and organization

### Error Handling

**Primary Rules:**
- #19 Safety Warning Consistency
- #21 Progressive Loading Pattern
- #25 User Validation Opportunity
- #26 Confidence Visualization

**Secondary Rules:**
- #4 Swift Concurrency
- #12 UI Component Consistency

**Code Areas:**
- `ErrorTypes.swift`
- `ErrorHandlingManager`
- Error views and components

### Data Persistence

**Primary Rules:**
- #11 Resource Optimization
- #22 Core Data Concurrency

**Secondary Rules:**
- #17 Offline Functionality
- #20 Restaurant Data Freshness

**Code Areas:**
- `StorageService`
- Core Data model files
- Data migration code

### UI/UX

**Primary Rules:**
- #12 UI Component Consistency
- #19 Safety Warning Consistency
- #21 Progressive Loading Pattern
- #26 Confidence Visualization
- #27 Apple Platform Best Practices

**Secondary Rules:**
- #5 Version Compatibility
- #8 Privacy Compliance
- #28 Apple Architecture & Performance

**Code Areas:**
- Shared UI components
- Design system implementation
- Accessibility implementations
- Navigation controllers
- Appearance adapters

## Rule Application by File Pattern

- **View files (`*View.swift`)**: #1, #2, #12, #19, #21, #26, #27
- **ViewModel files (`*ViewModel.swift`)**: #1, #2, #4, #19, #21, #25, #26, #28
- **Service files (`*Service.swift`)**: #2, #3, #4, #6, #16, #17, #22, #24, #28
- **Core Data files**: #11, #22, #28
- **Test files**: #15, #16, #17, #18
- **Database files**: #11, #17, #18, #20
- **AppDelegate/SceneDelegate files**: #8, #27, #28
- **Resource files (assets, strings)**: #12, #27 