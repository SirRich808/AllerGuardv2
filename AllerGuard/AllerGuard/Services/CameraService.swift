import Foundation
import AVFoundation
import SwiftUI
import Combine

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// TODO: Import camera types from Models/CameraTypes.swift
// This centralizes our type definitions and avoids duplication
// For now, we're using the types defined in AllerGuardApp.swift

// MARK: - Camera Service Protocol

/// Protocol for camera operations
protocol CameraServiceProtocol: ObservableObject {
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
    
    /// Creates a preview layer for displaying the camera feed
    /// - Parameter frame: The frame for the preview layer
    /// - Returns: The configured preview layer
    func makePreviewLayer(frame: CGRect) -> AVCaptureVideoPreviewLayer
}

/// Service for camera operations
final class CameraService: NSObject, ObservableObject, CameraServiceProtocol {
    // MARK: - Published Properties
    
    /// Whether the camera is currently active
    @Published private(set) var isActive = false
    
    /// The current camera position
    @Published private(set) var position: CameraPosition = .back
    
    /// The current camera error, if any
    @Published private(set) var error: CameraError?
    
    // MARK: - Private Properties
    
    /// The capture session for the camera
    private let captureSession = AVCaptureSession()
    
    /// The photo output for capturing still images
    private let photoOutput = AVCapturePhotoOutput()
    
    /// The video preview layer for displaying the camera feed
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    /// The current photo capture completion handler
    private var photoCaptureCompletionHandler: ((Image?, Error?) -> Void)?
    
    /// Queue for camera operations
    private let sessionQueue = DispatchQueue(label: "com.allerguard.cameraservice", qos: .userInitiated)
    
