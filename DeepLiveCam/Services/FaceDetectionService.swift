import Foundation
import Vision
import CoreImage
import UIKit

class FaceDetectionService: ObservableObject {
    private let faceDetectionRequest = VNDetectFaceRectanglesRequest()
    private let faceLandmarksRequest = VNDetectFaceLandmarksRequest()
    
    init() {
        setupFaceDetection()
    }
    
    private func setupFaceDetection() {
        faceDetectionRequest.revision = VNDetectFaceRectanglesRequestRevision3
        faceLandmarksRequest.revision = VNDetectFaceLandmarksRequestRevision3
    }
    
    func detectFaces(in image: UIImage) -> [VNFaceObservation] {
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
    
    func detectFaceLandmarks(in image: UIImage) -> [VNFaceObservation] {
        guard let cgImage = image.cgImage else { return [] }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        var faces: [VNFaceObservation] = []
        
        do {
            try requestHandler.perform([faceLandmarksRequest])
            faces = faceLandmarksRequest.results ?? []
        } catch {
            print("Face landmarks detection error: \(error)")
        }
        
        return faces
    }
    
    func getFaceRectangles(from observations: [VNFaceObservation], in imageSize: CGSize) -> [CGRect] {
        return observations.map { observation in
            VNImageRectForNormalizedRect(
                observation.boundingBox,
                Int(imageSize.width),
                Int(imageSize.height)
            )
        }
    }
    
    func cropFace(from image: UIImage, faceObservation: VNFaceObservation) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let imageSize = image.size
        let faceRect = VNImageRectForNormalizedRect(
            faceObservation.boundingBox,
            Int(imageSize.width),
            Int(imageSize.height)
        )
        
        // Add some padding around the face
        let padding: CGFloat = 20
        let paddedRect = CGRect(
            x: max(0, faceRect.origin.x - padding),
            y: max(0, faceRect.origin.y - padding),
            width: min(imageSize.width - faceRect.origin.x + padding, faceRect.width + 2 * padding),
            height: min(imageSize.height - faceRect.origin.y + padding, faceRect.height + 2 * padding)
        )
        
        guard let croppedImage = cgImage.cropping(to: paddedRect) else { return nil }
        return UIImage(cgImage: croppedImage)
    }
    
    func alignFace(_ image: UIImage, faceObservation: VNFaceObservation) -> UIImage? {
        // This is a simplified face alignment
        // In a real implementation, you would use more sophisticated techniques
        return cropFace(from: image, faceObservation: faceObservation)
    }
}
