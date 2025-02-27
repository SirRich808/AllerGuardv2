# AllerGuard Implementation Guide for Cursor

*Last Updated: February 27, 2025*

This guide provides practical implementation patterns for Cursor to follow when generating code for AllerGuard.

## Quick Reference

### File Structure
```
/AllerGuard
  /Models            # Data models, Core Data entities
  /Views             # SwiftUI views organized by feature
  /ViewModels        # View state and business logic
  /Services          # Core functionality and business rules
  /Utilities         # Helper functions and extensions
  /Resources         # Assets, localizations, etc.
  /Configuration     # Feature flags, environment settings
```

### Naming Patterns
- Views: `{Feature}View`, `{Feature}ListView`, `{Feature}DetailView`
- ViewModels: `{Feature}ViewModel`
- Services: `{Feature}Service`
- Protocols: `{Name}Protocol` or `{Name}able`
- Extensions: `{Type}+{Functionality}`

## Code Templates

### MVVM Pattern [Rule #1]

**ViewModel Template:**
```swift
class RestaurantMenuViewModel: ObservableObject {
    // Published properties for view binding
    @Published private(set) var menuItems: [MenuItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    // Services (injected via init)
    private let menuService: MenuServiceProtocol
    private let allergenService: AllergenServiceProtocol
    
    // Init with dependencies
    init(menuService: MenuServiceProtocol, allergenService: AllergenServiceProtocol) {
        self.menuService = menuService
        self.allergenService = allergenService
    }
    
    // Intent methods (called by View)
    func scanMenu() {
        Task {
            await MainActor.run { self.isLoading = true }
            do {
                // Show immediate feedback (Rule #21)
                await updateLoadingProgress(0.1)
                
                // Core business logic using services
                let result = try await menuService.scanMenu()
                
                // Update UI state on main thread
                await MainActor.run {
                    self.menuItems = result.items
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    // Private helper methods
    private func updateLoadingProgress(_ progress: Double) async {
        await MainActor.run { /* Update progress indicator */ }
    }
}
```

**View Template:**
```swift
struct RestaurantMenuView: View {
    @StateObject private var viewModel = RestaurantMenuViewModel(
        menuService: ServiceRegistry.shared.get(MenuServiceProtocol.self)!,
        allergenService: ServiceRegistry.shared.get(AllergenServiceProtocol.self)!
    )
    
    var body: some View {
        VStack {
            // UI elements bound to ViewModel
            if viewModel.isLoading {
                ProgressView()
            } else {
                List(viewModel.menuItems) { item in
                    MenuItemRow(item: item)
                }
            }
            
            Button("Scan Menu") {
                viewModel.scanMenu()
            }
        }
        .alert(item: $viewModel.errorMessage) { message in
            Alert(title: Text("Error"), message: Text(message))
        }
    }
}
```

### Service Registration [Rule #3]

```swift
// Service protocol
protocol MenuServiceProtocol {
    func scanMenu() async throws -> MenuScanResult
    func parseMenu(from text: String) throws -> ParsedMenu
    func filterMenuItems(menu: ParsedMenu, profile: AllergenProfile) -> FilteredMenu
}

// Service implementation
class MenuService: MenuServiceProtocol {
    // Implementation here
}

// Registration (in AppDelegate or startup code)
ServiceRegistry.shared.register(MenuService(), for: MenuServiceProtocol.self)

// Usage
let menuService = ServiceRegistry.shared.get(MenuServiceProtocol.self)!
```

### Progressive Loading [Rule #21]

