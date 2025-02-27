import Foundation
import SwiftUI
import Combine

// Import the Services module
import AVFoundation

// Define the necessary types locally if they can't be imported
// Camera position (front or back)
enum CameraPosition {
    case front
    case back
}

// Errors that can occur during camera operations
enum CameraError: Error, LocalizedError, Identifiable {
    case accessDenied
    case deviceNotAvailable
    case setupFailed
    case inputNotSupported
    case outputNotSupported
    case sessionNotRunning
    case captureFailed
    case invalidPhotoData
    case serviceDeallocated
    case unknown
    
    var id: UUID {
        UUID()
    }
    
    var localizedDescription: String {
        switch self {
        case .accessDenied:
            return "Camera access denied. Please enable camera access in Settings."
        case .deviceNotAvailable:
            return "Camera device not available."
        case .setupFailed:
            return "Failed to set up the camera."
        case .inputNotSupported:
            return "Camera input not supported."
        case .outputNotSupported:
            return "Camera output not supported."
        case .sessionNotRunning:
            return "Camera session not running."
        case .captureFailed:
            return "Failed to capture photo."
        case .invalidPhotoData:
            return "Invalid photo data."
        case .serviceDeallocated:
            return "Camera service was deallocated."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

// Represents a food allergen
struct Allergen: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var description: String
    var commonNames: [String]
    var iconName: String
}

// Represents a user's sensitivity level to allergens
enum SensitivityLevel: String, Codable, CaseIterable {
    case mild = "Mild"
    case moderate = "Moderate"
    case severe = "Severe"
    
    var color: Color {
        switch self {
        case .mild:
            return .yellow
        case .moderate:
            return .orange
        case .severe:
            return .red
        }
    }
}

// Represents a match between detected text and an allergen
struct AllergenMatch: Identifiable, Hashable {
    var id: UUID
    var allergen: Allergen
    var matchedText: String
    var sensitivityLevel: SensitivityLevel?
}

// Permission status
enum PermissionStatus: String {
    case notDetermined = "Not Determined"
    case denied = "Denied"
    case restricted = "Restricted"
    case authorized = "Authorized"
    case limited = "Limited"
}

// MARK: - Service Protocols

/// Protocol for camera operations
protocol CameraServiceProtocol {
    /// Whether the camera is currently active
    var isActive: Bool { get }
    
    /// The current camera position
    var position: CameraPosition { get }
    
    /// The current camera error, if any
    var error: CameraError? { get }
    
    /// Sets up the camera with the specified position
    /// - Parameter position: The camera position to use
    /// - Throws: CameraError if setup fails
    func setupCamera(position: CameraPosition) async throws
    
    /// Starts the camera session
    /// - Throws: CameraError if starting the session fails
    func startSession() async throws
    
    /// Stops the camera session
    func stopSession() async
    
    /// Captures a photo from the camera
    /// - Returns: The captured image, or nil if capture fails
    /// - Throws: CameraError if capturing the photo fails
    func capturePhoto() async throws -> Image?
    
    /// Switches between front and back cameras
    /// - Throws: CameraError if switching cameras fails
    func switchCamera() async throws
}

/// Protocol for OCR (Optical Character Recognition) service
protocol OCRServiceProtocol {
    /// Recognizes text in an image
    /// - Parameter image: The image to recognize text in
    /// - Returns: The recognized text
    #if os(iOS)
    func recognizeText(in image: UIImage) async throws -> String
    #elseif os(macOS)
    func recognizeText(in image: NSImage) async throws -> String
    #endif
    
    /// Recognizes text in an image at a specific region
    /// - Parameters:
    ///   - image: The image to recognize text in
    ///   - region: The region to recognize text in
    /// - Returns: The recognized text
    #if os(iOS)
    func recognizeText(in image: UIImage, region: CGRect) async throws -> String
    #elseif os(macOS)
    func recognizeText(in image: NSImage, region: CGRect) async throws -> String
    #endif
}

/// Protocol for allergen detection service
protocol AllergenServiceProtocol {
    /// Detects allergens in text
    /// - Parameter text: The text to detect allergens in
    /// - Returns: Array of detected allergens
    func detectAllergens(in text: String) async throws -> [AllergenMatch]
    
    /// Gets all supported allergens
    /// - Returns: Array of all supported allergens
    func getAllergens() async -> [Allergen]
    
    /// Updates the user's allergen preferences
    /// - Parameter allergens: The allergens to update
    func updateUserAllergens(_ allergens: [Allergen]) async
}

/// Protocol for permission handling service
protocol PermissionServiceProtocol {
    /// The current camera permission status
    var cameraPermissionStatus: PermissionStatus { get }
    
    /// The current photo library permission status
    var photoLibraryPermissionStatus: PermissionStatus { get }
    
    /// Requests camera permission
    /// - Returns: The updated permission status
    func requestCameraPermission() async -> PermissionStatus
    
    /// Requests photo library permission
    /// - Returns: The updated permission status
    func requestPhotoLibraryPermission() async -> PermissionStatus
    
    /// Opens the app settings
    func openAppSettings()
}

/// ViewModel for the camera screen
final class CameraViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// Whether the camera is currently active
    @Published var isActive = false
    
    /// The current camera position
    @Published var cameraPosition: CameraPosition = .back
    
    /// The current camera error, if any
    @Published var error: CameraError?
    
    /// The captured image, if any
    @Published var capturedImage: Image?
    
    /// Whether the camera is currently processing
    @Published var isProcessing = false
    
    /// The recognized text from the captured image
    @Published var recognizedText: String = ""
    
    /// The detected allergens from the recognized text
    @Published var detectedAllergens: [AllergenMatch] = []
    
    // MARK: - Private Properties
    
    /// The camera service
    private let cameraService: CameraServiceProtocol
    
    /// The OCR service
    private let ocrService: OCRServiceProtocol
    
    /// The allergen service
    private let allergenService: AllergenServiceProtocol
    
    /// The permission service
    private let permissionService: PermissionServiceProtocol
    
    /// Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// Initializes a new camera view model
    /// - Parameters:
    ///   - cameraService: The camera service
    ///   - ocrService: The OCR service
    ///   - allergenService: The allergen service
    ///   - permissionService: The permission service
    init(
        cameraService: CameraServiceProtocol,
        ocrService: OCRServiceProtocol,
        allergenService: AllergenServiceProtocol,
        permissionService: PermissionServiceProtocol
    ) {
        self.cameraService = cameraService
        self.ocrService = ocrService
        self.allergenService = allergenService
        self.permissionService = permissionService
        
        setupBindings()
    }
    
    // MARK: - Factory Methods
    
    /// Creates a mock camera view model for previews and testing
    /// - Returns: A mock camera view model
    static func createMock() -> CameraViewModel {
        // Create mock services
        let cameraService = MockCameraService()
        let ocrService = MockOCRService()
        let allergenService = MockAllergenService()
        let permissionService = MockPermissionService()
        
        // Create the view model with mock services
        return CameraViewModel(
            cameraService: cameraService,
            ocrService: ocrService,
            allergenService: allergenService,
            permissionService: permissionService
        )
    }
    
    // MARK: - Public Methods
    
    /// Sets up the camera
    func setupCamera() async {
        do {
            // Check camera permission
            if permissionService.cameraPermissionStatus != .authorized {
                let status = await permissionService.requestCameraPermission()
                if status != .authorized {
                    throw CameraError.accessDenied
                }
            }
            
            // Setup camera with current position
            try await cameraService.setupCamera(position: cameraPosition)
            
            // Start camera session
            try await cameraService.startSession()
            
            // Update isActive on main thread
            await MainActor.run {
                isActive = true
                error = nil
            }
        } catch let cameraError as CameraError {
            await MainActor.run {
                error = cameraError
                isActive = false
            }
        } catch {
            await MainActor.run {
                self.error = .unknown
                isActive = false
            }
        }
    }
    
    /// Captures a photo
    func capturePhoto() async {
        guard isActive else { return }
        
        await MainActor.run {
            isProcessing = true
        }
        
        do {
            // Capture photo
            if let image = try await cameraService.capturePhoto() {
                await MainActor.run {
                    capturedImage = image
                }
                
                // Process the captured image
                await processImage()
            } else {
                throw CameraError.invalidPhotoData
            }
        } catch let cameraError as CameraError {
            await MainActor.run {
                error = cameraError
                isProcessing = false
            }
        } catch {
            await MainActor.run {
                self.error = .unknown
                isProcessing = false
            }
        }
    }
    
    /// Switches the camera between front and back
    func switchCamera() async {
        do {
            try await cameraService.switchCamera()
            
            await MainActor.run {
                cameraPosition = cameraPosition == .front ? .back : .front
            }
        } catch let cameraError as CameraError {
            await MainActor.run {
                error = cameraError
            }
        } catch {
            await MainActor.run {
                self.error = .unknown
            }
        }
    }
    
    /// Stops the camera session
    func stopCamera() async {
        await cameraService.stopSession()
        
        await MainActor.run {
            isActive = false
        }
    }
    
    /// Clears the captured image and results
    func clearCapture() {
        capturedImage = nil
        recognizedText = ""
        detectedAllergens = []
    }
    
    // MARK: - Private Methods
    
    /// Sets up bindings for reactive updates
    private func setupBindings() {
        // No bindings needed yet
    }
    
    /// Processes the captured image for OCR and allergen detection
    private func processImage() async {
        guard capturedImage != nil else { return }
        
        do {
            // Perform OCR on the image
            #if os(iOS)
            // This is a stub - in a real implementation, we would convert the SwiftUI Image to UIImage
            let uiImage = UIImage() // Placeholder
            let text = try await ocrService.recognizeText(in: uiImage)
            #elseif os(macOS)
            // This is a stub - in a real implementation, we would convert the SwiftUI Image to NSImage
            let nsImage = NSImage() // Placeholder
            let text = try await ocrService.recognizeText(in: nsImage)
            #endif
            
            // Update recognized text
            await MainActor.run {
                recognizedText = text
            }
            
            // Detect allergens in the recognized text
            let allergens = try await allergenService.detectAllergens(in: text)
            
            // Update detected allergens
            await MainActor.run {
                detectedAllergens = allergens
                isProcessing = false
            }
        } catch {
            await MainActor.run {
                self.error = .unknown
                isProcessing = false
            }
        }
    }
}

// MARK: - Mock Services for Preview and Testing

/// Mock camera service for previews and testing
class MockCameraService: CameraServiceProtocol {
    var isActive: Bool = false
    var position: CameraPosition = .back
    var error: CameraError? = nil
    
