import Foundation

/// A registry for managing services in the application
final class ServiceRegistry {
    // MARK: - Singleton
    
    /// The shared instance of the service registry
    static let shared = ServiceRegistry()
    
    // MARK: - Private Properties
    
    /// Dictionary to store services by their protocol type
    private var services: [String: Any] = [:]
    
    // MARK: - Initialization
    
    private init() {
        // Private initializer to enforce singleton pattern
    }
    
    // MARK: - Public Methods
    
    /// Registers a service for a specific protocol
    /// - Parameters:
    ///   - service: The service to register
    ///   - protocolType: The protocol type to register the service for
    func register<T>(_ service: T, for protocolType: T.Type) {
        let key = String(describing: protocolType)
        services[key] = service
    }
    
    /// Retrieves a service for a specific protocol
    /// - Parameter protocolType: The protocol type to retrieve the service for
    /// - Returns: The registered service, or nil if no service is registered
    func resolve<T>(_ protocolType: T.Type) -> T? {
        let key = String(describing: protocolType)
        return services[key] as? T
    }
    
    /// Removes a service for a specific protocol
    /// - Parameter protocolType: The protocol type to remove the service for
    func unregister<T>(_ protocolType: T.Type) {
        let key = String(describing: protocolType)
        services.removeValue(forKey: key)
    }
    
    /// Removes all registered services
    func unregisterAll() {
        services.removeAll()
    }
} 