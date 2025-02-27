import Foundation

/// This file serves as a central import point for all services in the AllerGuard app.
/// It helps organize service-related code and makes imports cleaner.

// Re-export service protocols and implementations
@_exported import SwiftUI
@_exported import AVFoundation
@_exported import Combine

// Note: The @_exported attribute makes the imported modules available to any file that imports this module.
// This is an internal Swift feature and might change in future Swift versions. 