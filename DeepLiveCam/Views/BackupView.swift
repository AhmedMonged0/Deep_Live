import SwiftUI

struct BackupView: View {
    @StateObject private var backupManager = BackupManager.shared
    @State private var showingRestorePicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "icloud.and.arrow.up")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Backup & Restore")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Keep your data safe and synchronized")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Backup Status
                VStack(alignment: .leading, spacing: 15) {
                    Text("Backup Status")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 12) {
                        StatusRow(
                            title: "Last Backup",
                            value: backupManager.lastBackupDate?.formatted() ?? "Never"
                        )
                        
                        StatusRow(
                            title: "Backup Size",
                            value: formatBytes(backupManager.backupSize)
                        )
                        
                        StatusRow(
                            title: "Status",
                            value: backupManager.isBackingUp ? "Backing up..." : "Ready"
                        )
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                // Progress Bar
                if backupManager.isBackingUp {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Backup Progress")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        ProgressView(value: backupManager.backupProgress)
                            .progressViewStyle(LinearProgressViewStyle())
                        
                        Text("\(Int(backupManager.backupProgress * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                
                // Action Buttons
                VStack(spacing: 15) {
                    Button(action: createBackup) {
                        HStack {
                            Image(systemName: "icloud.and.arrow.up")
                            Text("Create Backup")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .disabled(backupManager.isBackingUp)
                    
                    Button(action: {
                        showingRestorePicker = true
                    }) {
                        HStack {
                            Image(systemName: "icloud.and.arrow.down")
                            Text("Restore Backup")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                    .disabled(backupManager.isBackingUp)
                    
                    Button(action: cleanupBackups) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Cleanup Old Backups")
                        }
                        .foregroundColor(.red)
                        .padding()
                        .background(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red, lineWidth: 1)
                        )
                        .cornerRadius(10)
                    }
                    .disabled(backupManager.isBackingUp)
                }
                
                // Information
                VStack(alignment: .leading, spacing: 10) {
                    Text("Information")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        InfoText("• Backups are encrypted and stored securely")
                        InfoText("• Only app settings and preferences are backed up")
                        InfoText("• Photos and videos are not included in backups")
                        InfoText("• Backups are automatically cleaned up after 7 days")
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Backup")
            .navigationBarTitleDisplayMode(.inline)
            .fileImporter(
                isPresented: $showingRestorePicker,
                allowedContentTypes: [.data],
                allowsMultipleSelection: false
            ) { result in
                handleRestorePicker(result)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func createBackup() {
        backupManager.createBackup { success, error in
            if success {
                alertTitle = "Success"
                alertMessage = "Backup created successfully!"
            } else {
                alertTitle = "Error"
                alertMessage = error?.localizedDescription ?? "Failed to create backup"
            }
            showingAlert = true
        }
    }
    
    private func handleRestorePicker(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                restoreBackup(from: url)
            }
        case .failure(let error):
            alertTitle = "Error"
            alertMessage = "Failed to select backup file: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func restoreBackup(from url: URL) {
        backupManager.restoreBackup(from: url) { success, error in
            if success {
                alertTitle = "Success"
                alertMessage = "Backup restored successfully!"
            } else {
                alertTitle = "Error"
                alertMessage = error?.localizedDescription ?? "Failed to restore backup"
            }
            showingAlert = true
        }
    }
    
    private func cleanupBackups() {
        backupManager.cleanupOldBackups()
        alertTitle = "Success"
        alertMessage = "Old backups cleaned up successfully!"
        showingAlert = true
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

struct StatusRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
    }
}

struct InfoText: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.body)
            .foregroundColor(.secondary)
    }
}

#Preview {
    BackupView()
}
