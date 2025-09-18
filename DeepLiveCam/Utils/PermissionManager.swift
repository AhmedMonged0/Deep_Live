import Foundation
import AVFoundation
import Photos
import UIKit

class PermissionManager: ObservableObject {
    static let shared = PermissionManager()
    
    @Published var cameraPermission: PermissionStatus = .notDetermined
    @Published var photoLibraryPermission: PermissionStatus = .notDetermined
    
    enum PermissionStatus {
        case notDetermined
        case granted
        case denied
        case restricted
    }
    
    private init() {
        checkPermissions()
    }
    
    // MARK: - Permission Checking
    
    func checkPermissions() {
        checkCameraPermission()
        checkPhotoLibraryPermission()
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermission = .granted
        case .denied:
            cameraPermission = .denied
        case .restricted:
            cameraPermission = .restricted
        case .notDetermined:
            cameraPermission = .notDetermined
        @unknown default:
            cameraPermission = .notDetermined
        }
    }
    
    private func checkPhotoLibraryPermission() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .limited:
            photoLibraryPermission = .granted
        case .denied:
            photoLibraryPermission = .denied
        case .restricted:
            photoLibraryPermission = .restricted
        case .notDetermined:
            photoLibraryPermission = .notDetermined
        @unknown default:
            photoLibraryPermission = .notDetermined
        }
    }
    
    // MARK: - Permission Requesting
    
    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.checkCameraPermission()
                completion(granted)
            }
        }
    }
    
    func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.checkPhotoLibraryPermission()
                completion(status == .authorized || status == .limited)
            }
        }
    }
    
    // MARK: - Permission Status Helpers
    
    var hasCameraPermission: Bool {
        return cameraPermission == .granted
    }
    
    var hasPhotoLibraryPermission: Bool {
        return photoLibraryPermission == .granted
    }
    
    var canUseApp: Bool {
        return hasCameraPermission && hasPhotoLibraryPermission
    }
    
    // MARK: - Settings Navigation
    
    func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    // MARK: - Permission Messages
    
    func getCameraPermissionMessage() -> String {
        switch cameraPermission {
        case .notDetermined:
            return "Camera access is required for face swapping. Please allow camera access to continue."
        case .denied:
            return "Camera access was denied. Please enable camera access in Settings to use this feature."
        case .restricted:
            return "Camera access is restricted on this device. Please contact your administrator."
        case .granted:
            return "Camera access is granted."
        }
    }
    
    func getPhotoLibraryPermissionMessage() -> String {
        switch photoLibraryPermission {
        case .notDetermined:
            return "Photo library access is required to select source images. Please allow photo library access to continue."
        case .denied:
            return "Photo library access was denied. Please enable photo library access in Settings to use this feature."
        case .restricted:
            return "Photo library access is restricted on this device. Please contact your administrator."
        case .granted:
            return "Photo library access is granted."
        }
    }
    
    // MARK: - Permission Alert
    
    func showPermissionAlert(for permission: PermissionType, completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Permission Required",
            message: getPermissionMessage(for: permission),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            self.openAppSettings()
        })
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
        }
    }
    
    private func getPermissionMessage(for permission: PermissionType) -> String {
        switch permission {
        case .camera:
            return getCameraPermissionMessage()
        case .photoLibrary:
            return getPhotoLibraryPermissionMessage()
        }
    }
    
    enum PermissionType {
        case camera
        case photoLibrary
    }
}

// MARK: - Permission Status Extensions

extension PermissionManager.PermissionStatus {
    var isGranted: Bool {
        return self == .granted
    }
    
    var canRequest: Bool {
        return self == .notDetermined
    }
    
    var needsSettings: Bool {
        return self == .denied || self == .restricted
    }
}
