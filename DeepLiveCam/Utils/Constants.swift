import Foundation
import UIKit

struct Constants {
    
    // MARK: - App Information
    struct App {
        static let name = "Deep Live Cam"
        static let version = "1.0.0"
        static let buildNumber = "1"
        static let bundleIdentifier = "com.deeplivecam.app"
    }
    
    // MARK: - UI Constants
    struct UI {
        static let cornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 8
        static let shadowOpacity: Float = 0.1
        static let animationDuration: Double = 0.3
        static let buttonHeight: CGFloat = 50
        static let spacing: CGFloat = 20
        static let padding: CGFloat = 16
    }
    
    // MARK: - Camera Constants
    struct Camera {
        static let defaultFrameRate: Int = 30
        static let maxFrameRate: Int = 60
        static let minFrameRate: Int = 15
        static let defaultResolution = CGSize(width: 1280, height: 720)
        static let maxResolution = CGSize(width: 1920, height: 1080)
    }
    
    // MARK: - Face Detection Constants
    struct FaceDetection {
        static let minFaceSize: CGFloat = 50
        static let maxFaceSize: CGFloat = 500
        static let confidenceThreshold: Float = 0.5
        static let maxFaces: Int = 10
    }
    
    // MARK: - Processing Constants
    struct Processing {
        static let maxImageSize: CGSize = CGSize(width: 1024, height: 1024)
        static let compressionQuality: CGFloat = 0.8
        static let maxProcessingTime: TimeInterval = 30.0
        static let memoryWarningThreshold: UInt64 = 100 * 1024 * 1024 // 100MB
    }
    
    // MARK: - File Constants
    struct File {
        static let maxFileSize: Int64 = 100 * 1024 * 1024 // 100MB
        static let supportedImageFormats = ["jpg", "jpeg", "png", "heic"]
        static let supportedVideoFormats = ["mov", "mp4", "m4v"]
        static let tempDirectory = "DeepLiveCamTemp"
    }
    
    // MARK: - Animation Constants
    struct Animation {
        static let springDamping: CGFloat = 0.8
        static let springResponse: CGFloat = 0.6
        static let fadeInDuration: Double = 0.2
        static let fadeOutDuration: Double = 0.2
        static let scaleAnimationDuration: Double = 0.3
    }
    
    // MARK: - Color Constants
    struct Colors {
        static let primary = UIColor.systemBlue
        static let secondary = UIColor.systemGray
        static let success = UIColor.systemGreen
        static let warning = UIColor.systemOrange
        static let error = UIColor.systemRed
        static let background = UIColor.systemBackground
        static let surface = UIColor.secondarySystemBackground
    }
    
    // MARK: - Notification Constants
    struct Notifications {
        static let processingStarted = "ProcessingStarted"
        static let processingCompleted = "ProcessingCompleted"
        static let processingFailed = "ProcessingFailed"
        static let memoryWarning = "MemoryWarning"
        static let faceDetected = "FaceDetected"
        static let faceLost = "FaceLost"
    }
    
    // MARK: - UserDefaults Keys
    struct UserDefaultsKeys {
        static let hasSeenTutorial = "hasSeenTutorial"
        static let lastUsedSourceImage = "lastUsedSourceImage"
        static let appSettings = "appSettings"
        static let userPreferences = "userPreferences"
        static let processingHistory = "processingHistory"
        static let favoriteSettings = "favoriteSettings"
    }
    
    // MARK: - Error Messages
    struct ErrorMessages {
        static let noCameraAccess = "Camera access is required for this app to function properly."
        static let noPhotoLibraryAccess = "Photo library access is required to select source images."
        static let noFacesDetected = "No faces detected in the selected image."
        static let processingFailed = "Failed to process the image. Please try again."
        static let memoryWarning = "Low memory detected. Please close other apps and try again."
        static let unsupportedFormat = "Unsupported file format. Please select a valid image or video file."
        static let fileTooLarge = "File is too large. Please select a smaller file."
    }
    
    // MARK: - Success Messages
    struct SuccessMessages {
        static let imageSaved = "Image saved to Photos successfully!"
        static let videoSaved = "Video saved to Photos successfully!"
        static let settingsSaved = "Settings saved successfully!"
        static let processingCompleted = "Processing completed successfully!"
    }
    
    // MARK: - URLs
    struct URLs {
        static let privacyPolicy = "https://deeplivecam.app/privacy"
        static let termsOfService = "https://deeplivecam.app/terms"
        static let support = "https://deeplivecam.app/support"
        static let github = "https://github.com/yourusername/IOS_DEEP_Live4"
    }
}

// MARK: - Extensions for Constants

extension Constants {
    static func getAppVersion() -> String {
        return "\(App.version) (\(App.buildNumber))"
    }
    
    static func getAppDisplayName() -> String {
        return App.name
    }
    
    static func getBundleIdentifier() -> String {
        return App.bundleIdentifier
    }
}

// MARK: - Debug Constants

#if DEBUG
struct DebugConstants {
    static let enableLogging = true
    static let enablePerformanceMonitoring = true
    static let enableMemoryMonitoring = true
    static let enableFaceDetectionDebug = true
    static let enableProcessingDebug = true
    static let logLevel: LogLevel = .debug
    
    enum LogLevel: Int {
        case error = 0
        case warning = 1
        case info = 2
        case debug = 3
        case verbose = 4
    }
}
#endif
