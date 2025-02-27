import Foundation
import Vision
import SwiftUI

#if os(iOS)
import UIKit
typealias PlatformImage = UIImage
#elseif os(macOS)
import AppKit
typealias PlatformImage = NSImage
#endif

// Import the OCRServiceProtocol
// This is needed because the protocol is defined in ServiceProtocols.swift
// and we need to make sure it's in scope
// MARK: - OCR Service Protocol

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

/// Errors that can occur during OCR operations
enum OCRError: Error, LocalizedError, Identifiable {
    case invalidImage
    case recognitionFailed
    case serviceDeallocated
    case cancelled
    
    var id: UUID {
        UUID()
    }
    
    var title: String {
        switch self {
        case .invalidImage:
            return "Invalid Image"
        case .recognitionFailed:
            return "Recognition Failed"
        case .serviceDeallocated:
            return "Service Error"
        case .cancelled:
            return "Operation Cancelled"
        }
    }
    
    var message: String {
        switch self {
        case .invalidImage:
            return "The provided image could not be processed."
        case .recognitionFailed:
            return "Text recognition failed."
        case .serviceDeallocated:
            return "The OCR service was deallocated during processing."
        case .cancelled:
            return "The OCR operation was cancelled."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidImage:
            return "Try using a different image or adjusting the lighting."
        case .recognitionFailed:
            return "Try again with a clearer image or better lighting."
        case .serviceDeallocated:
            return "Please try again."
        case .cancelled:
            return "You can try again when ready."
        }
    }
    
    // LocalizedError conformance
    var errorDescription: String? {
        title
    }
    
    var failureReason: String? {
        message
    }
}

/// Service for performing OCR (Optical Character Recognition) on images
final class OCRService: OCRServiceProtocol, ObservableObject {
    // MARK: - Private Properties
    
    /// The current OCR request
    private var currentRequest: VNRequest?
    
    /// Queue for OCR operations
    private let ocrQueue = DispatchQueue(label: "com.allerguard.ocrservice", qos: .userInitiated)
    
    // MARK: - Initialization
    
    init() {
        // Initialize the OCR service
    }
    
    // MARK: - OCRServiceProtocol
    
    /// Recognizes text in an image
    /// - Parameter image: The image to recognize text in
    /// - Returns: The recognized text
    func recognizeText(in image: PlatformImage) async throws -> String {
        guard let cgImage = platformImageToCGImage(image) else {
            throw OCRError.invalidImage
        }
        
        return try await performTextRecognition(on: cgImage, regionOfInterest: nil)
    }
    
    /// Recognizes text in an image at a specific region
    /// - Parameters:
    ///   - image: The image to recognize text in
    ///   - region: The region to recognize text in
    /// - Returns: The recognized text
    func recognizeText(in image: PlatformImage, region: CGRect) async throws -> String {
        guard let cgImage = platformImageToCGImage(image) else {
            throw OCRError.invalidImage
        }
        
        return try await performTextRecognition(on: cgImage, regionOfInterest: region)
    }
    
    /// Cancels any ongoing OCR operations
    func cancelRecognition() {
        currentRequest?.cancel()
        currentRequest = nil
    }
    
    // MARK: - Private Methods
    
    /// Converts a platform-specific image to CGImage
    /// - Parameter image: The platform-specific image
    /// - Returns: The CGImage representation, or nil if conversion fails
    private func platformImageToCGImage(_ image: PlatformImage) -> CGImage? {
        #if os(iOS)
        return image.cgImage
        #elseif os(macOS)
        var imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        return image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        #endif
    }
    
    /// Performs text recognition on a CGImage
    /// - Parameters:
    ///   - cgImage: The CGImage to process
    ///   - regionOfInterest: Optional region of interest in normalized coordinates (0-1)
    /// - Returns: The recognized text
    private func performTextRecognition(on cgImage: CGImage, regionOfInterest: CGRect?) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            // Create a text recognition request
            let request = VNRecognizeTextRequest { [weak self] request, error in
                guard let self = self else {
                    continuation.resume(throwing: OCRError.serviceDeallocated)
                    return
                }
                
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                // VNRequest doesn't have a direct way to check if it's cancelled
                // We'll rely on the error parameter to indicate cancellation
                
                if let recognizedText = self.processTextRecognitionResults(request), !recognizedText.isEmpty {
                    continuation.resume(returning: recognizedText)
                } else {
                    continuation.resume(throwing: OCRError.recognitionFailed)
                }
            }
            
            // Configure the request
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            if let regionOfInterest = regionOfInterest {
                request.regionOfInterest = regionOfInterest
            }
            
            self.currentRequest = request
            
            // Perform the request
            do {
                try requestHandler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    /// Processes the results of a text recognition request
    /// - Parameter request: The completed text recognition request
    /// - Returns: The recognized text
    private func processTextRecognitionResults(_ request: VNRequest) -> String? {
        // Get the text observation results
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            return nil
        }
        
        // Extract the recognized text
        let recognizedText = observations.compactMap { observation in
            observation.topCandidates(1).first?.string
        }.joined(separator: " ")
        
        return recognizedText.isEmpty ? nil : recognizedText
    }
} 