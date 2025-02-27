# AllerGuard AI Development Instructions

Please follow these instructions in all of your responses if relevant:

## Architecture & Structure
- Follow MVVM architecture for all features to ensure separation of concerns
- Use protocol-oriented programming to define interfaces and behaviors
- Implement dependency injection for loosely coupled and testable components
- Organize code into folders like Models, Views, ViewModels, and Services

## Coding Standards
- Use meaningful names for variables and functions (e.g., `userName` instead of `uN`)
- Comment complex logic or algorithms to improve readability
- Handle errors gracefully using try, catch, and throws
- Use guard statements for early exits when conditions aren't met
- Avoid forced unwrapping of optionals; use optional binding or guard instead
- Close resources like files and network connections properly

## Swift Best Practices
- Use property wrappers (e.g., @Published) to add behavior to properties
- Implement lazy initialization for resource-intensive properties
- Use Codable for JSON serialization and deserialization
- Adopt async/await for cleaner asynchronous code
- Use weak or unowned references in closures to avoid retain cycles
- Leverage tuple destructuring for concise code (e.g., let (x, y) = point)
- Use the nil coalescing operator (??) for providing default values
- Employ enums with associated values for state management

## SwiftUI Specific Guidelines
- Update UI elements only on the main thread to prevent crashes
- Minimize view body recalculations by using appropriate property wrappers
- Use lazy stacks and containers for performance-intensive views
- Implement custom ViewModifiers for reusable styling
- Apply animations consistently using withAnimation or animation modifiers
- Structure complex views using ViewBuilder and container views

## Performance & Optimization
- Profile with Instruments to identify and address bottlenecks
- Store image paths rather than raw data in Core Data
- Perform intensive operations (especially OCR and ML) on background threads
- Use efficient data structures and algorithms for allergen matching
- Implement caching for frequently accessed data
- Optimize camera and AR features for battery efficiency

## User Experience
- Follow Apple's Human Interface Guidelines for a consistent experience
- Support dark mode and adapt UI elements accordingly
- Ensure accessibility by supporting VoiceOver and high contrast modes
- Provide haptic feedback for important alerts and confirmations
- Implement proper error states and recovery options
- Create smooth transitions between scanning, processing, and results screens

## Testing & Quality
- Write unit tests for all new logic using XCTest
- Implement UI tests to simulate user interactions
- Use mocking libraries to isolate dependencies in unit tests
- Aim for high test coverage to catch regressions early
- Verify accessibility support for all screens and features

## Health & Privacy Considerations
- Implement proper permission handling with clear user messaging
- Securely store allergen profiles and scan history
- Apply appropriate data protection for health-related information
- Provide clear privacy policies regarding data handling
- Support offline functionality for critical allergen detection

## Quality Control Process
- After generating or modifying code, scan for duplicate files, functions, or code blocks
- At major milestones, perform verification including linting and error checking
- Before creating new files or adding dependencies, request user approval
- Maintain a detailed log of all code changes
- Follow a structured workflow with planning, coding, testing, and reviewing phases

## AllerGuard Specific Guidelines
- Optimize camera stabilization for accurate ingredient label scanning
- Implement robust OCR with fallbacks for different label formats
- Create flexible allergen detection algorithms with user customization
- Design efficient data models for allergen profiles and scan history
- Implement clear, high-visibility alerts for detected allergens
- Support voice commands and announcements for hands-free operation 