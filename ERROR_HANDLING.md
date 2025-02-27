# AllerGuard Error Handling

*Last Updated: February 27, 2025*

This document outlines the error handling strategy for AllerGuard, including error types, recovery mechanisms, and user communication.

## Error Handling Principles

1. **User-Centric**: Errors are presented in user-friendly language
2. **Recoverable When Possible**: Offer recovery paths when available
3. **Fail Gracefully**: Degrade functionality rather than crash
4. **Informative**: Provide enough information for troubleshooting
5. **Consistent**: Handle similar errors in similar ways
6. **Proactive**: Validate early to prevent errors
7. **Safety-First**: Prioritize user safety in health-critical contexts

## Error Types

### Core Error Types

#### AppError

Base protocol for app-specific errors:

```swift
protocol AppError: Error, Identifiable {
    var id: UUID { get }
    var title: String { get }
    var message: String { get }
    var recoverySuggestion: String? { get }
    var isRecoverable: Bool { get }
    var severityLevel: ErrorSeverity { get }
}
```

Default implementation:

```swift
extension AppError {
    var id: UUID {
        UUID()
    }
    
    var isRecoverable: Bool {
        recoverySuggestion != nil
    }
    
    var severityLevel: ErrorSeverity {
        .medium
    }
}
```

Added `severityLevel` to support the Safety Warning Consistency Rule, ensuring that errors related to health concerns are properly emphasized.

#### ErrorSeverity

New enum to classify error severity:

```swift
enum ErrorSeverity {
    case low      // Information, non-critical
    case medium   // Standard errors, may impact functionality
    case high     // Serious errors requiring attention
    case critical // Health-safety related errors
    
    var requiresAcknowledgment: Bool {
        self == .high || self == .critical
    }
}
```

#### ErrorWrapper

A wrapper for system errors to conform to AppError:

```swift
struct ErrorWrapper: AppError {
    let error: Error
    let title: String
    let message: String
    let recoverySuggestion: String?
    let severityLevel: ErrorSeverity
    
    init(error: Error, title: String, message: String, recoverySuggestion: String? = nil, severityLevel: ErrorSeverity = .medium) {
        self.error = error
        self.title = title
        self.message = message
        self.recoverySuggestion = recoverySuggestion
        self.severityLevel = severityLevel
    }
}
```

### Feature-Specific Errors

#### CameraError

```swift
enum CameraError: AppError {
    case notAuthorized
    case setupFailed(Error)
    case captureFailed(Error)
    case noDeviceAvailable
    
    var title: String {
        switch self {
        case .notAuthorized:
            return "Camera Access Required"
        case .setupFailed:
            return "Camera Setup Failed"
        case .captureFailed:
            return "Image Capture Failed"
        case .noDeviceAvailable:
            return "No Camera Available"
        }
    }
    
    var message: String {
        switch self {
        case .notAuthorized:
            return "AllerGuard needs camera access to scan ingredients and menus."
        case .setupFailed:
            return "There was a problem setting up the camera."
        case .captureFailed:
            return "Could not capture the image. Please try again."
        case .noDeviceAvailable:
            return "No camera was detected on your device."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .notAuthorized:
            return "Please grant camera access in Settings."
        case .setupFailed:
            return "Try restarting the app."
        case .captureFailed:
            return "Try again or use a different lighting condition."
        case .noDeviceAvailable:
            return nil
        }
    }
}
```

#### OCRError

```swift
enum OCRError: AppError {
    case recognitionFailed(Error)
    case noTextFound
    case lowConfidence
    case unsupportedLanguage
    
    var title: String {
        switch self {
        case .recognitionFailed:
            return "Text Recognition Failed"
        case .noTextFound:
            return "No Text Found"
        case .lowConfidence:
            return "Text Recognition Uncertain"
        case .unsupportedLanguage:
            return "Unsupported Language"
        }
    }
    
    var message: String {
        switch self {
        case .recognitionFailed:
            return "There was a problem recognizing text from the image."
        case .noTextFound:
            return "No text could be found in the image."
        case .lowConfidence:
            return "The text was recognized with low confidence."
        case .unsupportedLanguage:
            return "The language detected is not currently supported."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .recognitionFailed:
            return "Try again with better lighting or focus."
        case .noTextFound:
            return "Ensure the text is visible and well-lit."
        case .lowConfidence:
            return "Please check the results carefully or try scanning again."
        case .unsupportedLanguage:
            return "Try scanning text in one of the supported languages."
        }
    }
}
```

