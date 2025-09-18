import SwiftUI

struct PermissionView: View {
    @ObservedObject var permissionManager = PermissionManager.shared
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 10) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Permissions Required")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Deep Live Cam needs access to your camera and photo library to function properly.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Permission Status
            VStack(spacing: 20) {
                PermissionStatusRow(
                    icon: "camera.fill",
                    title: "Camera Access",
                    status: permissionManager.cameraPermission,
                    description: "Required for real-time face swapping"
                )
                
                PermissionStatusRow(
                    icon: "photo.on.rectangle",
                    title: "Photo Library Access",
                    status: permissionManager.photoLibraryPermission,
                    description: "Required to select source images"
                )
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            // Action Buttons
            VStack(spacing: 15) {
                if !permissionManager.hasCameraPermission {
                    Button(action: {
                        permissionManager.requestCameraPermission { granted in
                            if !granted {
                                showingSettings = true
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Grant Camera Access")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                }
                
                if !permissionManager.hasPhotoLibraryPermission {
                    Button(action: {
                        permissionManager.requestPhotoLibraryPermission { granted in
                            if !granted {
                                showingSettings = true
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("Grant Photo Library Access")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                }
                
                if permissionManager.cameraPermission == .denied || permissionManager.photoLibraryPermission == .denied {
                    Button(action: {
                        permissionManager.openAppSettings()
                    }) {
                        HStack {
                            Image(systemName: "gear")
                            Text("Open Settings")
                        }
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                        .cornerRadius(10)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .alert("Permission Denied", isPresented: $showingSettings) {
            Button("Cancel", role: .cancel) { }
            Button("Open Settings") {
                permissionManager.openAppSettings()
            }
        } message: {
            Text("Please enable camera and photo library access in Settings to use this app.")
        }
    }
}

struct PermissionStatusRow: View {
    let icon: String
    let title: String
    let status: PermissionManager.PermissionStatus
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(statusColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 5) {
                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
                Text(statusText)
                    .font(.caption)
                    .foregroundColor(statusColor)
            }
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .granted:
            return .green
        case .denied, .restricted:
            return .red
        case .notDetermined:
            return .orange
        }
    }
    
    private var statusIcon: String {
        switch status {
        case .granted:
            return "checkmark.circle.fill"
        case .denied, .restricted:
            return "xmark.circle.fill"
        case .notDetermined:
            return "questionmark.circle.fill"
        }
    }
    
    private var statusText: String {
        switch status {
        case .granted:
            return "Granted"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        case .notDetermined:
            return "Not Set"
        }
    }
}

#Preview {
    PermissionView()
}
