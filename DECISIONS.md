# AllerGuard Architectural Decisions Log

*Last Updated: February 27, 2025*

This document records significant architectural decisions made during the development of AllerGuard, including context, alternatives considered, and rationale.

## ADR-001: MVVM Architecture

**Date**: February 27, 2025

**Decision**: Adopt Model-View-ViewModel (MVVM) architecture for the AllerGuard application.

**Context**: 
- AllerGuard needs a clean separation of concerns
- The app has complex business logic for allergen detection
- UI components need to be testable
- SwiftUI is the chosen UI framework

**Alternatives Considered**:
1. MVC (Model-View-Controller): Too much logic tends to end up in controllers, making them difficult to test
2. Clean Architecture: Adds more complexity than needed for this size of application
3. Redux/Elm-like architecture: More complex state management than required

**Decision Rationale**:
- MVVM works well with SwiftUI's data flow model
- Clear separation between UI (Views) and business logic (ViewModels)
- Facilitates unit testing by isolating view logic in testable ViewModels
- Scales well as features are added
- Team has experience with MVVM

**Consequences**:
- All features must follow the MVVM pattern for consistency
- Need to establish clear rules for ViewModel-to-ViewModel communication
- Need to define state management approach within this architecture

---

## ADR-002: Core Data for Persistence

**Date**: February 27, 2025

**Decision**: Use Core Data for persistent storage of user profiles, allergen data, and scan history.

**Context**:
- Need to store user allergen profiles
- Need to maintain scan history with relationships to profiles
- Need to store allergen database with complex relationships
- Need to support offline functionality

**Alternatives Considered**:
1. SQLite direct: Would require more boilerplate code
2. UserDefaults: Not suitable for complex data or relationships
3. FileSystem (JSON/Plist): Lacks querying capabilities
4. Swift Data: New and not fully mature yet

**Decision Rationale**:
- Core Data provides robust data modeling with relationships
- Offers good performance for the expected data size
- Supports complex queries needed for allergen matching
- Has well-established migration paths for future schema changes
- Team has experience with Core Data

**Consequences**:
- Need to design Core Data model carefully upfront
- Need to implement proper error handling for Core Data operations
- Should create abstraction layer to isolate Core Data implementation details
- Must monitor memory usage with large scan histories

---

## ADR-003: Vision Framework for OCR

**Date**: February 27, 2025

**Decision**: Use Apple's Vision framework for Optical Character Recognition of ingredient labels.

**Context**:
- Need to extract text from ingredient labels
- Labels can have varying formats, fonts, and layouts
- Processing should work offline
- Need high accuracy for health-critical information

**Alternatives Considered**:
1. Google ML Kit: Requires Google dependencies, may need online access
2. Tesseract OCR: Heavier, more complex to integrate
3. Custom ML model: Would require training and expertise
4. Third-party OCR services: Would require network connection

**Decision Rationale**:
- Vision framework is built into iOS with no additional dependencies
- VNRecognizeTextRequest offers good accuracy for printed text
- Works completely offline
- Integrates well with iOS camera system
- Regular improvements from Apple with OS updates

**Consequences**:
- Limited to iOS 13+ devices
- Need to build custom post-processing for ingredient formats
- Must handle various languages and character sets
- Need to implement confidence thresholds and error recovery

---

## ADR-004: Service-Based Architecture

**Date**: February 27, 2025

**Decision**: Implement a service layer with clear interfaces and dependency injection.

**Context**:
- Need to organize core functionality into manageable components
- Multiple features will share common services
- Need to support unit testing with mock services
- Need to maintain clean separation between UI and business logic

**Alternatives Considered**:
1. Singleton-based utilities: Less testable, tighter coupling
2. Direct component-to-component communication: Creates tight coupling
3. Event-based architecture: More complex for core functionality

**Decision Rationale**:
- Service interfaces promote loose coupling between components
- Facilitates unit testing through dependency injection
- Provides clear ownership of functionality
- Makes it easier to replace implementations in the future
- Centralizes core functionality in discoverable locations

**Consequences**:
- Need to define clear service responsibilities
- Must implement proper service registration and discovery
- Need to manage service lifecycles
- Need to document service interfaces

---

## ADR-005: AppState for Global State Management

**Date**: February 27, 2025

**Decision**: Create a central AppState object for managing global application state.

**Context**:
- Some state needs to be shared across features
- Need to track global app status (scanning, processing, etc.)
- Need to handle navigation between different parts of the app
- Need to coordinate between otherwise unrelated components

**Alternatives Considered**:
1. No global state, all local: Would lead to duplicate state and sync issues
2. Redux-style global store: More complex than needed
3. Service-to-service communication: Could create circular dependencies

**Decision Rationale**:
- AppState provides single source of truth for important global state
- ObservableObject works well with SwiftUI's environment
- Centralizes global state in one discoverable location
- Minimizes prop drilling through view hierarchy
- Simpler than full Redux-style architecture

**Consequences**:
- Need to carefully consider what belongs in global vs. local state
- Need to document AppState properties and usage patterns
- Must avoid making AppState a "catch-all" for any state
- Need clear patterns for modifying global state

---

## ADR-006: Protocol-Based Services

**Date**: February 27, 2025

**Decision**: Define all services using protocols with concrete implementations.

**Context**:
- Need to be able to mock services for testing
- Services should have clearly defined interfaces
- Different implementations may be needed (e.g. for testing)
- Need to support dependency injection

**Alternatives Considered**:
1. Concrete classes only: Makes testing harder
2. Functional approach: Less structured organization
3. Class inheritance for services: Less flexible than protocols