    /// Cancellable storage for subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        
        // Setup notification observers for session interruptions
        setupNotificationObservers()
    }
    
    deinit {
        // Clean up resources
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    // MARK: - Public Methods
    
    /// Sets up the camera with the specified position
    /// - Parameter position: The camera position to use
    /// - Throws: CameraError if setup fails
    func setupCamera(position: CameraPosition = .back) async throws {
        // Clear any previous errors
        updateError(nil)
        
        self.position = position
        
        // Check camera authorization
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch authorizationStatus {
        case .notDetermined:
            // Request authorization
            let isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            guard isAuthorized else {
                let error = CameraError.accessDenied
                updateError(error)
                throw error
            }
        case .restricted, .denied:
            let error = CameraError.accessDenied
            updateError(error)
            throw error
        case .authorized:
            break
        @unknown default:
            let error = CameraError.unknown
            updateError(error)
            throw error
        }
        
        // Configure the capture session
        return try await withCheckedThrowingContinuation { continuation in
            sessionQueue.async { [weak self] in
                guard let self = self else {
                    let error = CameraError.serviceDeallocated
                    self?.updateError(error)
                    continuation.resume(throwing: error)
                    return
                }
                
                do {
                    // Begin configuration
                    self.captureSession.beginConfiguration()
                    
                    // Reset the session
                    self.captureSession.inputs.forEach { self.captureSession.removeInput($0) }
                    self.captureSession.outputs.forEach { self.captureSession.removeOutput($0) }
                    
                    // Set the quality level
                    self.captureSession.sessionPreset = .photo
                    
                    // Add video input
                    try self.configureVideoInput(position: position)
                    
                    // Add photo output
                    try self.configurePhotoOutput()
                    
                    // Commit configuration
                    self.captureSession.commitConfiguration()
                    
                    continuation.resume()
                } catch {
                    self.captureSession.commitConfiguration()
                    
                    if let cameraError = error as? CameraError {
                        self.updateError(cameraError)
                        continuation.resume(throwing: cameraError)
                    } else {
                        let wrappedError = CameraError.setupFailed
                        self.updateError(wrappedError)
                        continuation.resume(throwing: wrappedError)
                    }
                }
            }
        }
    }
    
    /// Starts the camera session
    /// - Throws: CameraError if starting the session fails
    func startSession() async throws {
        // Clear any previous errors
        updateError(nil)
        
        return try await withCheckedThrowingContinuation { continuation in
            sessionQueue.async { [weak self] in
                guard let self = self else {
                    let error = CameraError.serviceDeallocated
                    self?.updateError(error)
                    continuation.resume(throwing: error)
                    return
                }
                
                if !self.captureSession.isRunning {
                    self.captureSession.startRunning()
                    
                    DispatchQueue.main.async {
                        self.isActive = true
                    }
                }
                
                continuation.resume()
            }
        }
    }
    
    /// Stops the camera session
    func stopSession() async {
        // Clear any previous errors
        updateError(nil)
        
        await withCheckedContinuation { continuation in
            sessionQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume()
                    return
                }
                
                if self.captureSession.isRunning {
                    self.captureSession.stopRunning()
                    
                    DispatchQueue.main.async {
                        self.isActive = false
                    }
                }
                
                continuation.resume()
            }
        }
    }
    
    /// Captures a photo from the camera
    /// - Returns: The captured image, or nil if capture fails
    /// - Throws: CameraError if capturing the photo fails
    func capturePhoto() async throws -> Image? {
        // Clear any previous errors
        updateError(nil)
        
        guard captureSession.isRunning else {
            let error = CameraError.sessionNotRunning
            updateError(error)
            throw error
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            sessionQueue.async { [weak self] in
                guard let self = self else {
                    let error = CameraError.serviceDeallocated
                    self?.updateError(error)
                    continuation.resume(throwing: error)
                    return
                }
                
                let photoSettings = AVCapturePhotoSettings()
                
                // Configure photo settings for optimal food label scanning
                photoSettings.isHighResolutionPhotoEnabled = true
                photoSettings.flashMode = .auto
                
                // Store a weak reference to the continuation to avoid retain cycles
                let captureHandler: ((Image?, Error?) -> Void) = { [weak self] (image, error) in
                    if let error = error {
                        self?.updateError(error as? CameraError ?? .captureFailed)
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let image = image else {
                        let error = CameraError.captureFailed
                        self?.updateError(error)
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    continuation.resume(returning: image)
                }
                
                self.photoCaptureCompletionHandler = captureHandler
                
                self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
            }
        }
    }
    
    /// Switches between front and back cameras
    /// - Throws: CameraError if switching cameras fails
    func switchCamera() async throws {
        // Clear any previous errors
        updateError(nil)
        
        let newPosition: CameraPosition = position == .front ? .back : .front
        
        // Stop the session
        await stopSession()
        
        // Setup with new position
        try await setupCamera(position: newPosition)
        
        // Start the session again
        try await startSession()
    }
    
    /// Creates a preview layer for displaying the camera feed
    /// - Parameter frame: The frame for the preview layer
    /// - Returns: The configured preview layer
    func makePreviewLayer(frame: CGRect) -> AVCaptureVideoPreviewLayer {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.frame = frame
        layer.videoGravity = .resizeAspectFill
        videoPreviewLayer = layer
        return layer
    }
    
    // MARK: - Private Methods
    
    /// Updates the error property on the main thread
    /// - Parameter error: The error to set, or nil to clear
    private func updateError(_ error: CameraError?) {
        DispatchQueue.main.async { [weak self] in
            self?.error = error
        }
    }
    
    /// Sets up notification observers for camera session events
    private func setupNotificationObservers() {
        // Handle session interruptions (e.g., phone calls)
        NotificationCenter.default
            .publisher(for: .AVCaptureSessionWasInterrupted)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.isActive = false
                }
            }
            .store(in: &cancellables)
        
        // Handle session resumption after interruption
        NotificationCenter.default
            .publisher(for: .AVCaptureSessionInterruptionEnded)
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                Task {
                    do {
                        try await self.startSession()
                    } catch {
                        self.updateError(error as? CameraError ?? .setupFailed)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    /// Configures the video input for the capture session
    /// - Parameter position: The camera position to use
    /// - Throws: CameraError if configuration fails
    private func configureVideoInput(position: CameraPosition) throws {
        // Get the camera device
        guard let videoDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: position == .front ? .front : .back
        ) else {
            throw CameraError.deviceNotAvailable
        }
        
        // Configure camera for optimal food label scanning
        try configureCameraDevice(videoDevice)
        
        // Create the input
        let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
        
        // Add the input to the session
        guard captureSession.canAddInput(videoDeviceInput) else {
            throw CameraError.inputNotSupported
        }
        
        captureSession.addInput(videoDeviceInput)
    }
    
    /// Configures the camera device for optimal food label scanning
    /// - Parameter device: The camera device to configure
    /// - Throws: CameraError if configuration fails
    private func configureCameraDevice(_ device: AVCaptureDevice) throws {
        do {
            try device.lockForConfiguration()
            
            // Enable auto-focus
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            
            // Enable auto-exposure
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }
            
            // Enable auto white balance
            if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                device.whiteBalanceMode = .continuousAutoWhiteBalance
            }
            
            // Enable low-light boost if available (iOS only)
            #if os(iOS)
            if device.isLowLightBoostSupported {
                device.automaticallyEnablesLowLightBoostWhenAvailable = true
            }
            #endif
            
            device.unlockForConfiguration()
        } catch {
            throw CameraError.setupFailed
        }
    }
    
    /// Configures the photo output for the capture session
    /// - Throws: CameraError if configuration fails
    private func configurePhotoOutput() throws {
        // Configure photo output
        guard captureSession.canAddOutput(photoOutput) else {
            throw CameraError.outputNotSupported
        }
        
        photoOutput.isHighResolutionCaptureEnabled = true
        photoOutput.maxPhotoQualityPrioritization = .quality
        
        captureSession.addOutput(photoOutput)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            updateError(CameraError.captureFailed)
            photoCaptureCompletionHandler?(nil, error)
            return
        }
        
        // Get the image data
        guard let imageData = photo.fileDataRepresentation() else {
            updateError(CameraError.invalidPhotoData)
            photoCaptureCompletionHandler?(nil, CameraError.invalidPhotoData)
            return
        }
        
        // Convert to Image
        #if os(iOS)
        if let uiImage = UIImage(data: imageData) {
            let swiftUIImage = Image(uiImage: uiImage)
            photoCaptureCompletionHandler?(swiftUIImage, nil)
        } else {
            updateError(CameraError.invalidPhotoData)
            photoCaptureCompletionHandler?(nil, CameraError.invalidPhotoData)
        }
        #elseif os(macOS)
        if let nsImage = NSImage(data: imageData) {
            let swiftUIImage = Image(nsImage: nsImage)
            photoCaptureCompletionHandler?(swiftUIImage, nil)
        } else {
            updateError(CameraError.invalidPhotoData)
            photoCaptureCompletionHandler?(nil, CameraError.invalidPhotoData)
        }
        #else
        updateError(CameraError.invalidPhotoData)
        photoCaptureCompletionHandler?(nil, CameraError.invalidPhotoData)
        #endif
        
        // Clear the completion handler to avoid memory leaks
        photoCaptureCompletionHandler = nil
    }
}

