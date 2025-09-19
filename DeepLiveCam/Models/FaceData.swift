import Foundation
import Vision
import CoreImage
import UIKit

// MARK: - Face Data Models
struct FaceData {
    let observation: VNFaceObservation
    let landmarks: VNFaceLandmarks2D?
    let image: UIImage
    let boundingBox: CGRect
    let confidence: Float
    
    init(observation: VNFaceObservation, image: UIImage) {
        self.observation = observation
        self.landmarks = observation.landmarks
        self.image = image
        self.boundingBox = VNImageRectForNormalizedRect(
            observation.boundingBox,
            Int(image.size.width),
            Int(image.size.height)
        )
        self.confidence = observation.confidence
    }
}

// MARK: - Face Swap Configuration
struct FaceSwapConfiguration {
    let sourceFace: FaceData
    let targetFace: FaceData
    let blendMode: BlendMode
    let intensity: Float
    let preserveMouth: Bool
    let preserveEyes: Bool
    
    enum BlendMode: String, CaseIterable {
        case normal = "Normal"
        case overlay = "Overlay"
        case softLight = "Soft Light"
        case hardLight = "Hard Light"
    }
}

// MARK: - Processing Result
struct ProcessingResult {
    let success: Bool
    let processedImage: UIImage?
    let error: Error?
    let processingTime: TimeInterval
    
    init(success: Bool, processedImage: UIImage? = nil, error: Error? = nil, processingTime: TimeInterval = 0) {
        self.success = success
        self.processedImage = processedImage
        self.error = error
        self.processingTime = processingTime
    }
}

// MARK: - Face Detection Result
struct FaceDetectionResult {
    let faces: [FaceData]
    let processingTime: TimeInterval
    let success: Bool
    let error: Error?
    
    init(faces: [FaceData], processingTime: TimeInterval, success: Bool = true, error: Error? = nil) {
        self.faces = faces
        self.processingTime = processingTime
        self.success = success
        self.error = error
    }
}

// MARK: - Video Processing Settings
struct VideoProcessingSettings {
    let frameRate: Int
    let quality: VideoQuality
    let outputFormat: OutputFormat
    let preserveAudio: Bool
    
    enum VideoQuality: String, CaseIterable {
        case low = "Low (480p)"
        case medium = "Medium (720p)"
        case high = "High (1080p)"
        case ultra = "Ultra (4K)"
        
        var resolution: CGSize {
            switch self {
            case .low: return CGSize(width: 640, height: 480)
            case .medium: return CGSize(width: 1280, height: 720)
            case .high: return CGSize(width: 1920, height: 1080)
            case .ultra: return CGSize(width: 3840, height: 2160)
            }
        }
    }
    
    enum OutputFormat: String, CaseIterable {
        case mov = "MOV"
        case mp4 = "MP4"
        case m4v = "M4V"
    }
}

// MARK: - App Settings
struct AppSettings: Codable {
    var autoSave: Bool = true
    var defaultQuality: VideoProcessingSettings.VideoQuality = .high
    var defaultFormat: VideoProcessingSettings.OutputFormat = .mp4
    var preserveMouth: Bool = true
    var preserveEyes: Bool = false
    var blendIntensity: Float = 0.8
    var showFaceBoxes: Bool = false
    var enableEnhancement: Bool = true
    
    static let shared = AppSettings()
    
    init() {}
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "AppSettings")
        }
    }
    
    static func load() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: "AppSettings"),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return AppSettings()
        }
        return settings
    }
}