**Decision Rationale**:
- Protocols define clear contracts for services
- Enables easy mocking for unit tests
- Provides flexibility to swap implementations
- Supports Swift's protocol-oriented programming model
- Makes dependencies explicit

**Consequences**:
- Need to define protocols carefully upfront
- Requires more initial code than direct implementation
- Must ensure protocol requirements are stable over time
- Need to document protocol interfaces and expected behavior

---

## ADR-007: Core Data for Allergen Database vs. Custom Format

**Date**: February 27, 2025

**Decision**: Store allergen database in Core Data rather than a custom format.

**Context**:
- Need to store a comprehensive database of allergens
- Database includes complex relationships (allergens → categories → variants → ingredients)
- Need efficient querying for allergen detection
- Database will be occasionally updated

**Alternatives Considered**:
1. JSON file bundled with app: Simpler but less queryable
2. SQLite database directly: Would require custom query layer
3. Plist file: Limited for complex relationships
4. Remote database with API: Would limit offline functionality

**Decision Rationale**:
- Core Data provides robust querying capabilities
- Can leverage existing Core Data stack
- Supports complex relationships needed for allergen hierarchies
- Provides migration path for database updates
- Can be prepopulated from a seed file during first launch

**Consequences**:
- Need to design allergen data model carefully
- Must implement efficient import/update mechanism
- Database size must be monitored
- Need to consider performance of common queries

---

## ADR-008: SwiftUI for UI Implementation

**Date**: February 27, 2025

**Decision**: Use SwiftUI as the primary UI framework with UIKit integration where necessary.

**Context**:
- Need a modern, maintainable UI architecture
- App has complex UI for scan results and allergen details
- Need to support iOS 14+ devices
- Camera integration required

**Alternatives Considered**:
1. Pure UIKit: More verbose, less declarative
2. Mixed UIKit/SwiftUI with UIKit as primary: More complex integration
3. Third-party UI frameworks: Unnecessary additional dependencies

**Decision Rationale**:
- SwiftUI provides declarative, concise UI code
- Integrates well with MVVM architecture
- Offers good performance for most UI needs
- Can integrate UIKit components where needed (camera, complex interactions)
- Simpler to maintain and iterate on

**Consequences**:
- Camera view will require UIViewRepresentable wrapper
- May encounter SwiftUI limitations for complex interactions
- Need to establish patterns for UIKit integration
- Minimum deployment target must be iOS 14+

---

## ADR-009: Combine for Reactive Programming

**Date**: February 27, 2025

**Decision**: Use Combine framework for reactive programming needs.

**Context**:
- Need to handle asynchronous events (permission changes, camera events)
- Need to bind ViewModels to Views
- Need to transform and combine data streams
- Need to handle cancellation

**Alternatives Considered**:
1. Callback closures: More verbose, harder to compose
2. RxSwift: Additional external dependency
3. Async/await only: Less suitable for ongoing event streams
4. Notification Center: More limited functionality

**Decision Rationale**:
- Combine is built into iOS with no additional dependencies
- Works well with SwiftUI's observation model
- Provides powerful operators for transforming data streams
- Has good cancellation support
- Team has experience with reactive programming patterns

**Consequences**:
- Need to ensure proper cancellation to prevent memory leaks
- Learning curve for developers new to reactive programming
- Must establish patterns for error handling in Combine chains
- Need to consider performance for high-frequency publishers

---

## ADR-010: Offline-First Approach

**Date**: February 27, 2025

**Decision**: Design AllerGuard as an offline-first application.

**Context**:
- App will be used in grocery stores which may have poor connectivity
- Core allergen detection functionality is critical for user safety
- Users may need access to scan history without connectivity
- Future versions may add online functionality

**Alternatives Considered**:
1. Online-required for some features: Would limit core functionality
2. Hybrid approach with degraded functionality offline: More complex
3. Different modes for online/offline: Confusing user experience

**Decision Rationale**:
- Ensures core functionality works reliably regardless of connectivity
- Better user experience with consistent functionality
- Simpler architecture without online/offline mode switching
- Allows future addition of online features as enhancements
- Provides better privacy with local processing

**Consequences**:
- Must bundle initial allergen database with the app
- Updates to allergen database must be managed carefully
- All core processing must work locally on device
- Future online features must be designed as enhancements, not requirements

---

## ADR-016: Restaurant Menu Scanning as Primary Feature

**Date**: February 27, 2025

**Decision**: Position restaurant menu scanning and filtering as the primary feature of AllerGuard, while maintaining all other planned functionality.

**Context**:
- Need to establish a clear, compelling value proposition for users
- People with food allergies face significant challenges when dining out
- Restaurant menus often lack clear allergen information
- Users need personalized menu recommendations based on their specific allergen profiles
- The app already planned to include both product scanning and menu scanning capabilities

**Alternatives Considered**:
1. Equal emphasis on packaged food scanning and restaurant menu scanning
2. Primary focus on packaged food labels with restaurant scanning as a secondary feature
3. Developing two separate apps for different use cases

**Decision Rationale**:
- Restaurant dining presents a higher-anxiety situation for allergy sufferers
- Greater market differentiation as most competitors focus primarily on packaged foods
- Restaurant menu scanning offers more immediate value in high-stakes decisions
- Menu substitution recommendations provide unique value beyond simple allergen identification
- Maintains the comprehensive allergen management approach while clarifying primary use case

**Consequences**:
- UI and UX must prioritize restaurant menu scanning workflows
- Need to develop more sophisticated menu parsing algorithms
- Restaurant database and menu structure recognition become critical components
- Substitution recommendation engine needs to be robust and personalized
- All documentation and marketing materials need to emphasize this primary use case
- Product scanning remains important but positioned as complementary to restaurant features
- Onboarding flow should highlight restaurant scanning capabilities first 