#### AllergenError

```swift
enum AllergenError: AppError {
    case detectionFailed(Error)
    case noIngredientsFound
    case ingredientParsingFailed
    case databaseUpdateFailed
    
    var title: String {
        switch self {
        case .detectionFailed:
            return "Allergen Detection Failed"
        case .noIngredientsFound:
            return "No Ingredients Found"
        case .ingredientParsingFailed:
            return "Ingredient Parsing Failed"
        case .databaseUpdateFailed:
            return "Allergen Database Update Failed"
        }
    }
    
    var message: String {
        switch self {
        case .detectionFailed:
            return "There was a problem detecting allergens."
        case .noIngredientsFound:
            return "No ingredients could be identified in the text."
        case .ingredientParsingFailed:
            return "The ingredients could not be properly parsed."
        case .databaseUpdateFailed:
            return "The allergen database could not be updated."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .detectionFailed:
            return "Try scanning again with a clearer image."
        case .noIngredientsFound:
            return "Ensure you are scanning an ingredient list."
        case .ingredientParsingFailed:
            return "Try scanning again or manually check ingredients."
        case .databaseUpdateFailed:
            return "Check your internet connection and try again later."
        }
    }
}
```

#### StorageError

```swift
enum StorageError: AppError {
    case saveFailed(Error)
    case fetchFailed(Error)
    case deleteFailed(Error)
    case modelNotFound
    case corruptData
    
    var title: String {
        switch self {
        case .saveFailed:
            return "Save Failed"
        case .fetchFailed:
            return "Fetch Failed"
        case .deleteFailed:
            return "Delete Failed"
        case .modelNotFound:
            return "Data Not Found"
        case .corruptData:
            return "Corrupt Data"
        }
    }
    
    var message: String {
        switch self {
        case .saveFailed:
            return "Could not save your data."
        case .fetchFailed:
            return "Could not retrieve your data."
        case .deleteFailed:
            return "Could not delete the requested data."
        case .modelNotFound:
            return "The requested data could not be found."
        case .corruptData:
            return "The data appears to be corrupt."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .saveFailed:
            return "Try again later."
        case .fetchFailed:
            return "Try restarting the app."
        case .deleteFailed:
            return "Try again later."
        case .modelNotFound:
            return nil
        case .corruptData:
            return "You may need to reset the affected data."
        }
    }
}
```

#### MenuScanError

```swift
enum MenuScanError: AppError {
    case menuParsingFailed(Error)
    case noMenuItemsFound
    case menuStructureUnrecognized
    case restaurantNotFound
    case filteringFailed
    case substitutionGenerationFailed
    case lowConfidenceResults
    case potentialCrossContamination
    
    var title: String {
        switch self {
        case .menuParsingFailed:
            return "Menu Parsing Failed"
        case .noMenuItemsFound:
            return "No Menu Items Found"
        case .menuStructureUnrecognized:
            return "Menu Structure Not Recognized"
        case .restaurantNotFound:
            return "Restaurant Not Found"
        case .filteringFailed:
            return "Menu Filtering Failed"
        case .substitutionGenerationFailed:
            return "Substitution Generation Failed"
        case .lowConfidenceResults:
            return "Low Confidence Results"
        case .potentialCrossContamination:
            return "Cross-Contamination Risk"
        }
    }
    
    var message: String {
        switch self {
        case .menuParsingFailed:
            return "There was a problem parsing the menu structure."
        case .noMenuItemsFound:
            return "No menu items could be identified in the scan."
        case .menuStructureUnrecognized:
            return "The menu format could not be recognized."
        case .restaurantNotFound:
            return "The restaurant information could not be found."
        case .filteringFailed:
            return "Could not filter menu items based on your allergen profile."
        case .substitutionGenerationFailed:
            return "Could not generate substitution suggestions."
        case .lowConfidenceResults:
            return "The menu analysis has low confidence. Please review results carefully."
        case .potentialCrossContamination:
            return "Some menu items may have cross-contamination risk with your allergens."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .menuParsingFailed:
            return "Try scanning the menu again with better lighting or angle."
        case .noMenuItemsFound:
            return "Ensure you are scanning a menu and try again."
        case .menuStructureUnrecognized:
            return "Try scanning a different section of the menu or scan item by item."
        case .restaurantNotFound:
            return "Try searching for the restaurant manually or add it to your favorites."
        case .filteringFailed:
            return "Try updating your allergen profile or scan again."
        case .substitutionGenerationFailed:
            return "Check your internet connection or try again later."
        case .lowConfidenceResults:
            return "Verify ingredients directly with restaurant staff before ordering."
        case .potentialCrossContamination:
            return "Ask restaurant staff about their allergen handling practices."
        }
    }
    
    var severityLevel: ErrorSeverity {
        switch self {
        case .potentialCrossContamination:
            return .critical
        case .lowConfidenceResults:
            return .high
        case .menuParsingFailed, .noMenuItemsFound, .menuStructureUnrecognized:
            return .medium
        default:
            return .medium
        }
    }
}
```

