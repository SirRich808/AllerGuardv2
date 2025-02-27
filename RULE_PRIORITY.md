# AllerGuard Rule Priority Matrix

*Last Updated: February 27, 2025*

This document provides a prioritized view of AllerGuard's Cursor rules to help quickly identify which rules should take precedence when making implementation decisions.

## P0: Critical Rules (Health & Safety Impact)

These rules directly impact user health and safety and must never be compromised:

1. **MVVM Architecture Rule** (#1) - Ensures consistent separation of concerns for reliable, testable code
2. **Code Organization Rule** (#2) - Maintains codebase clarity and prevents crucial logic from being misplaced
3. **Service Registration Rule** (#3) - Ensures services critical to app function are properly accessible
4. **Menu Recognition Validation Rule** (#14) - Ensures accurate menu scanning to prevent allergen misidentification
5. **Substitution Algorithm Testing Rule** (#15) - Prevents dangerous substitution recommendations
6. **Safety Warning Consistency Rule** (#19) - Ensures users receive clear warnings about potential allergens
7. **Restaurant Data Freshness Rule** (#20) - Prevents decisions based on outdated restaurant information
8. **Progressive Loading Pattern Rule** (#21) - Ensures users always have feedback during critical operations
9. **User Validation Opportunity Rule** (#25) - Allows users to verify and correct critical health information
10. **Confidence Visualization Rule** (#26) - Communicates result reliability for informed user decisions

## P1: Architecture & Performance Rules

These rules ensure the application functions correctly and efficiently:

1. **Swift Concurrency Rule** (#4) - Prevents threading issues that could cause instability
2. **Version Compatibility Rule** (#5) - Ensures app works on supported devices
3. **Dependency Impact Assessment Rule** (#6) - Prevents problematic dependencies
4. **Phased Feature Integration Rule** (#7) - Ensures features are stable before integration
5. **Privacy Compliance Rule** (#8) - Maintains compliance with Apple's policies
6. **OCR Performance Benchmark Rule** (#16) - Ensures responsive performance for core functionality
7. **Offline Functionality Rule** (#17) - Ensures critical functions work without connectivity
8. **Edge Case Database Rule** (#18) - Maintains robustness against unusual inputs
9. **Core Data Concurrency Rule** (#22) - Prevents data corruption and crashes
10. **Feature Flag Consistency Rule** (#23) - Enables problematic feature isolation
11. **Dependency Change Impact Rule** (#24) - Prevents regressions from service changes
12. **Apple Platform Best Practices Rule** (#27) - Ensures compliance with iOS platform guidelines
13. **Apple Architecture & Performance Rule** (#28) - Optimizes app for iOS architecture patterns

## P2: Quality & Maintenance Rules

These rules improve code quality and maintainability:

1. **Documentation-Code Sync Rule** (#9) - Keeps documentation accurate
2. **Branch Strategy Rule** (#10) - Maintains clean development process
3. **Resource Optimization Rule** (#11) - Improves performance and reduces resource usage
4. **UI Component Consistency Rule** (#12) - Ensures consistent user experience
5. **Incremental Build Rule** (#13) - Improves development efficiency

## Conflict Resolution Matrix

When rules conflict, resolve according to this hierarchy:

1. User safety (P0 health/safety rules) always takes precedence
2. Functional correctness (P1 rules) takes precedence over optimization (P2 rules)
3. Within the same priority level:
   - Rules with wider system impact take precedence over localized rules
   - Rules affecting allergen detection take precedence over general UI rules
   - Runtime behavior takes precedence over build-time concerns

## Rule Enforcement by Development Phase

### Planning Phase
- Apply rules #1, #2, #3, #6, #7, #23, #27, #28

### Implementation Phase
- Apply rules #4, #5, #8, #11, #12, #13, #14, #15, #16, #19, #21, #22, #24, #25, #26, #27, #28

### Testing Phase
- Apply rules #9, #17, #18, #20, #27, #28

### Release Phase
- Verify all rules have been followed, with special audit of P0 rules and Apple platform compliance (#27, #28) 