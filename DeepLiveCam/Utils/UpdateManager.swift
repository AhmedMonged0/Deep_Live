import Foundation
import SwiftUI

class UpdateManager: ObservableObject {
    static let shared = UpdateManager()
    
    @Published var updateAvailable = false
    @Published var updateInfo: UpdateInfo?
    @Published var isCheckingForUpdates = false
    @Published var isDownloadingUpdate = false
    @Published var downloadProgress: Double = 0.0
    
    private let networkManager = NetworkManager.shared
    private let fileManager = FileManager.default
    
    private init() {
        checkForUpdatesOnLaunch()
    }
    
    // MARK: - Update Checking
    
    func checkForUpdates() {
        guard !isCheckingForUpdates else { return }
        
        isCheckingForUpdates = true
        
        // Simulate API call - replace with actual endpoint
        let url = URL(string: "https://api.deeplivecam.app/updates/latest")!
        
        networkManager.makeRequest(
            url: url,
            method: .GET,
            responseType: APIResponse<UpdateInfo>.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isCheckingForUpdates = false
                
                switch result {
                case .success(let response):
                    if response.success, let updateInfo = response.data {
                        self?.handleUpdateInfo(updateInfo)
                    }
                case .failure(let error):
                    Logger.shared.error("Update check failed: \(error)")
                }
            }
        }
    }
    
    private func checkForUpdatesOnLaunch() {
        // Check for updates on app launch (with delay to avoid blocking UI)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.checkForUpdates()
        }
    }
    
    private func handleUpdateInfo(_ updateInfo: UpdateInfo) {
        self.updateInfo = updateInfo
        
        // Check if update is available
        let currentVersion = getCurrentVersion()
        let newVersion = updateInfo.version
        
        if isNewerVersion(newVersion, than: currentVersion) {
            updateAvailable = true
            Logger.shared.info("Update available: \(newVersion)")
        }
    }
    
    // MARK: - Version Comparison
    
    private func getCurrentVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    private func isNewerVersion(_ newVersion: String, than currentVersion: String) -> Bool {
        let newComponents = newVersion.split(separator: ".").compactMap { Int($0) }
        let currentComponents = currentVersion.split(separator: ".").compactMap { Int($0) }
        
        let maxLength = max(newComponents.count, currentComponents.count)
        
        for i in 0..<maxLength {
            let newComponent = i < newComponents.count ? newComponents[i] : 0
            let currentComponent = i < currentComponents.count ? currentComponents[i] : 0
            
            if newComponent > currentComponent {
                return true
            } else if newComponent < currentComponent {
                return false
            }
        }
        
        return false
    }
    
    // MARK: - Update Download
    
    func downloadUpdate() {
        guard let updateInfo = updateInfo, !isDownloadingUpdate else { return }
        
        isDownloadingUpdate = true
        downloadProgress = 0.0
        
        // Simulate download - replace with actual download logic
        simulateDownload()
    }
    
    private func simulateDownload() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            DispatchQueue.main.async {
                self.downloadProgress += 0.02
                
                if self.downloadProgress >= 1.0 {
                    timer.invalidate()
                    self.isDownloadingUpdate = false
                    self.handleDownloadComplete()
                }
            }
        }
    }
    
    private func handleDownloadComplete() {
        // In a real app, you would install the update here
        Logger.shared.info("Update download completed")
        
        // Show installation prompt
        showInstallationPrompt()
    }
    
    private func showInstallationPrompt() {
        // This would show a system alert to install the update
        Logger.shared.info("Showing installation prompt")
    }
    
    // MARK: - Update Installation
    
    func installUpdate() {
        guard let updateInfo = updateInfo else { return }
        
        // In a real app, you would handle the installation process
        Logger.shared.info("Installing update: \(updateInfo.version)")
        
        // For now, just mark as installed
        updateAvailable = false
        updateInfo = nil
    }
    
    // MARK: - Update Dismissal
    
    func dismissUpdate() {
        updateAvailable = false
        updateInfo = nil
    }
    
    // MARK: - Update Settings
    
    func setAutoUpdateEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "AutoUpdateEnabled")
    }
    
    func isAutoUpdateEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: "AutoUpdateEnabled")
    }
    
    func setUpdateCheckFrequency(_ frequency: UpdateCheckFrequency) {
        UserDefaults.standard.set(frequency.rawValue, forKey: "UpdateCheckFrequency")
    }
    
    func getUpdateCheckFrequency() -> UpdateCheckFrequency {
        let rawValue = UserDefaults.standard.integer(forKey: "UpdateCheckFrequency")
        return UpdateCheckFrequency(rawValue: rawValue) ?? .weekly
    }
}

// MARK: - Update Check Frequency

enum UpdateCheckFrequency: Int, CaseIterable {
    case daily = 0
    case weekly = 1
    case monthly = 2
    case never = 3
    
    var name: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .never: return "Never"
        }
    }
    
    var interval: TimeInterval {
        switch self {
        case .daily: return 24 * 60 * 60 // 24 hours
        case .weekly: return 7 * 24 * 60 * 60 // 7 days
        case .monthly: return 30 * 24 * 60 * 60 // 30 days
        case .never: return .infinity
        }
    }
}

// MARK: - Update Info Model

struct UpdateInfo: Codable {
    let version: String
    let build: String
    let releaseNotes: String
    let downloadURL: String
    let isRequired: Bool
    let releaseDate: Date
    let fileSize: Int64
    
    enum CodingKeys: String, CodingKey {
        case version
        case build
        case releaseNotes = "release_notes"
        case downloadURL = "download_url"
        case isRequired = "is_required"
        case releaseDate = "release_date"
        case fileSize = "file_size"
    }
}

// MARK: - Update View

struct UpdateView: View {
    @StateObject private var updateManager = UpdateManager.shared
    @State private var showingReleaseNotes = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 10) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Update Available")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if let updateInfo = updateManager.updateInfo {
                    Text("Version \(updateInfo.version) is now available")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top)
            
            // Update Info
            if let updateInfo = updateManager.updateInfo {
                VStack(alignment: .leading, spacing: 15) {
                    Text("What's New")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(updateInfo.releaseNotes)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(5)
                    
                    Button("View Full Release Notes") {
                        showingReleaseNotes = true
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
            
            // Progress
            if updateManager.isDownloadingUpdate {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Downloading Update")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    ProgressView(value: updateManager.downloadProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                    
                    Text("\(Int(updateManager.downloadProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
            
            // Actions
            VStack(spacing: 15) {
                if !updateManager.isDownloadingUpdate {
                    Button("Download Update") {
                        updateManager.downloadUpdate()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                
                Button("Install Update") {
                    updateManager.installUpdate()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.green)
                .cornerRadius(10)
                .disabled(!updateManager.isDownloadingUpdate)
                
                Button("Remind Me Later") {
                    updateManager.dismissUpdate()
                }
                .foregroundColor(.secondary)
                .padding()
                .background(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.secondary, lineWidth: 1)
                )
                .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showingReleaseNotes) {
            if let updateInfo = updateManager.updateInfo {
                ReleaseNotesView(updateInfo: updateInfo)
            }
        }
    }
}

struct ReleaseNotesView: View {
    let updateInfo: UpdateInfo
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Release Notes")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Version \(updateInfo.version) (\(updateInfo.build))")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Released \(updateInfo.releaseDate.formatted())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Release Notes
                    Text(updateInfo.releaseNotes)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    // File Size
                    HStack {
                        Text("File Size:")
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(ByteCountFormatter.string(fromByteCount: updateInfo.fileSize, countStyle: .file))
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("Release Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    UpdateView()
}