Added cases and severity levels to support the Safety Warning Consistency Rule and Confidence Visualization Rule.

#### RestaurantError

```swift
enum RestaurantError: AppError {
    case searchFailed(Error)
    case detailsFetchFailed(Error)
    case menuFetchFailed(Error)
    case saveFailed(Error)
    case locationUnavailable
    case outdatedInformation(Date)
    
    var title: String {
        switch self {
        case .searchFailed:
            return "Restaurant Search Failed"
        case .detailsFetchFailed:
            return "Restaurant Details Failed"
        case .menuFetchFailed:
            return "Menu Fetch Failed"
        case .saveFailed:
            return "Save Restaurant Failed"
        case .locationUnavailable:
            return "Location Unavailable"
        case .outdatedInformation:
            return "Outdated Restaurant Information"
        }
    }
    
    var message: String {
        switch self {
        case .searchFailed:
            return "Could not search for restaurants."
        case .detailsFetchFailed:
            return "Could not retrieve restaurant details."
        case .menuFetchFailed:
            return "Could not retrieve the restaurant's menu."
        case .saveFailed:
            return "Could not save the restaurant to favorites."
        case .locationUnavailable:
            return "Your current location is unavailable."
        case .outdatedInformation(let date):
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return "Restaurant information was last updated on \(formatter.string(from: date))."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .searchFailed:
            return "Check your internet connection and try again."
        case .detailsFetchFailed:
            return "Try again later or search for a different restaurant."
        case .menuFetchFailed:
            return "Try scanning the physical menu instead."
        case .saveFailed:
            return "Try again later."
        case .locationUnavailable:
            return "Enable location services for AllerGuard in Settings."
        case .outdatedInformation:
            return "This information may not be current. Consider verifying with restaurant staff."
        }
    }
    
    var severityLevel: ErrorSeverity {
        switch self {
        case .outdatedInformation:
            return .high
        default:
            return .medium
        }
    }
}
```

Added `outdatedInformation` case to support the Restaurant Data Freshness Rule.

## Error Handling Strategies

### 1. User Interface Error Handling

#### AlertView

For presenting errors that require acknowledgment:

```swift
struct ErrorAlertView: ViewModifier {
    @Binding var error: AppError?
    var onDismiss: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .alert(item: $error) { error in
                // Apply Safety Warning Consistency Rule
                let alertStyle = alertStyleFor(severity: error.severityLevel)
                
                Alert(
                    title: Text(error.title)
                        .foregroundColor(alertStyle.titleColor),
                    message: Text(error.message + (error.recoverySuggestion.map { "\n\n\($0)" } ?? "")),
                    dismissButton: .default(Text(alertStyle.buttonText)) {
                        onDismiss?()
                    }
                )
            }
    }
    
    private func alertStyleFor(severity: ErrorSeverity) -> AlertStyle {
        switch severity {
        case .critical:
            return AlertStyle(titleColor: .red, buttonText: "I Understand")
        case .high:
            return AlertStyle(titleColor: .orange, buttonText: "Acknowledge")
        default:
            return AlertStyle(titleColor: .primary, buttonText: "OK")
        }
    }
    
    struct AlertStyle {
        let titleColor: Color
        let buttonText: String
    }
}

extension View {
    func errorAlert(error: Binding<AppError?>, onDismiss: (() -> Void)? = nil) -> some View {
        self.modifier(ErrorAlertView(error: error, onDismiss: onDismiss))
    }
}
```

Updated to support the Safety Warning Consistency Rule by styling alerts according to severity.

