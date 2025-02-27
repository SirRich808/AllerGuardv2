import SwiftUI
import Combine

/// The main application entry point
@main
struct AllerGuardAppDelegate: App {
    /// The app state for global state management
    @StateObject private var appState = AppState()
    
    /// The service registry for dependency injection
    private let serviceRegistry = ServiceRegistry()
    
    /// Initialize the app delegate
    init() {
        // Register services
        registerServices()
    }
    
    /// Define the app's scene
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appState)
                .environmentObject(serviceRegistry.cameraService)
                .environmentObject(serviceRegistry.ocrService)
                .environmentObject(serviceRegistry.allergenService)
                .environmentObject(serviceRegistry.permissionService)
                .onAppear {
                    // Perform any app initialization here
                    setupAppearance()
                }
        }
    }
    
    /// Registers all services with the service registry
    private func registerServices() {
        // Register services with the service registry
        serviceRegistry.registerServices()
    }
    
    /// Sets up the global appearance for the app
    private func setupAppearance() {
        // Configure global appearance settings
        #if os(iOS)
        // Set navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color("PrimaryBackground"))
        appearance.titleTextAttributes = [.foregroundColor: UIColor(Color("PrimaryText"))]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color("PrimaryText"))]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Set tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color("PrimaryBackground"))
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        #endif
    }
} 