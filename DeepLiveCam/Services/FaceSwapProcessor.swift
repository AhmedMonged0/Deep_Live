import SwiftUI
import Vision
import CoreML
import CoreImage
import UIKit

class FaceSwapProcessor: ObservableObject {
    @Published var processedImage: UIImage?
    @Published var isProcessing = false
    
    private let faceDetectionRequest = VNDetectFaceRectanglesRequest()
    private let faceLandmarksRequest = VNDetectFaceLandmarksRequest()
    private let context = CIContext()
    
    init() {
        setupFaceDetection()
    }
    
    private func setupFaceDetection() {
        faceDetectionRequest.revision = VNDetectFaceRectanglesRequestRevision3
        faceLandmarksRequest.revision = VNDetectFaceLandmarksRequestRevision3
    }
    
    func processFrame(_ frame: UIImage, with sourceImage: UIImage?) {
        guard let sourceImage = sourceImage else {
            processedImage = frame
            return
        }
        
        isProcessing = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Detect faces in both images
            let frameFaces = self.detectFaces(in: frame)
            let sourceFaces = self.detectFaces(in: sourceImage)
            
            guard let frameFace = frameFaces.first,
                  let sourceFace = sourceFaces.first else {
                DispatchQueue.main.async {
                    self.processedImage = frame
                    self.isProcessing = false
                }
                return
            }
            
            // Perform face swap
            let result = self.performFaceSwap(
                frame: frame,
                frameFace: frameFace,
                sourceImage: sourceImage,
                sourceFace: sourceFace
            )
            
            DispatchQueue.main.async {
                self.processedImage = result
                self.isProcessing = false
            }
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
    
    private func performFaceSwap(
        frame: UIImage,
        frameFace: VNFaceObservation,
        sourceImage: UIImage,
        sourceFace: VNFaceObservation
    ) -> UIImage {
        // This is a simplified face swap implementation
        // In a real app, you would use more sophisticated techniques
        
        guard let frameCGImage = frame.cgImage,
              let sourceCGImage = sourceImage.cgImage else {
            return frame
        }
        
        let frameSize = frame.size
        let sourceSize = sourceImage.size
        
        // Calculate face regions
        let frameFaceRect = VNImageRectForNormalizedRect(
            frameFace.boundingBox,
            Int(frameSize.width),
            Int(frameSize.height)
        )
        
        let sourceFaceRect = VNImageRectForNormalizedRect(
            sourceFace.boundingBox,
            Int(sourceSize.width),
            Int(sourceSize.height)
        )
        
        // Create a simple face overlay (simplified version)
        let resultImage = createFaceOverlay(
            frameImage: frameCGImage,
            frameFaceRect: frameFaceRect,
            sourceImage: sourceCGImage,
            sourceFaceRect: sourceFaceRect
        )
        
        return resultImage
    }
    
    private func createFaceOverlay(
        frameImage: CGImage,
        frameFaceRect: CGRect,
        sourceImage: CGImage,
        sourceFaceRect: CGRect
    ) -> UIImage {
        let frameSize = CGSize(width: frameImage.width, height: frameImage.height)
        
        UIGraphicsBeginImageContextWithOptions(frameSize, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage(cgImage: frameImage)
        }
        
        // Draw original frame
        context.draw(frameImage, in: CGRect(origin: .zero, size: frameSize))
        
        // Calculate scaling factor for source face
        let scaleX = frameFaceRect.width / sourceFaceRect.width
        let scaleY = frameFaceRect.height / sourceFaceRect.height
        let scale = min(scaleX, scaleY)
        
        // Calculate source face region to extract
        let sourceExtractRect = CGRect(
            x: sourceFaceRect.origin.x,
            y: sourceFaceRect.origin.y,
            width: sourceFaceRect.width,
            height: sourceFaceRect.height
        )
        
        // Extract and scale source face
        if let croppedSource = sourceImage.cropping(to: sourceExtractRect) {
            let scaledSize = CGSize(
                width: sourceExtractRect.width * scale,
                height: sourceExtractRect.height * scale
            )
            
            let scaledSource = UIImage(cgImage: croppedSource)
                .resized(to: scaledSize)
            
            // Draw scaled source face onto frame
            let drawRect = CGRect(
                x: frameFaceRect.origin.x,
                y: frameFaceRect.origin.y,
                width: scaledSize.width,
                height: scaledSize.height
            )
            
            context.draw(scaledSource.cgImage!, in: drawRect)
        }
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage(cgImage: frameImage)
        UIGraphicsEndImageContext()
        
        return resultImage
    }
}

// Helper extension for image resizing
extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage ?? self
    }
}
