import Foundation
import Vision
import CoreML
import CoreImage
import UIKit

class AdvancedFaceProcessor: ObservableObject {
    @Published var isProcessing = false
    @Published var processingProgress: Double = 0.0
    
    private let context = CIContext()
    private let faceDetectionRequest = VNDetectFaceRectanglesRequest()
    private let faceLandmarksRequest = VNDetectFaceLandmarksRequest()
    
    init() {
        setupFaceDetection()
    }
    
    private func setupFaceDetection() {
        faceDetectionRequest.revision = VNDetectFaceRectanglesRequestRevision3
        faceLandmarksRequest.revision = VNDetectFaceLandmarksRequestRevision3
    }
    
    func processAdvancedFaceSwap(
        sourceImage: UIImage,
        targetImage: UIImage,
        configuration: FaceSwapConfiguration
    ) async -> ProcessingResult {
        let startTime = Date()
        
        await MainActor.run {
            isProcessing = true
            processingProgress = 0.0
        }
        
        do {
            // Step 1: Detect faces
            await updateProgress(0.1)
            let sourceFaces = detectFaces(in: sourceImage)
            let targetFaces = detectFaces(in: targetImage)
            
            guard let sourceFace = sourceFaces.first,
                  let targetFace = targetFaces.first else {
                return ProcessingResult(success: false, error: FaceProcessingError.noFacesDetected)
            }
            
            // Step 2: Extract face landmarks
            await updateProgress(0.2)
            let sourceLandmarks = extractFaceLandmarks(from: sourceImage, face: sourceFace)
            let targetLandmarks = extractFaceLandmarks(from: targetImage, face: targetFace)
            
            // Step 3: Align faces
            await updateProgress(0.3)
            let alignedSource = alignFace(sourceImage, landmarks: sourceLandmarks)
            let alignedTarget = alignFace(targetImage, landmarks: targetLandmarks)
            
            // Step 4: Create face mask
            await updateProgress(0.4)
            let faceMask = createFaceMask(from: targetLandmarks, imageSize: targetImage.size)
            
            // Step 5: Apply face swap
            await updateProgress(0.6)
            let swappedFace = applyFaceSwap(
                sourceFace: alignedSource,
                targetFace: alignedTarget,
                mask: faceMask,
                configuration: configuration
            )
            
            // Step 6: Blend with original image
            await updateProgress(0.8)
            let result = blendFaces(
                originalImage: targetImage,
                swappedFace: swappedFace,
                mask: faceMask,
                configuration: configuration
            )
            
            await updateProgress(1.0)
            
            let processingTime = Date().timeIntervalSince(startTime)
            
            await MainActor.run {
                isProcessing = false
            }
            
            return ProcessingResult(
                success: true,
                processedImage: result,
                processingTime: processingTime
            )
            
        } catch {
            await MainActor.run {
                isProcessing = false
            }
            
            return ProcessingResult(
                success: false,
                error: error,
                processingTime: Date().timeIntervalSince(startTime)
            )
        }
    }
    
    private func detectFaces(in image: UIImage) -> [VNFaceObservation] {
        guard let cgImage = image.cgImage else { return [] }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        var faces: [VNFaceObservation] = []
        
        do {
            try requestHandler.perform([faceDetectionRequest])
            faces = faceDetectionRequest.results ?? []
        } catch {
            print("Face detection error: \(error)")
        }
        
        return faces
    }
    
    private func extractFaceLandmarks(from image: UIImage, face: VNFaceObservation) -> VNFaceLandmarks2D? {
        guard let cgImage = image.cgImage else { return nil }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try requestHandler.perform([faceLandmarksRequest])
            return faceLandmarksRequest.results?.first?.landmarks
        } catch {
            print("Face landmarks extraction error: \(error)")
            return nil
        }
    }
    
    private func alignFace(_ image: UIImage, landmarks: VNFaceLandmarks2D?) -> UIImage {
        guard let landmarks = landmarks,
              let leftEye = landmarks.leftEye,
              let rightEye = landmarks.rightEye,
              let leftEyePoints = leftEye.normalizedPoints.first,
              let rightEyePoints = rightEye.normalizedPoints.first else {
            return image
        }
        
        // Calculate eye angle
        let eyeVector = CGPoint(
            x: rightEyePoints.x - leftEyePoints.x,
            y: rightEyePoints.y - leftEyePoints.y
        )
        
        let angle = atan2(eyeVector.y, eyeVector.x)
        
        // Rotate image to align eyes horizontally
        let rotatedImage = image.rotated(by: -angle)
        
        return rotatedImage
    }
    
    private func createFaceMask(from landmarks: VNFaceLandmarks2D?, imageSize: CGSize) -> UIImage? {
        guard let landmarks = landmarks else { return nil }
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: imageSize))
        
        context.setFillColor(UIColor.black.cgColor)
        
        // Create mask based on face landmarks
        if let faceContour = landmarks.faceContour {
            let points = faceContour.normalizedPoints.map { point in
                CGPoint(
                    x: point.x * imageSize.width,
                    y: (1 - point.y) * imageSize.height
                )
            }
            
            context.move(to: points[0])
            for point in points.dropFirst() {
                context.addLine(to: point)
            }
            context.closePath()
            context.fillPath()
        }
        
        let maskImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return maskImage
    }
    
    private func applyFaceSwap(
        sourceFace: UIImage,
        targetFace: UIImage,
        mask: UIImage?,
        configuration: FaceSwapConfiguration
    ) -> UIImage? {
        // This is a simplified implementation
        // In a real app, you would use more sophisticated techniques
        
        let size = targetFace.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        // Draw target face
        targetFace.draw(in: CGRect(origin: .zero, size: size))
        
        // Apply source face with mask
        if let mask = mask {
            let sourceRect = CGRect(origin: .zero, size: size)
            sourceFace.draw(in: sourceRect, blendMode: .normal, alpha: configuration.intensity)
        }
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
    
    private func blendFaces(
        originalImage: UIImage,
        swappedFace: UIImage?,
        mask: UIImage?,
        configuration: FaceSwapConfiguration
    ) -> UIImage? {
        guard let swappedFace = swappedFace else { return originalImage }
        
        let size = originalImage.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        // Draw original image
        originalImage.draw(in: CGRect(origin: .zero, size: size))
        
        // Apply swapped face with mask
        if let mask = mask {
            let maskRect = CGRect(origin: .zero, size: size)
            swappedFace.draw(in: maskRect, blendMode: .normal, alpha: configuration.intensity)
        }
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
    
    @MainActor
    private func updateProgress(_ progress: Double) {
        processingProgress = progress
    }
}

// MARK: - Error Types
// FaceProcessingError is defined in FaceData.swift

// MARK: - UIImage Extensions
extension UIImage {
    func rotated(by angle: CGFloat) -> UIImage {
        let radians = angle * .pi / 180
        let rotatedSize = CGSize(
            width: abs(cos(radians)) * size.width + abs(sin(radians)) * size.height,
            height: abs(sin(radians)) * size.width + abs(cos(radians)) * size.height
        )
        
        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        
        context.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        context.rotate(by: radians)
        context.translateBy(x: -size.width / 2, y: -size.height / 2)
        
        draw(in: CGRect(origin: .zero, size: size))
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return rotatedImage ?? self
    }
}
