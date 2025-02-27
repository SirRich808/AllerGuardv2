# AllerGuard State Management

*Last Updated: February 27, 2025*

This document outlines the state management approach for AllerGuard, including state ownership, update patterns, and the flow of data throughout the application.

## State Management Principles

1. **Single Source of Truth**: Each piece of state has a single, definitive owner
2. **Unidirectional Data Flow**: State changes flow in one direction
3. **Immutability**: State is not directly modified; new state is created from old state
4. **Observable State**: State changes are observable by interested components
5. **Localized State**: State is kept as close as possible to where it's used
6. **Predictable Updates**: State changes follow consistent patterns

## State Hierarchy

AllerGuard employs a hierarchical state management approach:

1. **App State**: Global application state managed by AppState
2. **Feature State**: State specific to a feature managed by feature ViewModels
3. **View State**: UI-specific state managed within individual views using @State
4. **Ephemeral State**: Temporary state that doesn't need to be persisted

## AppState (Global State)

The AppState class serves as the centralized state container for application-wide state:

```swift
class AppState: ObservableObject {
    // User & Profiles
    @Published var currentUser: User?
    @Published var selectedProfile: AllergenProfile?
    @Published var availableProfiles: [AllergenProfile] = []
    
    // App Status
    @Published var appStatus: AppStatus = .ready
    @Published var networkStatus: NetworkStatus = .unknown
    
    // Restaurant & Menu State
    @Published var currentRestaurant: Restaurant?
    @Published var recentRestaurants: [Restaurant] = []
    @Published var favoriteRestaurants: [Restaurant] = []
    @Published var lastMenuScanResult: MenuScanResult?
    
    // Feature Flags
    @Published var enabledFeatures: [FeatureFlag] = []
    
    // Global Navigation State
    @Published var activeTab: TabSelection = .home
    @Published var presentedSheet: SheetType? = nil
    @Published var alertType: AlertType? = nil
}
```

**Ownership & Injection**:
- AppState is owned by the app entry point (AllerGuardApp)
- It is injected into the view hierarchy using `@EnvironmentObject`
- Services can access AppState through dependency injection

## ViewModel State (Feature State)

Each feature has dedicated ViewModels that manage feature-specific state:

### Restaurant Menu Scanning ViewModel

```swift
class RestaurantMenuViewModel: ObservableObject {
    // Scanning State
    @Published var scanState: MenuScanState = .ready
    @Published var capturedImage: UIImage? = nil
    @Published var recognizedMenuText: MenuTextResult? = nil
    @Published var parsedMenu: ParsedMenu? = nil
    @Published var filteredMenu: FilteredMenu? = nil
    @Published var scanProgress: Double = 0.0
    
    // Restaurant Context
    @Published var currentRestaurant: Restaurant? = nil
    @Published var restaurantSearchResults: [Restaurant] = []
    @Published var searchQuery: String = ""
    
    // Menu Filtering
    @Published var safeMenuItems: [MenuItem] = []
    @Published var unsafeMenuItems: [MenuItem] = []
    @Published var cautionMenuItems: [MenuItem] = []
    @Published var selectedMenuItem: MenuItem? = nil
    @Published var substitutionOptions: [Substitution] = []
    
    // Errors
    @Published var error: MenuScanError? = nil
    
    // Dependencies
    private let cameraService: CameraService
    private let ocrService: OCRService
    private let menuService: MenuService
    private let restaurantService: RestaurantService
    private let allergenService: AllergenService
    
    // Reference to global state
    private weak var appState: AppState?
}
```

### Product Scanning ViewModel 

```swift
class ScanViewModel: ObservableObject {
    // State
    @Published var scanState: ScanState = .ready
    @Published var capturedImage: UIImage? = nil
    @Published var recognizedText: String? = nil
    @Published var detectedAllergens: [Allergen] = []
    @Published var scanProgress: Double = 0.0
    
    // Errors
    @Published var error: ScanError? = nil
    
    // Dependencies
    private let cameraService: CameraService
    private let ocrService: OCRService
    private let allergenService: AllergenService
    
    // Reference to global state
    private weak var appState: AppState?
}
```

**Ownership & Injection**:
- ViewModels are owned by parent views or coordinators
- They are injected into views using `@ObservedObject` or `@StateObject`
- ViewModels have access to services through dependency injection

## View State (UI State)

Individual views manage their own UI-specific state:

```swift
struct MenuItemDetailView: View {
    @State private var showIngredients = false
    @State private var showSubstitutions = false
    @State private var selectedSubstitution: Substitution? = nil
    @State private var animateSafetyIndicator = false
    
    // ViewModel provided through parent
    @ObservedObject var viewModel: MenuItemViewModel
}
```

**Characteristics**:
- Managed using SwiftUI's `@State` property wrapper
- Limited to UI concerns (animations, expanded/collapsed states)
- Not persisted beyond view lifecycle

## State Update Patterns

### 1. User Action → State Update

```
User Action → View → ViewModel → State Update → UI Update
```

