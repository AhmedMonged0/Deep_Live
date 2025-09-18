import Foundation
import CoreImage
import UIKit
import Accelerate

class PerformanceOptimizer {
    static let shared = PerformanceOptimizer()
    
    private init() {}
    
    // MARK: - Image Processing Optimization
    
    func optimizeImageForProcessing(_ image: UIImage, targetSize: CGSize) -> UIImage {
        // Resize image to target size for better performance
        let resizedImage = image.resized(to: targetSize)
        
        // Convert to optimal format
        return resizedImage.optimizedForProcessing()
    }
    
    func processImageInBackground<T>(
        _ image: UIImage,
        processing: @escaping (UIImage) -> T,
        completion: @escaping (T) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = processing(image)
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    // MARK: - Memory Management
    
    func clearImageCache() {
        // Clear any cached images to free memory
        URLCache.shared.removeAllCachedResponses()
    }
    
    func optimizeMemoryUsage() {
        // Force garbage collection
        autoreleasepool {
            // Process any pending operations
        }
    }
    
    // MARK: - Performance Monitoring
    
    func measurePerformance<T>(
        operation: () throws -> T,
        operationName: String
    ) rethrows -> (result: T, duration: TimeInterval) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try operation()
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        
        print("\(operationName) took \(duration) seconds")
        
        return (result, duration)
    }
    
    // MARK: - Image Quality Optimization
    
    func adjustImageQuality(_ image: UIImage, for targetSize: CGSize) -> UIImage {
        let currentSize = image.size
        let scale = min(targetSize.width / currentSize.width, targetSize.height / currentSize.height)
        
        if scale < 1.0 {
            // Downscale for better performance
            let newSize = CGSize(
                width: currentSize.width * scale,
                height: currentSize.height * scale
            )
            return image.resized(to: newSize)
        }
        
        return image
    }
}

// MARK: - UIImage Extensions for Optimization

extension UIImage {
    func optimizedForProcessing() -> UIImage {
        // Convert to RGB format for better processing performance
        guard let cgImage = self.cgImage else { return self }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: nil,
            width: cgImage.width,
            height: cgImage.height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        
        guard let optimizedContext = context else { return self }
        optimizedContext.draw(cgImage, in: CGRect(origin: .zero, size: self.size))
        
        guard let optimizedImage = optimizedContext.makeImage() else { return self }
        return UIImage(cgImage: optimizedImage)
    }
    
    func resized(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage ?? self
    }
    
    func compressed(quality: CGFloat = 0.8) -> UIImage? {
        guard let imageData = jpegData(compressionQuality: quality) else { return nil }
        return UIImage(data: imageData)
    }
}

// MARK: - Performance Metrics

struct PerformanceMetrics {
    let operationName: String
    let duration: TimeInterval
    let memoryUsage: UInt64
    let timestamp: Date
    
    init(operationName: String, duration: TimeInterval, memoryUsage: UInt64 = 0) {
        self.operationName = operationName
        self.duration = duration
        self.memoryUsage = memoryUsage
        self.timestamp = Date()
    }
}

class PerformanceMonitor {
    static let shared = PerformanceMonitor()
    
    private var metrics: [PerformanceMetrics] = []
    private let maxMetricsCount = 100
    
    private init() {}
    
    func recordMetric(_ metric: PerformanceMetrics) {
        metrics.append(metric)
        
        // Keep only recent metrics
        if metrics.count > maxMetricsCount {
            metrics.removeFirst(metrics.count - maxMetricsCount)
        }
    }
    
    func getAverageDuration(for operationName: String) -> TimeInterval {
        let operationMetrics = metrics.filter { $0.operationName == operationName }
        guard !operationMetrics.isEmpty else { return 0 }
        
        let totalDuration = operationMetrics.reduce(0) { $0 + $1.duration }
        return totalDuration / Double(operationMetrics.count)
    }
    
    func getRecentMetrics(count: Int = 10) -> [PerformanceMetrics] {
        return Array(metrics.suffix(count))
    }
    
    func clearMetrics() {
        metrics.removeAll()
    }
}
