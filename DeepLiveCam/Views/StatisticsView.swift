import SwiftUI

struct StatisticsView: View {
    @StateObject private var usageStats = UsageStatistics.shared
    @StateObject private var memoryManager = MemoryManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Usage Statistics
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Usage Statistics")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            StatisticRow(
                                title: "Face Swaps",
                                value: "\(usageStats.getFaceSwapsCount())",
                                icon: "face.smiling"
                            )
                            
                            StatisticRow(
                                title: "Images Saved",
                                value: "\(usageStats.getImagesSavedCount())",
                                icon: "square.and.arrow.down"
                            )
                            
                            StatisticRow(
                                title: "Camera Sessions",
                                value: "\(usageStats.getCameraSessionsCount())",
                                icon: "camera.fill"
                            )
                            
                            if let lastUsed = usageStats.getLastUsedDate() {
                                StatisticRow(
                                    title: "Last Used",
                                    value: formatDate(lastUsed),
                                    icon: "clock"
                                )
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Memory Usage
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Memory Usage")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        let memoryInfo = memoryManager.getMemoryInfo()
                        
                        VStack(spacing: 12) {
                            StatisticRow(
                                title: "Current Usage",
                                value: memoryInfo.formattedCurrentUsage,
                                icon: "memorychip"
                            )
                            
                            StatisticRow(
                                title: "Available Memory",
                                value: memoryInfo.formattedAvailableMemory,
                                icon: "memorychip.fill"
                            )
                            
                            StatisticRow(
                                title: "Usage Percentage",
                                value: "\(Int(memoryInfo.usagePercentage))%",
                                icon: "percent"
                            )
                            
                            if memoryManager.isMemoryWarning {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                    Text("Memory usage is high")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Performance Metrics
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Performance")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            StatisticRow(
                                title: "App Version",
                                value: Constants.getAppVersion(),
                                icon: "info.circle"
                            )
                            
                            StatisticRow(
                                title: "Build Number",
                                value: Constants.App.buildNumber,
                                icon: "hammer"
                            )
                            
                            StatisticRow(
                                title: "iOS Version",
                                value: UIDevice.current.systemVersion,
                                icon: "iphone"
                            )
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Actions
                    VStack(spacing: 15) {
                        Button("Clear Cache") {
                            memoryManager.clearImageCache()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(10)
                        
                        Button("Optimize Memory") {
                            memoryManager.optimizeMemoryUsage()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        
                        Button("Reset Statistics") {
                            resetStatistics()
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
                }
                .padding()
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func resetStatistics() {
        // Reset usage statistics
        UserDefaults.standard.removeObject(forKey: "UsageStatistics")
        
        // Clear memory
        memoryManager.optimizeMemoryUsage()
        
        // Refresh the view
        usageStats.setValue("face_swaps_count", value: 0)
        usageStats.setValue("images_saved_count", value: 0)
        usageStats.setValue("camera_sessions_count", value: 0)
    }
}

struct StatisticRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title3)
                .frame(width: 24)
            
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

#Preview {
    StatisticsView()
}
