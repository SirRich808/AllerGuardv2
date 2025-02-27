import Foundation

/// Severity levels for errors in the application
enum ErrorSeverity {
    case low      // Information, non-critical
    case medium   // Standard errors, may impact functionality
    case high     // Serious errors requiring attention
    case critical // Health-safety related errors
    
    var requiresAcknowledgment: Bool {
        self == .high || self == .critical
    }
}

/// Base protocol for app-specific errors
protocol AppError: Error, Identifiable {
    var id: UUID { get }
    var title: String { get }
    var message: String { get }
    var recoverySuggestion: String? { get }
    var isRecoverable: Bool { get }
    var severityLevel: ErrorSeverity { get }
}

/// Default implementation for AppError
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

/// A wrapper for system errors to conform to AppError
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