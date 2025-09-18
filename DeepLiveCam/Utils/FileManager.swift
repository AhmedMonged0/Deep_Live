import Foundation
import UIKit
import Photos

class FileManagerHelper {
    static let shared = FileManagerHelper()
    
    private let fileManager = FileManager.default
    private let tempDirectory: URL
    
    private init() {
        tempDirectory = fileManager.temporaryDirectory.appendingPathComponent(Constants.File.tempDirectory)
        createTempDirectoryIfNeeded()
    }
    
    // MARK: - Directory Management
    
    private func createTempDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: tempDirectory.path) {
            try? fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        }
    }
    
    func clearTempDirectory() {
        try? fileManager.removeItem(at: tempDirectory)
        createTempDirectoryIfNeeded()
    }
    
    // MARK: - File Operations
    
    func saveImageToPhotos(_ image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                DispatchQueue.main.async {
                    completion(false, FileError.photoLibraryAccessDenied)
                }
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { success, error in
                DispatchQueue.main.async {
                    completion(success, error)
                }
            }
        }
    }
    
    func saveVideoToPhotos(_ videoURL: URL, completion: @escaping (Bool, Error?) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                DispatchQueue.main.async {
                    completion(false, FileError.photoLibraryAccessDenied)
                }
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
            }) { success, error in
                DispatchQueue.main.async {
                    completion(success, error)
                }
            }
        }
    }
    
    func createTempFileURL(withExtension ext: String) -> URL {
        let fileName = UUID().uuidString
        return tempDirectory.appendingPathComponent("\(fileName).\(ext)")
    }
    
    func deleteTempFile(at url: URL) {
        try? fileManager.removeItem(at: url)
    }
    
    // MARK: - File Validation
    
    func validateImageFile(_ url: URL) -> Bool {
        let fileExtension = url.pathExtension.lowercased()
        return Constants.File.supportedImageFormats.contains(fileExtension)
    }
    
    func validateVideoFile(_ url: URL) -> Bool {
        let fileExtension = url.pathExtension.lowercased()
        return Constants.File.supportedVideoFormats.contains(fileExtension)
    }
    
    func getFileSize(_ url: URL) -> Int64? {
        do {
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64
        } catch {
            return nil
        }
    }
    
    func isFileTooLarge(_ url: URL) -> Bool {
        guard let fileSize = getFileSize(url) else { return true }
        return fileSize > Constants.File.maxFileSize
    }
    
    // MARK: - Image Processing
    
    func processImageForSaving(_ image: UIImage, quality: CGFloat = Constants.Processing.compressionQuality) -> Data? {
        return image.jpegData(compressionQuality: quality)
    }
    
    func resizeImageIfNeeded(_ image: UIImage, maxSize: CGSize = Constants.Processing.maxImageSize) -> UIImage {
        let currentSize = image.size
        
        if currentSize.width <= maxSize.width && currentSize.height <= maxSize.height {
            return image
        }
        
        let aspectRatio = currentSize.width / currentSize.height
        let maxAspectRatio = maxSize.width / maxSize.height
        
        let newSize: CGSize
        if aspectRatio > maxAspectRatio {
            newSize = CGSize(width: maxSize.width, height: maxSize.width / aspectRatio)
        } else {
            newSize = CGSize(width: maxSize.height * aspectRatio, height: maxSize.height)
        }
        
        return image.resized(to: newSize)
    }
    
    // MARK: - Cache Management
    
    func clearImageCache() {
        URLCache.shared.removeAllCachedResponses()
    }
    
    func getCacheSize() -> Int64 {
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return getDirectorySize(cacheDirectory)
    }
    
    private func getDirectorySize(_ url: URL) -> Int64 {
        var totalSize: Int64 = 0
        
        if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in enumerator {
                if let fileSize = getFileSize(fileURL) {
                    totalSize += fileSize
                }
            }
        }
        
        return totalSize
    }
}

// MARK: - Error Types

enum FileError: Error, LocalizedError {
    case photoLibraryAccessDenied
    case fileTooLarge
    case unsupportedFormat
    case saveFailed
    case loadFailed
    
    var errorDescription: String? {
        switch self {
        case .photoLibraryAccessDenied:
            return Constants.ErrorMessages.noPhotoLibraryAccess
        case .fileTooLarge:
            return Constants.ErrorMessages.fileTooLarge
        case .unsupportedFormat:
            return Constants.ErrorMessages.unsupportedFormat
        case .saveFailed:
            return "Failed to save file"
        case .loadFailed:
            return "Failed to load file"
        }
    }
}

// MARK: - File Info

struct FileInfo {
    let url: URL
    let size: Int64
    let creationDate: Date?
    let modificationDate: Date?
    let isDirectory: Bool
    
    init(url: URL) {
        self.url = url
        self.size = FileManagerHelper.shared.getFileSize(url) ?? 0
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            self.creationDate = attributes[.creationDate] as? Date
            self.modificationDate = attributes[.modificationDate] as? Date
            self.isDirectory = (attributes[.type] as? FileAttributeType) == .typeDirectory
        } catch {
            self.creationDate = nil
            self.modificationDate = nil
            self.isDirectory = false
        }
    }
}
