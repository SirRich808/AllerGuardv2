import SwiftUI
import Combine

// Since we're having issues with direct type references, let's temporarily
// keep the type definitions here until the module structure is fixed

/// Enum representing the main tabs in the app
enum Tab: Hashable {
    case scan
    case history
    case profile
    case settings
}

/// App-level errors
struct AppError: Error, Identifiable {
    /// Unique identifier for the error
    let id = UUID()
    
    /// The title of the error
    let title: String
    
    /// The message describing the error
    let message: String
    
    /// Optional suggestion for recovering from the error
    let recoverySuggestion: String?
    
    /// Initializes a new app error
    /// - Parameters:
    ///   - title: The title of the error
    ///   - message: The message describing the error
    ///   - recoverySuggestion: Optional suggestion for recovering from the error
    init(title: String, message: String, recoverySuggestion: String? = nil) {
        self.title = title
        self.message = message
        self.recoverySuggestion = recoverySuggestion
    }
}

/// Global application state that can be shared across the app
final class AppState: ObservableObject {
    /// The currently selected tab in the main interface
    @Published var selectedTab: Tab = .scan
    
    /// Whether the app is currently processing a task
    @Published var isProcessing = false
    
    /// The current global error, if any
    @Published var error: AppError?
    
    /// Cancellable storage for subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    /// Initializes the app state
    init() {
        // Setup any initial state or observers
    }
    
    /// Clears the current error
    func clearError() {
        error = nil
    }
    
    /// Sets the current error
    /// - Parameter error: The error to set
    func setError(_ error: AppError) {
        self.error = error
    }
} 