#### Recovery Action Sheet

For errors with multiple recovery options:

```swift
struct RecoveryActionSheet: ViewModifier {
    @Binding var error: RecoverableError?
    
    func body(content: Content) -> some View {
        content
            .actionSheet(item: $error) { error in
                ActionSheet(
                    title: Text(error.title),
                    message: Text(error.message),
                    buttons: error.recoveryOptions.map { option in
                        .default(Text(option.title)) {
                            option.action()
                        }
                    } + [.cancel()]
                )
            }
    }
}

extension View {
    func recoveryActionSheet(error: Binding<RecoverableError?>) -> some View {
        self.modifier(RecoveryActionSheet(error: error))
    }
}
```

#### Error Banner

For non-blocking errors:

```swift
struct ErrorBannerView: View {
    let error: AppError
    var onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if error.severityLevel == .critical || error.severityLevel == .high {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(error.severityLevel == .critical ? .red : .orange)
                }
                
                Text(error.title)
                    .font(.headline)
                    .foregroundColor(severityColor(for: error.severityLevel))
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            Text(error.message)
                .font(.subheadline)
            
            if let recovery = error.recoverySuggestion {
                Text(recovery)
                    .font(.caption)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(severityBackgroundColor(for: error.severityLevel).opacity(0.2))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(severityColor(for: error.severityLevel), lineWidth: 1)
        )
        .padding(.horizontal)
    }
    
    private func severityColor(for severity: ErrorSeverity) -> Color {
        switch severity {
        case .critical: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .blue
        }
    }
    
    private func severityBackgroundColor(for severity: ErrorSeverity) -> Color {
        switch severity {
        case .critical: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .blue
        }
    }
}
```

Updated to support the Safety Warning Consistency Rule by using consistent visual indicators based on severity.

### 2. ViewModel Error Handling

```swift
class MenuScanViewModel: ObservableObject {
    // ... other properties ...
    
    @Published var error: AppError?
    
    // Support for Confidence Visualization Rule
    @Published var confidenceLevel: ConfidenceLevel = .unknown
    @Published var requiresUserVerification: Bool = false
    
    func scanMenu() {
        do {
            // Start menu scanning process
            let image = try await cameraService.captureImage()
            processMenuImage(image)
        } catch let error as CameraError {
            handleError(error)
        } catch {
            handleError(ErrorWrapper(
                error: error,
                title: "Menu Scanning Failed",
                message: "An unexpected error occurred while scanning the menu.",
                recoverySuggestion: "Please try again."
            ))
        }
    }
    
    private func processMenuImage(_ image: UIImage) {
        Task {
            do {
                // Show immediate feedback per Progressive Loading Pattern Rule
                await MainActor.run {
                    self.scanProgress = 0.1
                    self.scanState = .processing
                }
                
                // Process the menu image
                let textResult = try await ocrService.recognizeMenu(from: image)
                await MainActor.run {
                    self.recognizedMenuText = textResult
                    self.scanProgress = 0.3
                }
                
                let parsedMenu = try await menuService.parseMenu(from: textResult)
                await MainActor.run {
                    self.parsedMenu = parsedMenu
                    self.scanProgress = 0.6
                }
                
                // Filter menu based on user's allergen profile
                if let profile = appState?.selectedProfile {
                    let filteredMenu = menuService.filterMenuItems(menu: parsedMenu, profile: profile)
                    await MainActor.run {
                        self.filteredMenu = filteredMenu
                        self.safeMenuItems = filteredMenu.safeItems
                        self.unsafeMenuItems = filteredMenu.unsafeItems
                        self.cautionMenuItems = filteredMenu.cautionItems
                        self.scanProgress = 0.9
                    }
                    
                    // Set confidence levels for User Validation Opportunity Rule
                    let confidence = menuService.calculateMenuConfidence(parsedMenu)
                    await MainActor.run {
                        self.confidenceLevel = confidence
                        // If low confidence or has critical allergens, require user verification
                        self.requiresUserVerification = confidence == .low || 
                            !filteredMenu.unsafeItems.isEmpty
                        self.scanProgress = 1.0
                        self.scanState = .completed
                    }
                }
            } catch let error as OCRError {
                await MainActor.run {
                    handleError(error)
                    self.scanState = .failed(error)
                }
            } catch let error as MenuScanError {
                await MainActor.run {
                    handleError(error)
                    self.scanState = .failed(error)
                }
            } catch {
                await MainActor.run {
                    handleError(ErrorWrapper(
                        error: error,
                        title: "Menu Processing Failed",
                        message: "An unexpected error occurred while processing the menu.",
                        recoverySuggestion: "Please try scanning again with better lighting."
                    ))
                    self.scanState = .failed(error)
                }
            }
        }
    }
    
    private func handleError(_ error: AppError) {
        self.error = error
        
        // Log error for debugging
        Logger.error("MenuScan error: \(error.title) - \(error.message)")
        
        // For certain errors, try recovery or degrades functionality
        switch error {
        case let menuError as MenuScanError:
            switch menuError {
            case .noMenuItemsFound:
                // Maybe try a different OCR strategy or prompt user to manually search
                suggestManualSearch()
            case .menuStructureUnrecognized:
                // Try a different parsing approach
                tryAlternativeParsingStrategy()
            case .lowConfidenceResults:
                // Implement User Validation Opportunity Rule
                self.requiresUserVerification = true
            default:
                break
            }
        default:
            break
        }
        
        // For critical errors, notify app state
        if isCriticalError(error) {
            appState?.alertType = .criticalError(error)
        }
    }
}
```

