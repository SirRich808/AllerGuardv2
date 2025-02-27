# AllerGuard Project Map

This document outlines the structure and purpose of different directories and key files in the AllerGuard project.

## Project Structure

```
AllerGuard/
├── AllerGuard/               # Main app code
│   ├── App/                  # App lifecycle and entry point
│   ├── Models/               # Data models and Core Data entities
│   ├── Views/                # SwiftUI views organized by feature
│   │   ├── Common/           # Reusable UI components
│   │   ├── Camera/           # Camera scanning interface
│   │   ├── AllergenDetection/# Allergen detection results UI
│   │   ├── Profile/          # User profile management
│   │   └── History/          # Scan history views
│   ├── ViewModels/           # View models organized by feature
│   │   ├── Camera/           # Camera functionality logic
│   │   ├── AllergenDetection/# Allergen detection logic
│   │   ├── Profile/          # Profile management logic
│   │   └── History/          # Scan history management
│   ├── Services/             # Service layer
│   │   ├── CameraService/    # Camera access and configuration
│   │   ├── OCRService/       # Optical character recognition
│   │   ├── AllergenService/  # Allergen detection and matching
│   │   ├── StorageService/   # Core Data and persistence
│   │   └── PermissionService/# Permission handling
│   ├── Utilities/            # Helper functions and extensions
│   ├── Resources/            # Assets and resource files
│   └── Configuration/        # App configuration files
├── AllerGuardTests/          # Unit tests
├── AllerGuardUITests/        # UI tests
└── Docs/                     # Project documentation
    ├── APIs/                 # API interface documentation
    ├── Features/             # Feature specifications
    └── Snippets/             # Code snippets and patterns
```

## Key Files

- `AllerGuard/App/AppState.swift` - Global app state management
- `AllerGuard/App/AllerGuardApp.swift` - Main app entry point
- `AllerGuard/Models/AllergenProfile.swift` - Core data models for allergen profiles
- `AllerGuard/Services/OCRService/OCRService.swift` - Vision framework OCR implementation
- `AllerGuard/Services/AllergenService/AllergenDetector.swift` - Allergen matching logic

## Documentation Files

- `ARCHITECTURE.md` - High-level architecture documentation
- `DEVELOPMENT_STATUS.md` - Current development status and next steps
- `DECISIONS.md` - Record of architectural decisions
- `FEATURES.md` - Feature descriptions and boundaries
- `ROADMAP.md` - Development roadmap and priorities
- `SERVICE_REGISTRY.md` - Documentation of all services
- `STATE_MANAGEMENT.md` - State management approach
- `ERROR_HANDLING.md` - Error handling strategies
- `TEST_COVERAGE.md` - Test coverage reporting
- `STYLE_GUIDE.md` - Code style guidelines

## Rule Files

- `.cursor/rules/allerguard-rules.mdc` - General AllerGuard development rules
- `.cursor/rules/swiftui-performance-rule.mdc` - SwiftUI performance optimization rules
- `.cursor/rules/security-privacy-rule.mdc` - Security and privacy best practices
- `.cursor/rules/session-continuity-rule.mdc` - Rules for maintaining continuity across sessions
- `.cursor/custom_instructions.md` - AI assistant instructions

## Purpose and Ownership

| Directory/File | Purpose | Owner |
|----------------|---------|-------|
| Models/ | Core data entities and data structures | Core Team |
| Views/ | User interface components | UI Team |
| ViewModels/ | Business logic and data transformation | Logic Team |
| Services/ | Core functionality and external integrations | Services Team |
| Utilities/ | Helper functions and extensions | Shared |
| Configuration/ | App settings and configuration | Core Team |
| Tests/ | Test suites and mocks | QA Team | 