```swift
func scanMenu() {
    Task {
        // 1. Immediate UI feedback
        await MainActor.run {
            self.scanState = .scanning
            self.scanProgress = 0.1
        }
        
        do {
            // 2. Camera capture with progress
            let image = try await cameraService.captureImage()
            await MainActor.run { self.scanProgress = 0.3 }
            
            // 3. OCR with progress
            let textResult = try await ocrService.recognizeMenu(from: image)
            await MainActor.run { 
                self.recognizedText = textResult
                self.scanProgress = 0.5 
            }
            
            // 4. Menu parsing with progress
            let parsedMenu = try await menuService.parseMenu(from: textResult)
            await MainActor.run { 
                self.parsedMenu = parsedMenu
                self.scanProgress = 0.7 
            }
            
            // 5. Allergen detection with progress
            let filteredMenu = allergenService.detectAllergens(in: parsedMenu)
            await MainActor.run { 
                self.filteredMenu = filteredMenu
                self.scanProgress = 0.9 
            }
            
            // 6. Completion
            await MainActor.run {
                self.scanState = .completed
                self.scanProgress = 1.0
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.scanState = .failed
            }
        }
    }
}
```

### Confidence Visualization [Rule #26]

```swift
struct ConfidenceView: View {
    let level: ConfidenceLevel
    
    var body: some View {
        HStack {
            Image(systemName: iconFor(level))
                .foregroundColor(colorFor(level))
            Text(textFor(level))
                .font(.caption)
                .foregroundColor(colorFor(level))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(colorFor(level).opacity(0.1))
        .cornerRadius(12)
    }
    
    private func iconFor(_ level: ConfidenceLevel) -> String {
        switch level {
            case .high: return "checkmark.circle.fill"
            case .medium: return "exclamationmark.circle.fill"
            case .low: return "exclamationmark.triangle.fill"
            case .unknown: return "questionmark.circle.fill"
        }
    }
    
    private func colorFor(_ level: ConfidenceLevel) -> Color {
        switch level {
            case .high: return .green
            case .medium: return .yellow
            case .low: return .orange
            case .unknown: return .gray
        }
    }
    
    private func textFor(_ level: ConfidenceLevel) -> String {
        switch level {
            case .high: return "High Confidence"
            case .medium: return "Medium Confidence"
            case .low: return "Low Confidence"
            case .unknown: return "Unknown Confidence"
        }
    }
}
```

### User Validation Opportunity [Rule #25]

```swift
struct MenuVerificationView: View {
    @ObservedObject var viewModel: MenuVerificationViewModel
    
    var body: some View {
        VStack {
            // Header with title and confidence
            HStack {
                Text("Verify Menu Results")
                    .font(.headline)
                Spacer()
                ConfidenceView(level: viewModel.confidenceLevel)
            }
            .padding()
            
            // Display items that need verification
            List {
                ForEach(viewModel.menuItems) { item in
                    MenuItemVerificationRow(
                        item: item,
                        onVerify: { viewModel.verifyItem(item.id) },
                        onEdit: { viewModel.editItem(item.id) }
                    )
                }
            }
            
            // Action buttons
            HStack {
                Button("Accept All") {
                    viewModel.acceptAllItems()
                }
                
                Spacer()
                
                Button("Continue") {
                    viewModel.saveAndContinue()
                }
                .disabled(!viewModel.canContinue)
            }
            .padding()
        }
    }
}
```

### Core Data Concurrency [Rule #22]

```swift
class StorageService {
    private let container: NSPersistentContainer
    private let viewContext: NSManagedObjectContext
    
    // Create a new background context for intensive operations
    private func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    // Save menu scan in background
    func saveMenuScan(_ scan: MenuScanResult) async throws {
        // Execute on background context
        try await Task.detached {
            let context = self.newBackgroundContext()
            
            // Create and configure the entity
            let scanEntity = MenuScanEntity(context: context)
            scanEntity.id = scan.id
            scanEntity.timestamp = scan.timestamp
            // ... set other properties
            
            // Save context
            try context.save()
            
            // Notify main context of changes
            await MainActor.run {
                self.viewContext.mergeChanges(fromContextDidSave: context)
            }
        }.value
    }
    
    // Fetch on view context for UI operations
    func fetchRecentMenuScans(limit: Int) -> [MenuScanResult] {
        let request = MenuScanEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = limit
        
        do {
            let entities = try viewContext.fetch(request)
            return entities.map { $0.toMenuScanResult() }
        } catch {
            Logger.error("Failed to fetch menu scans: \(error)")
            return []
        }
    }
}
```

