# AllerGuard Cursor Rules Summary

*Last Updated: March 12, 2025*

## Core Architecture Rules [P0]

**#1 MVVM Architecture Rule**: UI components must have corresponding ViewModels; Views contain only UI logic; ViewModels handle business logic; Models are plain data structures. Validate: Check for matching View-ViewModel pairs, no direct Service calls in Views, @Published properties in ViewModels.

**#2 Code Organization Rule**: Organize code in Models, Views, ViewModels, Services folders; group by feature; use consistent naming (e.g., ProfileView, ProfileViewModel); maintain UI/logic separation. Validate: Files in correct directories, consistent naming patterns, organized imports.

**#3 Service Registration Rule**: Register all services with ServiceRegistry; access via ServiceRegistry not direct creation; manage service lifecycles properly. Validate: Service registration calls present, services retrieved through registry, protocol-based approach followed.

## Swift & Development Rules [P1]

**#4 Swift Concurrency Rule**: Use async/await for async operations; manage Task lifecycles; use actors for shared mutable state; use MainActor for UI updates. Validate: No completion handler anti-patterns, proper async error handling, main thread UI updates.

**#5 Version Compatibility Rule**: Check API availability for iOS 14+; use availability checks for newer APIs; avoid deprecated APIs. Validate: No incompatible framework imports, proper availability guards, fallbacks for newer APIs.

**#6 Dependency Impact Assessment Rule**: Document purpose/scope of each dependency; evaluate alternatives; consider size/performance/maintenance. Validate: Justify new dependencies, check for duplicate functionality, verify pinned versions.

**#7 Phased Feature Integration Rule**: Implement features in isolation first; use feature flags for control; test independently before enabling. Validate: Features can toggle on/off, clean boundaries exist, no regression in existing functionality.

**#8 Privacy Compliance Rule**: Add proper usage descriptions for permissions; request only when needed; provide clear user benefit. Validate: Info.plist contains required descriptions, requests include explanations, graceful degradation when denied.

**#9 Documentation-Code Sync Rule**: Update docs with code changes; ensure comments reflect implementation; maintain accurate feature descriptions. Validate: Doc updates with code changes, correct code examples, accurate interface descriptions.

**#10 Branch Strategy Rule**: Create feature branches from main; use consistent naming; merge after review and tests. Validate: Branch names follow convention, branches updated before merging, tests pass pre-merge.

**#11 Resource Optimization Rule**: Use appropriate image formats/sizes; implement efficient caching; optimize database queries. Validate: Optimized assets, proper caching headers, efficient Core Data fetch requests.

**#12 UI Component Consistency Rule**: Follow Apple's Human Interface Guidelines; implement native iOS design patterns (navigation bar, tab bar, context menus); support Dynamic Type, Dark Mode, and accessibility; use SF Symbols for iconography; implement appropriate haptic feedback; follow iOS spacing/layout conventions. Validate: UI components match Apple's design system, support system appearances, implement proper navigation patterns, pass Accessibility Audit.

**#13 Incremental Build Rule**: Structure code to minimize rebuild time; avoid unnecessary dependencies; use proper access modifiers. Validate: Monitor build times, check for circular dependencies, verify public/internal/private access.

## Menu Processing Rules [P0]

**#14 Menu Recognition Validation Rule**: Test OCR against diverse menu dataset (fonts, layouts, languages); establish 90% minimum accuracy. Validate: Verify results against known content, test low-light/contrast conditions, handle multi-column and special characters.

**#15 Substitution Algorithm Testing Rule**: Create test suite for allergen substitutions; validate substitutions don't introduce cross-allergen risks; test against known-safe alternatives. Validate: Run engine against test cases, verify no cross-allergen introduction, ensure feasible restaurant substitutions.

## Testing & Performance Rules [P1]

**#16 OCR Performance Benchmark Rule**: Process standard menu under 3 seconds on iPhone 12; test on older devices; implement optimizations for slower devices. Validate: Time operations against benchmarks, monitor memory usage, ensure acceptable performance degradation.

**#17 Offline Functionality Rule**: Test all critical features in airplane mode; implement proper caching; provide clear feedback when connectivity required. Validate: Run core workflow offline, verify local data storage/retrieval, check appropriate offline messaging.

**#18 Edge Case Database Rule**: Maintain database of edge case menus/ingredients; include unusual formatting/ingredients/variants; test regularly. Validate: Run automated tests against edge cases, add new cases when failures found, verify fixes don't break other cases.

## UX & Safety Rules [P0]

**#19 Safety Warning Consistency Rule**: Define consistent visual language for warnings; use appropriate prominence for severity; place warnings consistently. Validate: Warning visuals match severity, consistent locations, proper emphasis for critical allergens.

**#20 Restaurant Data Freshness Rule**: Include "last verified" timestamp with restaurant data; display notices for outdated information; implement refresh mechanisms. Validate: Timestamp display in restaurant info, appropriate aging indicators, functional refresh mechanism.

**#21 Progressive Loading Pattern Rule**: Show immediate response for operations; implement progressive result refinement; provide clear progress indicators. Validate: UI responsiveness during scanning, appropriate progress indicators, progressive result display.

## Architecture & Integration Rules [P1]

**#22 Core Data Concurrency Rule**: Separate viewContext/backgroundContext usage; perform intensive operations in background; update UI from main thread only. Validate: Appropriate context usage, no main thread violations, proper background context merging.

**#23 Feature Flag Consistency Rule**: Implement consistent feature flag system; allow emergency disabling; manage visibility based on flags. Validate: New features use flag system, disabling flags hides functionality, flags persist across app restarts.

**#24 Dependency Change Impact Rule**: Analyze impact when modifying core services; perform regression testing on dependents; document dependencies clearly. Validate: Identify/test affected services, verify backward compatibility, ensure proper error handling.

## Safety & User Trust Rules [P0]

**#25 User Validation Opportunity Rule**: Allow users to review allergen detection results; provide manual correction options; distinguish system vs. user-validated info. Validate: Review screens exist, correction mechanisms available, proper storage of user-verified data.

**#26 Confidence Visualization Rule**: Consistently visualize confidence levels; use clear indicators for low/medium/high confidence; provide guidance based on confidence. Validate: Confidence indicators with results, appropriate guidance for low confidence, consistent calculation/display.

**#27 Apple Platform Best Practices Rule [P1]**: Use SwiftUI for new UI; follow UIKit patterns when needed; respect iOS lifecycle events; implement proper state restoration; support multitasking on iPad; handle interruptions (calls, notifications); support universal purchase when applicable. Validate: App responds correctly to lifecycle events, handles interruptions gracefully, maintains state appropriately, supports all target device families.

**#28 Apple Architecture & Performance Rule [P1]**: Follow Apple's recommended architecture patterns; use Swift concurrency over GCD; implement background tasks using BackgroundTasks framework; follow memory/battery usage guidelines; optimize for Metal rendering; use Instruments to profile performance; implement proper push notification handling. Validate: Use Instruments for memory/CPU profiling, follow Background Execution Guidelines, implement proper notification registration/handling, pass App Store Review Guidelines.

## Application Priority

When implementing these rules, follow this priority order:
1. P0: Health/safety-critical rules (1-3, 14-15, 19-21, 25-26)
2. P1: Architecture and performance rules (4-13, 16-18, 22-24, 27-28)

In case of rule conflicts, always prioritize user safety and data integrity over other concerns. 