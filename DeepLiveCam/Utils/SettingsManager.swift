import Foundation
import SwiftUI

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var settings: AppSettings
    
    private init() {
        self.settings = AppSettings.load()
    }
    
    func updateSettings(_ newSettings: AppSettings) {
        settings = newSettings
        settings.save()
    }
    
    func resetToDefaults() {
        settings = AppSettings()
        settings.save()
    }
    
    // MARK: - Specific Settings Updates
    
    func updateVideoQuality(_ quality: VideoProcessingSettings.VideoQuality) {
        settings.defaultQuality = quality
        settings.save()
    }
    
    func updateOutputFormat(_ format: VideoProcessingSettings.OutputFormat) {
        settings.defaultFormat = format
        settings.save()
    }
    
    func updatePreserveMouth(_ preserve: Bool) {
        settings.preserveMouth = preserve
        settings.save()
    }
    
    func updatePreserveEyes(_ preserve: Bool) {
        settings.preserveEyes = preserve
        settings.save()
    }
    
    func updateBlendIntensity(_ intensity: Float) {
        settings.blendIntensity = intensity
        settings.save()
    }
    
    func updateAutoSave(_ autoSave: Bool) {
        settings.autoSave = autoSave
        settings.save()
    }
    
    func updateShowFaceBoxes(_ show: Bool) {
        settings.showFaceBoxes = show
        settings.save()
    }
    
    func updateEnableEnhancement(_ enable: Bool) {
        settings.enableEnhancement = enable
        settings.save()
    }
}

// MARK: - User Preferences

struct UserPreferences: Codable {
    var hasSeenTutorial: Bool = false
    var lastUsedSourceImage: String?
    var favoriteSettings: [String: Any] = [:]
    var usageCount: Int = 0
    var lastUsedDate: Date?
    
    static let shared = UserPreferences()
    
    private init() {}
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "UserPreferences")
        }
    }
    
    static func load() -> UserPreferences {
        guard let data = UserDefaults.standard.data(forKey: "UserPreferences"),
              let preferences = try? JSONDecoder().decode(UserPreferences.self, from: data) else {
            return UserPreferences()
        }
        return preferences
    }
}

// MARK: - App State Manager

class AppStateManager: ObservableObject {
    @Published var isFirstLaunch: Bool
    @Published var currentMode: AppMode = .camera
    @Published var isProcessing: Bool = false
    @Published var processingProgress: Double = 0.0
    
    enum AppMode {
        case camera
        case gallery
        case settings
        case tutorial
    }
    
    init() {
        let preferences = UserPreferences.load()
        self.isFirstLaunch = !preferences.hasSeenTutorial
    }
    
    func completeTutorial() {
        var preferences = UserPreferences.load()
        preferences.hasSeenTutorial = true
        preferences.save()
        isFirstLaunch = false
    }
    
    func startProcessing() {
        isProcessing = true
        processingProgress = 0.0
    }
    
    func updateProgress(_ progress: Double) {
        processingProgress = progress
    }
    
    func stopProcessing() {
        isProcessing = false
        processingProgress = 0.0
    }
}

// MARK: - Notification Manager

class NotificationManager: ObservableObject {
    @Published var notifications: [AppNotification] = []
    
    func showNotification(_ notification: AppNotification) {
        notifications.append(notification)
        
        // Auto-remove after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.removeNotification(notification.id)
        }
    }
    
    func removeNotification(_ id: UUID) {
        notifications.removeAll { $0.id == id }
    }
}

struct AppNotification: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let type: NotificationType
    
    enum NotificationType {
        case success
        case error
        case warning
        case info
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .warning: return .orange
            case .info: return .blue
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }
}