## Implementation Checklist

When generating code for AllerGuard, always verify:

1. **Architecture Compliance**
   - ✓ MVVM pattern followed
   - ✓ Services accessed through ServiceRegistry
   - ✓ UI logic in View, business logic in ViewModel

2. **Safety Features**
   - ✓ Confidence levels displayed for all allergen-related results
   - ✓ User verification opportunity for critical information
   - ✓ Consistent warning styling based on severity

3. **Performance & Reliability**
   - ✓ Async/await used for asynchronous operations
   - ✓ UI updates on MainActor
   - ✓ Progressive loading patterns implemented
   - ✓ Core Data operations on appropriate contexts

4. **UX Best Practices**
   - ✓ Immediate feedback for user actions
   - ✓ Clear error messages with recovery options
   - ✓ Consistent UI components and styling
   
## Apple Best Practices Implementation

### Human Interface Guidelines Components [Rule #12, #27]

```swift
struct MenuItemView: View {
    let item: MenuItem
    let isAllergenic: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title using system font sizes
            Text(item.name)
                .font(.headline)
                .foregroundColor(isAllergenic ? .red : .primary)
            
            // Description with proper line spacing
            Text(item.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineSpacing(4)
                .lineLimit(2)
            
            // Use of SF Symbols with semantic colors
            HStack {
                if isAllergenic {
                    Label {
                        Text("Contains allergens")
                    } icon: {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                    }
                    .accessibilityLabel("Warning: Contains allergens")
                } else {
                    Label {
                        Text("Safe to eat")
                    } icon: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    .accessibilityLabel("Safe to eat")
                }
                
                Spacer()
                
                // Context menu with SF Symbols
                Menu {
                    Button {
                        // Action
                    } label: {
                        Label("Save Item", systemImage: "bookmark")
                    }
                    
                    Button {
                        // Action
                    } label: {
                        Label("View Details", systemImage: "doc.text.magnifyingglass")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        // Support dynamic type
        .dynamicTypeSize(.medium...DynamicTypeSize.accessibility3)
        // Add proper spacing for iOS
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
```

### Navigation Patterns [Rule #27]

```swift
struct RestaurantTabView: View {
    @StateObject private var viewModel = RestaurantViewModel()
    
    var body: some View {
        TabView {
            NavigationView {
                RestaurantMenuView(viewModel: viewModel)
                    .navigationTitle("Menu")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                viewModel.scanMenu()
                            } label: {
                                Image(systemName: "camera")
                            }
                        }
                    }
            }
            .tabItem {
                Label("Menu", systemImage: "doc.text")
            }
            
            NavigationView {
                AllergenProfileView()
                    .navigationTitle("My Allergens")
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            
            NavigationView {
                ScanHistoryView()
                    .navigationTitle("History")
            }
            .tabItem {
                Label("History", systemImage: "clock")
            }
        }
        .accentColor(.red) // App tint color
    }
}
```

### iOS App Lifecycle Management [Rule #27, #28]

```swift
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Create the SwiftUI view that provides the window contents
        let contentView = ContentView()
            .environmentObject(AppState.shared)
        
        // Use a UIHostingController as window root view controller
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: contentView)
        self.window = window
        window.makeKeyAndVisible()
        
        // Handle deep links
        if let userActivity = connectionOptions.userActivities.first {
            self.scene(scene, continue: userActivity)
        }
        
        // Handle URL context
        if let url = connectionOptions.urlContexts.first?.url {
            handleIncomingURL(url)
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Save any pending data
        PersistenceController.shared.saveContext()
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Remove any temporary UI like alerts
        NotificationCenter.default.post(name: .sceneDidBecomeActive, object: nil)
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Pause ongoing tasks, disable timers
        NotificationCenter.default.post(name: .sceneWillResignActive, object: nil)
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        // Handle Handoff and Spotlight continuation
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {
            handleIncomingURL(url)
        }
    }
    
    private func handleIncomingURL(_ url: URL) {
        // Process deep link URL
        DeepLinkHandler.shared.handle(url: url)
    }
}
```

