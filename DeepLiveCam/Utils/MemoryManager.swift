import Foundation
import UIKit

class MemoryManager: ObservableObject {
    static let shared = MemoryManager()
    
    @Published var currentMemoryUsage: UInt64 = 0
    @Published var isMemoryWarning = false
    
    private var memoryWarningThreshold: UInt64 = Constants.Processing.memoryWarningThreshold
    private var timer: Timer?
    
    private init() {
        startMemoryMonitoring()
    }
    
    deinit {
        stopMemoryMonitoring()
    }
    
    // MARK: - Memory Monitoring
    
    private func startMemoryMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateMemoryUsage()
        }
    }
    
    private func stopMemoryMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateMemoryUsage() {
        let memoryUsage = getCurrentMemoryUsage()
        
        DispatchQueue.main.async {
            self.currentMemoryUsage = memoryUsage
            
            if memoryUsage > self.memoryWarningThreshold {
                self.isMemoryWarning = true
                self.handleMemoryWarning()
            } else {
                self.isMemoryWarning = false
            }
        }
    }
    
    private func getCurrentMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return info.resident_size
        }
        
        return 0
    }
    
    private func handleMemoryWarning() {
        Logger.shared.warning("Memory warning: \(formatBytes(currentMemoryUsage))")
        
        // Clear caches
        clearImageCache()
        clearTempFiles()
        
        // Force garbage collection
        autoreleasepool {
            // Process any pending operations
        }
        
        // Notify other components
        NotificationCenter.default.post(name: .memoryWarning, object: nil)
    }
    
    // MARK: - Memory Management
    
    func clearImageCache() {
        URLCache.shared.removeAllCachedResponses()
        Logger.shared.info("Image cache cleared")
    }
    
    func clearTempFiles() {
        FileManagerHelper.shared.clearTempDirectory()
        Logger.shared.info("Temp files cleared")
    }
    
    func optimizeMemoryUsage() {
        clearImageCache()
        clearTempFiles()
        
        // Force garbage collection
        autoreleasepool {
            // Process any pending operations
        }
        
        Logger.shared.info("Memory optimized")
    }
    
    // MARK: - Memory Info
    
    func getMemoryInfo() -> MemoryInfo {
        let memoryUsage = getCurrentMemoryUsage()
        let totalMemory = getTotalMemory()
        let availableMemory = totalMemory - memoryUsage
        
        return MemoryInfo(
            currentUsage: memoryUsage,
            totalMemory: totalMemory,
            availableMemory: availableMemory,
            usagePercentage: Double(memoryUsage) / Double(totalMemory) * 100
        )
    }
    
    private func getTotalMemory() -> UInt64 {
        var size: UInt64 = 0
        var sizeSize = UInt32(MemoryLayout<UInt64>.size)
        
        let result = sysctlbyname("hw.memsize", &size, &sizeSize, nil, 0)
        
        if result == 0 {
            return size
        }
        
        return 0
    }
    
    func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    // MARK: - Memory Warnings
    
    func setMemoryWarningThreshold(_ threshold: UInt64) {
        memoryWarningThreshold = threshold
    }
    
    func isMemoryUsageHigh() -> Bool {
        return currentMemoryUsage > memoryWarningThreshold
    }
}

// MARK: - Memory Info

struct MemoryInfo {
    let currentUsage: UInt64
    let totalMemory: UInt64
    let availableMemory: UInt64
    let usagePercentage: Double
    
    var formattedCurrentUsage: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(currentUsage))
    }
    
    var formattedTotalMemory: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(totalMemory))
    }
    
    var formattedAvailableMemory: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(availableMemory))
    }
}

// MARK: - Memory Warning Notification

extension Notification.Name {
    static let memoryWarning = Notification.Name("MemoryWarning")
}

// MARK: - Memory Optimized Image Processing

extension UIImage {
    func memoryOptimized() -> UIImage? {
        // Reduce image size if it's too large
        let maxSize = Constants.Processing.maxImageSize
        let currentSize = self.size
        
        if currentSize.width > maxSize.width || currentSize.height > maxSize.height {
            let aspectRatio = currentSize.width / currentSize.height
            let maxAspectRatio = maxSize.width / maxSize.height
            
            let newSize: CGSize
            if aspectRatio > maxAspectRatio {
                newSize = CGSize(width: maxSize.width, height: maxSize.width / aspectRatio)
            } else {
                newSize = CGSize(width: maxSize.height * aspectRatio, height: maxSize.height)
            }
            
            return self.resized(to: newSize)
        }
        
        return self
    }
    
    func compressed(quality: CGFloat = Constants.Processing.compressionQuality) -> UIImage? {
        guard let data = self.jpegData(compressionQuality: quality) else { return nil }
        return UIImage(data: data)
    }
}