Example:
```swift
// In View
Button("Scan Menu") {
    viewModel.startMenuScan()
}

// In ViewModel
func startMenuScan() {
    scanState = .scanning
    cameraService.configureForMenuScan()
    cameraService.captureImage { [weak self] result in
        switch result {
        case .success(let image):
            self?.processMenuImage(image)
        case .failure(let error):
            self?.handleError(error)
        }
    }
}
```

### 2. External Event → State Update

```
External Event → Service → ViewModel → State Update → UI Update
```

Example:
```swift
// In ViewModel initialization
restaurantService.nearbyRestaurantsPublisher
    .receive(on: DispatchQueue.main)
    .sink { [weak self] restaurants in
        self?.nearbyRestaurants = restaurants
    }
    .store(in: &cancellables)
```

### 3. Timer/Background Process → State Update

```
Timer → ViewModel → State Update → UI Update
```

Example:
```swift
// Background refresh of restaurant database
Timer.publish(every: 86400, on: .main, in: .common)
    .autoconnect()
    .sink { [weak self] _ in
        self?.refreshRestaurantDatabase()
    }
    .store(in: &cancellables)
```

## State Persistence

State is persisted at different levels:

1. **User Preferences**: Stored in UserDefaults
2. **User Profiles & Scan History**: Stored in Core Data
3. **Restaurant & Menu Data**: Stored in Core Data with caching strategies
4. **App State**: Reconstructed on app launch
5. **Session State**: Maintained during app lifecycle

Persistence responsibilities:

```swift
// Example of restaurant and menu state restoration
func restoreRestaurantState() {
    do {
        // Restore favorite restaurants
        let favoriteRestaurants = try storageService.fetchFavoriteRestaurants()
        self.favoriteRestaurants = favoriteRestaurants
        
        // Restore recent restaurants
        let recentMenuScans = try storageService.fetchMenuHistory(limit: 5, offset: 0)
        let recentRestaurants = recentMenuScans.compactMap { $0.restaurant }.uniqued()
        self.recentRestaurants = recentRestaurants
        
        // Restore last visited restaurant
        if let lastRestaurantID = UserDefaults.standard.string(forKey: "lastVisitedRestaurantID"),
           let restaurant = favoriteRestaurants.first(where: { $0.id == lastRestaurantID }) {
            self.currentRestaurant = restaurant
        }
    } catch {
        self.error = error
    }
}
```

## Cross-Feature Communication

Features communicate through these mechanisms:

1. **Via AppState**: Using the shared AppState object
2. **Publisher/Subscriber**: Using Combine framework
3. **Delegate Pattern**: For direct communication between related components
4. **Service Layer**: Through shared services

Example:
```swift
// Publishing a menu scan result that other features might be interested in
func publishMenuScanResult(_ result: MenuScanResult) {
    menuScanResultPublisher.send(result)
    appState?.lastMenuScanResult = result
    
    // Update recent restaurants in app state
    if let restaurant = result.restaurant, 
       !appState?.recentRestaurants.contains(where: { $0.id == restaurant.id }) ?? true {
        appState?.recentRestaurants.insert(restaurant, at: 0)
        if appState?.recentRestaurants.count ?? 0 > 5 {
            appState?.recentRestaurants.removeLast()
        }
    }
}
```

## Error State Management

Errors are managed at appropriate levels:

1. **Recovery Errors**: Handled at view level with retry options
2. **Feature Errors**: Managed by ViewModels
3. **System Errors**: Propagated to AppState for app-wide handling

Error state pattern:
```swift
// In ViewModel
func handleMenuScanError(_ error: Error) {
    switch error {
    case let menuError as MenuScanError where menuError.isRecoverable:
        self.error = error
    case let restaurantError as RestaurantError:
        // Handle restaurant-specific errors
        self.error = error
        scanState = .failed(error)
    case let ocrError as OCRError:
        // Handle OCR-specific errors with potential retry strategies
        self.error = error
        scanState = .failed(error)
    default:
        appState?.alertType = .generalError(error)
    }
}
```

## State Debugging

For debugging purposes:

1. **State Logging**: Important state transitions are logged
2. **Debug Views**: Special views for development showing state
3. **State Inspection**: Using Xcode's View Hierarchy Debugger

Example:
```swift
// Debug logging of state changes
func updateScanState(_ newState: ScanState) {
    #if DEBUG
    print("Scan state changing: \(scanState) → \(newState)")
    #endif
    
    scanState = newState
}
```

## Performance Considerations

To maintain performance while managing state:

1. **Granular Publishers**: Break up @Published properties to avoid unnecessary updates
2. **Debouncing**: Limit rapid state changes
3. **Background Processing**: Perform heavy state transformations off the main thread
4. **Lazy State Loading**: Load state only when needed

Example:
```swift
// Debouncing rapid state changes
$searchText
    .debounce(for: 0.3, scheduler: RunLoop.main)
    .removeDuplicates()
    .sink { [weak self] text in
        self?.performSearch(text)
    }
    .store(in: &cancellables)
``` 