Updated to implement the Progressive Loading Pattern Rule, User Validation Opportunity Rule, and Confidence Visualization Rule.

### 3. Service Layer Error Handling

```swift
class MenuService {
    func parseMenu(from image: UIImage) async throws -> ParsedMenu {
        do {
            let ocrResult = try await ocrService.recognizeMenu(from: image)
            guard !ocrResult.text.isEmpty else {
                throw MenuScanError.noMenuItemsFound
            }
            
            do {
                return try parseMenuStructure(from: ocrResult)
            } catch {
                // Fall back to simpler parsing strategy
                return try parseMenuAsFlatList(from: ocrResult)
            }
        } catch let error as OCRError {
            // Translate OCR errors to MenuScan errors for consistent handling
            switch error {
            case .noTextFound:
                throw MenuScanError.noMenuItemsFound
            case .lowConfidence:
                // Apply Confidence Visualization Rule
                let menu = try? parseMenuWithLowConfidence(from: image)
                if let menu = menu {
                    menu.confidenceLevel = .low
                    return menu
                } else {
                    throw MenuScanError.lowConfidenceResults
                }
            default:
                throw MenuScanError.menuParsingFailed(error)
            }
        } catch {
            throw MenuScanError.menuParsingFailed(error)
        }
    }
    
    // Support for Confidence Visualization Rule
    func calculateMenuConfidence(_ menu: ParsedMenu) -> ConfidenceLevel {
        let itemConfidences = menu.items.map { $0.confidenceScore }
        let averageConfidence = itemConfidences.reduce(0, +) / Double(itemConfidences.count)
        
        if averageConfidence > 0.85 {
            return .high
        } else if averageConfidence > 0.65 {
            return .medium
        } else {
            return .low
        }
    }
    
    // Support for User Validation Opportunity Rule
    func applyUserCorrections(_ corrections: [MenuItemCorrection], to menu: ParsedMenu) -> ParsedMenu {
        var updatedMenu = menu
        
        for correction in corrections {
            if let index = updatedMenu.items.firstIndex(where: { $0.id == correction.itemID }) {
                var item = updatedMenu.items[index]
                
                // Apply user corrections
                if let correctedName = correction.correctedName {
                    item.name = correctedName
                }
                
                if let correctedIngredients = correction.correctedIngredients {
                    item.ingredients = correctedIngredients
                }
                
                if let correctedAllergens = correction.correctedAllergens {
                    item.detectedAllergens = correctedAllergens
                }
                
                // Mark as user-verified
                item.isUserVerified = true
                
                updatedMenu.items[index] = item
            }
        }
        
        return updatedMenu
    }
}
```

Updated to implement the User Validation Opportunity Rule and Confidence Visualization Rule.

## Error Logging & Analytics

### Logger

Centralized logging for errors:

```swift
enum LogLevel: Int {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    case critical = 4
}

class Logger {
    static let shared = Logger()
    
    static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.log(level: .debug, message: message, file: file, function: function, line: line)
    }
    
    static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.log(level: .info, message: message, file: file, function: function, line: line)
    }
    
    static func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.log(level: .warning, message: message, file: file, function: function, line: line)
    }
    
    static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.log(level: .error, message: message, file: file, function: function, line: line)
    }
    
    static func critical(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.log(level: .critical, message: message, file: file, function: function, line: line)
    }
    
    private func log(level: LogLevel, message: String, file: String, function: String, line: Int) {
        let fileName = (file as NSString).lastPathComponent
        let logString = "[\(level)] [\(fileName):\(line)] \(function) - \(message)"
        
        // Print to console in debug
        #if DEBUG
        print(logString)
        #endif
        
        // Store logs for crash reporting
        storeLog(level: level, message: logString)
        
        // For critical errors, send to analytics immediately
        if level == .critical {
            sendToAnalytics(level: level, message: message, file: fileName, function: function, line: line)
        }
    }
    
    private func storeLog(level: LogLevel, message: String) {
        // Implementation for storing logs
    }
    
    private func sendToAnalytics(level: LogLevel, message: String, file: String, function: String, line: Int) {
        // Implementation for sending to analytics
    }
}
```

### Error Analytics

For tracking and improving error handling:

```swift
class ErrorAnalytics {
    static let shared = ErrorAnalytics()
    
    func trackError(_ error: Error, context: [String: Any]? = nil) {
        var properties: [String: Any] = [
            "error_type": String(describing: type(of: error)),
            "error_message": error.localizedDescription,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if let appError = error as? AppError {
            properties["error_title"] = appError.title
            properties["is_recoverable"] = appError.isRecoverable
            properties["severity_level"] = String(describing: appError.severityLevel)
        }
        
        if let context = context {
            properties.merge(context) { (current, _) in current }
        }
        
        // Send to analytics service
        sendToAnalytics(event: "error_occurred", properties: properties)
    }
    
    private func sendToAnalytics(event: String, properties: [String: Any]) {
        // Implementation for sending to analytics service
    }
}
```

## Error Prevention Strategies

### Input Validation

```swift
func validateRestaurantSearch(query: String) -> ValidationResult {
    guard !query.isEmpty else {
        return .failure("Search query cannot be empty")
    }
    
    guard query.count >= 3 else {
        return .failure("Search query must be at least 3 characters")
    }
    
    return .success
}
```

### Preventive Checks

```swift
func canScanMenu() -> Bool {
    guard cameraService.isAvailable else {
        handleError(CameraError.noDeviceAvailable)
        return false
    }
    
    guard cameraService.currentPermissionStatus == .authorized else {
        handleError(CameraError.notAuthorized)
        return false
    }
    
    guard networkMonitor.isConnected || appState.offlineModeEnabled else {
        handleError(NetworkError.noConnection)
        return false
    }
    
    return true
}
```

### Graceful Degradation

```swift
func scanMenuWithFallbacks() async {
    // Try primary method
    do {
        let result = try await fullMenuScanAndParse()
        updateUI(with: result)
        return
    } catch {
        Logger.warning("Primary menu scan failed: \(error.localizedDescription)")
    }
    
    // First fallback: Try simplified OCR
    do {
        let result = try await simplifiedMenuScan()
        // Flag as low confidence per Confidence Visualization Rule
        result.confidenceLevel = .low
        updateUI(with: result, isReducedFunctionality: true)
        // Flag for user verification per User Validation Opportunity Rule
        requireUserVerification(for: result)
        return
    } catch {
        Logger.warning("Simplified menu scan failed: \(error.localizedDescription)")
    }
    
    // Final fallback: Manual entry mode
    activateManualEntryMode()
    handleError(MenuScanError.menuParsingFailed(error))
}
```

Updated to support the Confidence Visualization Rule and User Validation Opportunity Rule.

## User Communication

### Error Presentation Guidelines

1. **Be Clear**: Use plain language that users can understand
2. **Be Specific**: Explain what went wrong
3. **Be Helpful**: Provide actionable next steps
4. **Be Calm**: Don't alarm users unnecessarily
5. **Be Consistent**: Use consistent error messaging patterns
6. **Be Safety-Conscious**: Prioritize health and safety information
7. **Be Transparent**: Communicate confidence levels clearly

### Error Recovery Options

Recovery options are presented based on the error type:

```swift
func getRecoveryOptions(for error: AppError) -> [RecoveryOption] {
    switch error {
    case is CameraError:
        return [
            RecoveryOption(title: "Try Again", action: retryLastAction),
            RecoveryOption(title: "Use Photo Library", action: usePhotoLibrary),
            RecoveryOption(title: "Go to Settings", action: openSettings)
        ]
    case is MenuScanError:
        let options = [
            RecoveryOption(title: "Try Again", action: retryLastAction),
            RecoveryOption(title: "Scan Different Section", action: startNewScan),
            RecoveryOption(title: "Manual Search", action: startManualSearch)
        ]
        
        // For low confidence results, add option to verify per User Validation Opportunity Rule
        if case MenuScanError.lowConfidenceResults = error {
            return options + [RecoveryOption(title: "Review Results", action: reviewScanResults)]
        }
        
        return options
    // Additional cases for other error types
    default:
        return [
            RecoveryOption(title: "OK", action: dismissError)
        ]
    }
}
```

Updated to support the User Validation Opportunity Rule.

## User Verification Workflow

To implement the User Validation Opportunity Rule:

```swift
struct MenuVerificationView: View {
    @ObservedObject var viewModel: MenuVerificationViewModel
    
    var body: some View {
        VStack {
            // Header with confidence indicator
            HStack {
                Text("Please Verify Menu Results")
                    .font(.headline)
                
                Spacer()
                
                ConfidenceIndicator(level: viewModel.confidenceLevel)
            }
            .padding()
            
            // List of menu items for verification
            List {
                ForEach(viewModel.menuItems) { item in
                    MenuItemVerificationRow(
                        item: item,
                        onVerify: { viewModel.markItemVerified(item) },
                        onEdit: { viewModel.editItem(item) }
                    )
                }
            }
            
            // Action buttons
            HStack {
                Button("Accept All Safe Items") {
                    viewModel.acceptAllSafeItems()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Continue") {
                    viewModel.completeVerification()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canContinue)
            }
            .padding()
        }
        .alert(item: $viewModel.error) { error in
            Alert(
                title: Text(error.title),
                message: Text(error.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
```

This view implements the User Validation Opportunity Rule by allowing users to verify menu scan results.

## Confidence Visualization

To implement the Confidence Visualization Rule:

```swift
struct ConfidenceIndicator: View {
    let level: ConfidenceLevel
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var iconName: String {
        switch level {
        case .high:
            return "checkmark.circle.fill"
        case .medium:
            return "exclamationmark.circle.fill"
        case .low:
            return "exclamationmark.triangle.fill"
        case .unknown:
            return "questionmark.circle.fill"
        }
    }
    
    private var label: String {
        switch level {
        case .high:
            return "High Confidence"
        case .medium:
            return "Medium Confidence"
        case .low:
            return "Low Confidence"
        case .unknown:
            return "Unknown Confidence"
        }
    }
    
    private var color: Color {
        switch level {
        case .high:
            return .green
        case .medium:
            return .yellow
        case .low:
            return .orange
        case .unknown:
            return .gray
        }
    }
}
```

This component implements the Confidence Visualization Rule by providing a consistent visual representation of confidence levels.

## Safety Warning Display

To implement the Safety Warning Consistency Rule:

```swift
struct SafetyWarningView: View {
    let warning: SafetyWarning
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: warning.severity.iconName)
                .font(.title2)
                .foregroundColor(warning.severity.color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(warning.title)
                    .font(.headline)
                    .foregroundColor(warning.severity.color)
                
                Text(warning.message)
                    .font(.body)
                
                if let action = warning.action {
                    Button(action.title) {
                        action.handler()
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(warning.severity.color.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(warning.severity.color, lineWidth: 1)
        )
    }
}

struct SafetyWarning: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let severity: SafetySeverity
    let action: SafetyAction?
    
    struct SafetyAction {
        let title: String
        let handler: () -> Void
    }
}

enum SafetySeverity {
    case notice
    case caution
    case warning
    case danger
    
    var color: Color {
        switch self {
        case .notice: return .blue
        case .caution: return .yellow
        case .warning: return .orange
        case .danger: return .red
        }
    }
    
    var iconName: String {
        switch self {
        case .notice: return "info.circle.fill"
        case .caution: return "exclamationmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .danger: return "exclamationmark.octagon.fill"
        }
    }
}
```

This component implements the Safety Warning Consistency Rule by providing a consistent visual pattern for safety warnings based on severity.