// MARK: - Supporting Types
// These types are also defined in ServiceProtocols.swift and should eventually be imported from there

/// Camera position (front or back)
enum CameraPosition {
    case front
    case back
}

/// Errors that can occur during camera operations
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
    
    var title: String {
        switch self {
        case .accessDenied:
            return "Camera Access Denied"
        case .deviceNotAvailable:
            return "Camera Not Available"
        case .setupFailed:
            return "Camera Setup Failed"
        case .inputNotSupported:
            return "Camera Input Not Supported"
        case .outputNotSupported:
            return "Camera Output Not Supported"
        case .sessionNotRunning:
            return "Camera Not Running"
        case .captureFailed:
            return "Photo Capture Failed"
        case .invalidPhotoData:
            return "Invalid Photo Data"
        case .serviceDeallocated:
            return "Camera Service Error"
        case .unknown:
            return "Unknown Camera Error"
        }
    }
    
    var message: String {
        switch self {
        case .accessDenied:
            return "AllerGuard needs access to your camera to scan food labels."
        case .deviceNotAvailable:
            return "No camera device is available on this device."
        case .setupFailed:
            return "Failed to set up the camera."
        case .inputNotSupported:
            return "The camera input is not supported."
        case .outputNotSupported:
            return "The camera output is not supported."
        case .sessionNotRunning:
            return "The camera session is not running."
        case .captureFailed:
            return "Failed to capture a photo."
        case .invalidPhotoData:
            return "The captured photo data is invalid."
        case .serviceDeallocated:
            return "The camera service was deallocated during operation."
        case .unknown:
            return "An unknown camera error occurred."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .accessDenied:
            return "Please enable camera access in Settings."
        case .deviceNotAvailable:
            return "Try using a device with a camera."
        case .setupFailed:
            return "Try restarting the app."
        case .inputNotSupported, .outputNotSupported:
            return "Try using a different device."
        case .sessionNotRunning:
            return "Try starting the camera again."
        case .captureFailed, .invalidPhotoData:
            return "Try taking another photo."
        case .serviceDeallocated:
            return "Try restarting the app."
        case .unknown:
            return "Try restarting the app."
        }
    }
    
    // Keep LocalizedError conformance for backward compatibility
    var errorDescription: String? {
        title
    }
    
    var failureReason: String? {
        message
    }
} 