    func setupCamera(position: CameraPosition) async throws {
        self.position = position
        // Simulate success
    }
    
    func startSession() async throws {
        isActive = true
        // Simulate success
    }
    
    func stopSession() async {
        isActive = false
    }
    
    func capturePhoto() async throws -> Image? {
        // Return a placeholder image
        return Image(systemName: "photo")
    }
    
    func switchCamera() async throws {
        position = position == .front ? .back : .front
    }
}

/// Mock OCR service for previews and testing
class MockOCRService: OCRServiceProtocol {
    #if os(iOS)
    func recognizeText(in image: UIImage) async throws -> String {
        return "Sample ingredients: Milk, Eggs, Wheat, Soy, Peanuts"
    }
    
    func recognizeText(in image: UIImage, region: CGRect) async throws -> String {
        return "Sample ingredients: Milk, Eggs, Wheat, Soy, Peanuts"
    }
    #elseif os(macOS)
    func recognizeText(in image: NSImage) async throws -> String {
        return "Sample ingredients: Milk, Eggs, Wheat, Soy, Peanuts"
    }
    
    func recognizeText(in image: NSImage, region: CGRect) async throws -> String {
        return "Sample ingredients: Milk, Eggs, Wheat, Soy, Peanuts"
    }
    #endif
}

/// Mock allergen service for previews and testing
class MockAllergenService: AllergenServiceProtocol {
    func detectAllergens(in text: String) async throws -> [AllergenMatch] {
        // Create some sample allergen matches
        let milk = Allergen(
            id: UUID(),
            name: "Milk",
            description: "Dairy product from cows",
            commonNames: ["Dairy", "Lactose", "Whey"],
            iconName: "drop.fill"
        )
        
        let eggs = Allergen(
            id: UUID(),
            name: "Eggs",
            description: "Eggs from chickens",
            commonNames: ["Egg whites", "Egg yolks", "Albumin"],
            iconName: "oval.fill"
        )
        
        return [
            AllergenMatch(
                id: UUID(),
                allergen: milk,
                matchedText: "Milk",
                sensitivityLevel: .severe
            ),
            AllergenMatch(
                id: UUID(),
                allergen: eggs,
                matchedText: "Eggs",
                sensitivityLevel: .moderate
            )
        ]
    }
    
    func getAllergens() async -> [Allergen] {
        // Return some sample allergens
        return [
            Allergen(
                id: UUID(),
                name: "Milk",
                description: "Dairy product from cows",
                commonNames: ["Dairy", "Lactose", "Whey"],
                iconName: "drop.fill"
            ),
            Allergen(
                id: UUID(),
                name: "Eggs",
                description: "Eggs from chickens",
                commonNames: ["Egg whites", "Egg yolks", "Albumin"],
                iconName: "oval.fill"
            )
        ]
    }
    
    func updateUserAllergens(_ allergens: [Allergen]) async {
        // Do nothing in the mock
    }
}

/// Mock permission service for previews and testing
class MockPermissionService: PermissionServiceProtocol {
    var cameraPermissionStatus: PermissionStatus = .authorized
    var photoLibraryPermissionStatus: PermissionStatus = .authorized
    
    func requestCameraPermission() async -> PermissionStatus {
        return .authorized
    }
    
    func requestPhotoLibraryPermission() async -> PermissionStatus {
        return .authorized
    }
    
    func openAppSettings() {
        // Do nothing in the mock
    }
} 