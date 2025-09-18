import Foundation

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: Language = .english
    @Published var localizedStrings: [String: String] = [:]
    
    private init() {
        loadLanguage()
        loadLocalizedStrings()
    }
    
    // MARK: - Language Management
    
    func setLanguage(_ language: Language) {
        currentLanguage = language
        loadLocalizedStrings()
        saveLanguage()
    }
    
    private func loadLanguage() {
        if let languageRawValue = UserDefaults.standard.object(forKey: "AppLanguage") as? Int,
           let language = Language(rawValue: languageRawValue) {
            currentLanguage = language
        }
    }
    
    private func saveLanguage() {
        UserDefaults.standard.set(currentLanguage.rawValue, forKey: "AppLanguage")
    }
    
    // MARK: - Localization
    
    func localizedString(for key: String) -> String {
        return localizedStrings[key] ?? key
    }
    
    private func loadLocalizedStrings() {
        let fileName = "\(currentLanguage.code)"
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json"),
              let data = NSData(contentsOfFile: path),
              let json = try? JSONSerialization.jsonObject(with: data as Data) as? [String: String] else {
            localizedStrings = getDefaultStrings()
            return
        }
        localizedStrings = json
    }
    
    private func getDefaultStrings() -> [String: String] {
        return [
            "app_name": "Deep Live Cam",
            "camera": "Camera",
            "gallery": "Gallery",
            "settings": "Settings",
            "statistics": "Statistics",
            "face_swap": "Face Swap",
            "select_source_image": "Select Source Image",
            "start_camera": "Start Camera",
            "stop_camera": "Stop Camera",
            "save_frame": "Save Frame",
            "permissions_required": "Permissions Required",
            "camera_access_required": "Camera access is required for face swapping",
            "photo_library_access_required": "Photo library access is required to select source images",
            "grant_camera_access": "Grant Camera Access",
            "grant_photo_library_access": "Grant Photo Library Access",
            "open_settings": "Open Settings",
            "about": "About",
            "version": "Version",
            "build": "Build",
            "privacy_policy": "Privacy Policy",
            "terms_of_service": "Terms of Service",
            "support": "Support",
            "github": "GitHub",
            "made_with_love": "Made with ❤️ for the iOS community",
            "usage_statistics": "Usage Statistics",
            "face_swaps": "Face Swaps",
            "images_saved": "Images Saved",
            "camera_sessions": "Camera Sessions",
            "last_used": "Last Used",
            "memory_usage": "Memory Usage",
            "current_usage": "Current Usage",
            "available_memory": "Available Memory",
            "usage_percentage": "Usage Percentage",
            "performance": "Performance",
            "ios_version": "iOS Version",
            "clear_cache": "Clear Cache",
            "optimize_memory": "Optimize Memory",
            "reset_statistics": "Reset Statistics",
            "memory_warning": "Memory usage is high",
            "no_photos_yet": "No Photos Yet",
            "add_some_photos": "Add some photos to get started with face swapping",
            "add_photo": "Add Photo",
            "cancel": "Cancel",
            "done": "Done",
            "ok": "OK",
            "error": "Error",
            "success": "Success",
            "warning": "Warning",
            "info": "Info",
            "loading": "Loading...",
            "processing": "Processing...",
            "saving": "Saving...",
            "saved": "Saved",
            "failed": "Failed",
            "retry": "Retry",
            "close": "Close"
        ]
    }
}

// MARK: - Language Enum

enum Language: Int, CaseIterable {
    case english = 0
    case arabic = 1
    case spanish = 2
    case french = 3
    case german = 4
    case chinese = 5
    case japanese = 6
    case korean = 7
    
    var name: String {
        switch self {
        case .english: return "English"
        case .arabic: return "العربية"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .chinese: return "中文"
        case .japanese: return "日本語"
        case .korean: return "한국어"
        }
    }
    
    var code: String {
        switch self {
        case .english: return "en"
        case .arabic: return "ar"
        case .spanish: return "es"
        case .french: return "fr"
        case .german: return "de"
        case .chinese: return "zh"
        case .japanese: return "ja"
        case .korean: return "ko"
        }
    }
    
    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .arabic: return "🇸🇦"
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        case .german: return "🇩🇪"
        case .chinese: return "🇨🇳"
        case .japanese: return "🇯🇵"
        case .korean: return "🇰🇷"
        }
    }
}

// MARK: - Localized String Extension

extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }
}

// MARK: - Localization View

struct LocalizationView: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Language.allCases, id: \.rawValue) { language in
                    HStack {
                        Text(language.flag)
                            .font(.title2)
                        
                        Text(language.name)
                            .font(.body)
                        
                        Spacer()
                        
                        if language == localizationManager.currentLanguage {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        localizationManager.setLanguage(language)
                    }
                }
            }
            .navigationTitle("Language")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    LocalizationView()
}
