import Foundation
import Photos
import UIKit

class BackupManager: ObservableObject {
    static let shared = BackupManager()
    
    @Published var isBackingUp = false
    @Published var backupProgress: Double = 0.0
    @Published var lastBackupDate: Date?
    @Published var backupSize: Int64 = 0
    
    private let fileManager = FileManager.default
    private let securityManager = SecurityManager.shared
    
    private init() {
        loadBackupInfo()
    }
    
    // MARK: - Backup Operations
    
    func createBackup(completion: @escaping (Bool, Error?) -> Void) {
        guard !isBackingUp else {
            completion(false, BackupError.alreadyInProgress)
            return
        }
        
        isBackingUp = true
        backupProgress = 0.0
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                let backupData = try self.createBackupData()
                let success = try self.saveBackupData(backupData)
                
                DispatchQueue.main.async {
                    self.isBackingUp = false
                    self.backupProgress = 1.0
                    self.lastBackupDate = Date()
                    self.backupSize = Int64(backupData.count)
                    self.saveBackupInfo()
                    
                    completion(success, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    self.isBackingUp = false
                    completion(false, error)
                }
            }
        }
    }
    
    func restoreBackup(from url: URL, completion: @escaping (Bool, Error?) -> Void) {
        guard !isBackingUp else {
            completion(false, BackupError.alreadyInProgress)
            return
        }
        
        isBackingUp = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                let backupData = try Data(contentsOf: url)
                let success = try self.restoreFromBackupData(backupData)
                
                DispatchQueue.main.async {
                    self.isBackingUp = false
                    completion(success, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    self.isBackingUp = false
                    completion(false, error)
                }
            }
        }
    }
    
    // MARK: - Backup Data Creation
    
    private func createBackupData() throws -> Data {
        var backupData: [String: Any] = [:]
        
        // App Settings
        backupData["settings"] = getAppSettings()
        
        // User Preferences
        backupData["preferences"] = getUserPreferences()
        
        // Statistics
        backupData["statistics"] = getStatistics()
        
        // Face Data (if any)
        backupData["faceData"] = getFaceData()
        
        // Processing History
        backupData["processingHistory"] = getProcessingHistory()
        
        // Convert to JSON
        let jsonData = try JSONSerialization.data(withJSONObject: backupData, options: .prettyPrinted)
        
        // Encrypt the data
        guard let encryptedData = securityManager.encryptData(jsonData, with: SecurityConstants.encryptionKey) else {
            throw BackupError.encryptionFailed
        }
        
        return encryptedData
    }
    
    private func getAppSettings() -> [String: Any] {
        let settings = AppSettings.load()
        return [
            "autoSave": settings.autoSave,
            "defaultQuality": settings.defaultQuality.rawValue,
            "defaultFormat": settings.defaultFormat.rawValue,
            "preserveMouth": settings.preserveMouth,
            "preserveEyes": settings.preserveEyes,
            "blendIntensity": settings.blendIntensity,
            "showFaceBoxes": settings.showFaceBoxes,
            "enableEnhancement": settings.enableEnhancement
        ]
    }
    
    private func getUserPreferences() -> [String: Any] {
        let preferences = UserPreferences.load()
        return [
            "hasSeenTutorial": preferences.hasSeenTutorial,
            "lastUsedSourceImage": preferences.lastUsedSourceImage ?? "",
            "usageCount": preferences.usageCount,
            "lastUsedDate": preferences.lastUsedDate?.timeIntervalSince1970 ?? 0
        ]
    }
    
    private func getStatistics() -> [String: Any] {
        let stats = UsageStatistics.shared
        return [
            "faceSwapsCount": stats.getFaceSwapsCount(),
            "imagesSavedCount": stats.getImagesSavedCount(),
            "cameraSessionsCount": stats.getCameraSessionsCount(),
            "lastUsedDate": stats.getLastUsedDate()?.timeIntervalSince1970 ?? 0
        ]
    }
    
    private func getFaceData() -> [String: Any] {
        // This would contain any saved face data
        return [:]
    }
    
    private func getProcessingHistory() -> [String: Any] {
        // This would contain processing history
        return [:]
    }
    
    // MARK: - Backup Data Saving
    
    private func saveBackupData(_ data: Data) throws -> Bool {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let backupURL = documentsPath.appendingPathComponent("backup_\(Date().timeIntervalSince1970).dpc")
        
        try data.write(to: backupURL)
        
        // Save to iCloud if available
        if fileManager.ubiquityIdentityToken != nil {
            try saveToiCloud(backupURL)
        }
        
        return true
    }
    
    private func saveToiCloud(_ url: URL) throws {
        let iCloudURL = fileManager.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
        
        guard let iCloudPath = iCloudURL else { return }
        
        try fileManager.createDirectory(at: iCloudPath, withIntermediateDirectories: true)
        
        let destinationURL = iCloudPath.appendingPathComponent(url.lastPathComponent)
        try fileManager.copyItem(at: url, to: destinationURL)
    }
    
    // MARK: - Backup Restoration
    
    private func restoreFromBackupData(_ data: Data) throws -> Bool {
        // Decrypt the data
        guard let decryptedData = securityManager.decryptData(data, with: SecurityConstants.encryptionKey) else {
            throw BackupError.decryptionFailed
        }
        
        // Parse JSON
        guard let backupData = try JSONSerialization.jsonObject(with: decryptedData) as? [String: Any] else {
            throw BackupError.invalidFormat
        }
        
        // Restore settings
        if let settings = backupData["settings"] as? [String: Any] {
            restoreAppSettings(settings)
        }
        
        // Restore preferences
        if let preferences = backupData["preferences"] as? [String: Any] {
            restoreUserPreferences(preferences)
        }
        
        // Restore statistics
        if let statistics = backupData["statistics"] as? [String: Any] {
            restoreStatistics(statistics)
        }
        
        return true
    }
    
    private func restoreAppSettings(_ settings: [String: Any]) {
        var appSettings = AppSettings()
        
        if let autoSave = settings["autoSave"] as? Bool {
            appSettings.autoSave = autoSave
        }
        
        if let qualityRaw = settings["defaultQuality"] as? String,
           let quality = VideoProcessingSettings.VideoQuality(rawValue: qualityRaw) {
            appSettings.defaultQuality = quality
        }
        
        if let formatRaw = settings["defaultFormat"] as? String,
           let format = VideoProcessingSettings.OutputFormat(rawValue: formatRaw) {
            appSettings.defaultFormat = format
        }
        
        if let preserveMouth = settings["preserveMouth"] as? Bool {
            appSettings.preserveMouth = preserveMouth
        }
        
        if let preserveEyes = settings["preserveEyes"] as? Bool {
            appSettings.preserveEyes = preserveEyes
        }
        
        if let blendIntensity = settings["blendIntensity"] as? Float {
            appSettings.blendIntensity = blendIntensity
        }
        
        if let showFaceBoxes = settings["showFaceBoxes"] as? Bool {
            appSettings.showFaceBoxes = showFaceBoxes
        }
        
        if let enableEnhancement = settings["enableEnhancement"] as? Bool {
            appSettings.enableEnhancement = enableEnhancement
        }
        
        appSettings.save()
    }
    
    private func restoreUserPreferences(_ preferences: [String: Any]) {
        var userPreferences = UserPreferences()
        
        if let hasSeenTutorial = preferences["hasSeenTutorial"] as? Bool {
            userPreferences.hasSeenTutorial = hasSeenTutorial
        }
        
        if let lastUsedSourceImage = preferences["lastUsedSourceImage"] as? String {
            userPreferences.lastUsedSourceImage = lastUsedSourceImage
        }
        
        if let usageCount = preferences["usageCount"] as? Int {
            userPreferences.usageCount = usageCount
        }
        
        if let lastUsedTimestamp = preferences["lastUsedDate"] as? TimeInterval {
            userPreferences.lastUsedDate = Date(timeIntervalSince1970: lastUsedTimestamp)
        }
        
        userPreferences.save()
    }
    
    private func restoreStatistics(_ statistics: [String: Any]) {
        if let faceSwapsCount = statistics["faceSwapsCount"] as? Int {
            UsageStatistics.shared.setValue("face_swaps_count", value: faceSwapsCount)
        }
        
        if let imagesSavedCount = statistics["imagesSavedCount"] as? Int {
            UsageStatistics.shared.setValue("images_saved_count", value: imagesSavedCount)
        }
        
        if let cameraSessionsCount = statistics["cameraSessionsCount"] as? Int {
            UsageStatistics.shared.setValue("camera_sessions_count", value: cameraSessionsCount)
        }
        
        if let lastUsedTimestamp = statistics["lastUsedDate"] as? TimeInterval {
            UsageStatistics.shared.setValue("last_used_date", value: lastUsedTimestamp)
        }
    }
    
    // MARK: - Backup Info Management
    
    private func loadBackupInfo() {
        lastBackupDate = UserDefaults.standard.object(forKey: "LastBackupDate") as? Date
        backupSize = UserDefaults.standard.object(forKey: "BackupSize") as? Int64 ?? 0
    }
    
    private func saveBackupInfo() {
        UserDefaults.standard.set(lastBackupDate, forKey: "LastBackupDate")
        UserDefaults.standard.set(backupSize, forKey: "BackupSize")
    }
    
    // MARK: - Backup Validation
    
    func validateBackup(at url: URL) -> Bool {
        do {
            let data = try Data(contentsOf: url)
            
            // Check if it's encrypted
            guard securityManager.decryptData(data, with: SecurityConstants.encryptionKey) != nil else {
                return false
            }
            
            return true
        } catch {
            return false
        }
    }
    
    // MARK: - Backup Cleanup
    
    func cleanupOldBackups() {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            let backupFiles = try fileManager.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: [.creationDateKey])
            
            let oldBackups = backupFiles.filter { url in
                url.pathExtension == "dpc" && 
                (try? url.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast < Date().addingTimeInterval(-7 * 24 * 60 * 60) // 7 days ago
            }
            
            for backup in oldBackups {
                try fileManager.removeItem(at: backup)
            }
        } catch {
            Logger.shared.error("Failed to cleanup old backups: \(error)")
        }
    }
}

// MARK: - Backup Errors

enum BackupError: Error, LocalizedError {
    case alreadyInProgress
    case encryptionFailed
    case decryptionFailed
    case invalidFormat
    case saveFailed
    case restoreFailed
    
    var errorDescription: String? {
        switch self {
        case .alreadyInProgress:
            return "Backup operation is already in progress"
        case .encryptionFailed:
            return "Failed to encrypt backup data"
        case .decryptionFailed:
            return "Failed to decrypt backup data"
        case .invalidFormat:
            return "Invalid backup format"
        case .saveFailed:
            return "Failed to save backup"
        case .restoreFailed:
            return "Failed to restore backup"
        }
    }
}