### Background Tasks [Rule #28]

```swift
class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    
    private let menuDataUpdateTaskIdentifier = "com.allerguard.menuDataUpdate"
    
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: menuDataUpdateTaskIdentifier,
            using: nil
        ) { task in
            self.handleMenuDataUpdate(task: task as! BGProcessingTask)
        }
    }
    
    func scheduleMenuDataUpdate() {
        let request = BGProcessingTaskRequest(identifier: menuDataUpdateTaskIdentifier)
        
        // Require device to be charging
        request.requiresExternalPower = true
        
        // Run when network is available
        request.requiresNetworkConnectivity = true
        
        // Request to run in 12 hours
        request.earliestBeginDate = Date(timeIntervalSinceNow: 12 * 60 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            Logger.error("Could not schedule menu data update: \(error)")
        }
    }
    
    private func handleMenuDataUpdate(task: BGProcessingTask) {
        scheduleMenuDataUpdate() // Schedule next update
        
        // Create a task to update menu database
        let updateTask = Task.detached(priority: .background) {
            do {
                try await RestaurantService.shared.updateMenuDatabase()
                return true
            } catch {
                Logger.error("Background menu update failed: \(error)")
                return false
            }
        }
        
        // Set expiration handler
        task.expirationHandler = {
            updateTask.cancel()
        }
        
        // When task completes, report result and complete task
        Task {
            let success = await updateTask.value
            task.setTaskCompleted(success: success)
        }
    }
}
```

### Accessibility Implementation [Rule #12, #27]

```swift
struct AccessibleMenuItemView: View {
    let item: MenuItem
    let isAllergenic: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            // Title row with content and warning
            HStack {
                Text(item.name)
                    .font(.headline)
                
                if isAllergenic {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .accessibilityHidden(true) // Hidden because we'll have a comprehensive label
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(isAllergenic ? 
                "Menu item \(item.name), contains allergens" : 
                "Menu item \(item.name), safe to eat"
            )
            
            // Description with proper accessibility
            Text(item.description)
                .font(.body)
                .foregroundColor(.secondary)
                .accessibilityLabel("Description: \(item.description)")
            
            // Ingredients with proper accessibility 
            VStack(alignment: .leading) {
                Text("Ingredients:")
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                Text(item.ingredients.joined(separator: ", "))
                    .font(.subheadline)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Ingredients: \(item.ingredients.joined(separator: ", "))")
            
            // Allergen info with proper accessibility traits
            if isAllergenic {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Contains allergens:")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    
                    ForEach(item.allergens, id: \.self) { allergen in
                        Text("• \(allergen)")
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Contains allergens: \(item.allergens.joined(separator: ", "))")
                .accessibilityTraits(.isButton)
                .accessibilityHint("Double tap for more information about these allergens")
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .accessibilityAction(named: "Save to favorites") {
            // Action to save to favorites
        }
        .accessibilityAction(named: "View alternatives") {
            // Action to view alternatives
        }
    }
}
```

## Apple Platform Checklist

When implementing features, ensure:

1. **UI Design**
   - ✓ Follows iOS design language (roundedness, spacing, margins)
   - ✓ Uses system fonts (SF Pro) for consistent typography
   - ✓ Implements Dynamic Type for text scaling
   - ✓ Uses SF Symbols for iconography
   - ✓ Supports Dark Mode with appropriate semantic colors
   - ✓ Implements appropriate haptic feedback patterns

2. **iOS Platform Integration**
   - ✓ Handles app lifecycle events properly
   - ✓ Implements state restoration for interrupted sessions
   - ✓ Supports multitasking on iPad (if applicable)
   - ✓ Handles system interruptions (calls, notifications)
   - ✓ Uses BackgroundTasks framework for background operations

3. **Performance & Efficiency**
   - ✓ Minimizes main thread work
   - ✓ Uses efficient drawing techniques
   - ✓ Implements proper caching strategies
   - ✓ Optimizes memory usage with Instruments
   - ✓ Respects battery life by optimizing background operations 