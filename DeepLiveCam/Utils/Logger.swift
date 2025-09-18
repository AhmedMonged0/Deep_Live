import Foundation
import os.log

class Logger {
    static let shared = Logger()
    
    private let osLog = OSLog(subsystem: Constants.App.bundleIdentifier, category: "DeepLiveCam")
    
    private init() {}
    
    // MARK: - Logging Methods
    
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .debug, message: message, file: file, function: function, line: line)
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .info, message: message, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .warning, message: message, file: file, function: function, line: line)
    }
    
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .error, message: message, file: file, function: function, line: line)
    }
    
    func error(_ error: Error, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .error, message: error.localizedDescription, file: file, function: function, line: line)
    }
    
    // MARK: - Private Methods
    
    private func log(level: LogLevel, message: String, file: String, function: String, line: Int) {
        #if DEBUG
        guard DebugConstants.enableLogging else { return }
        guard level.rawValue <= DebugConstants.logLevel.rawValue else { return }
        #endif
        
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let logMessage = "[\(fileName):\(line)] \(function) - \(message)"
        
        switch level {
        case .debug:
            os_log("%{public}@", log: osLog, type: .debug, logMessage)
        case .info:
            os_log("%{public}@", log: osLog, type: .info, logMessage)
        case .warning:
            os_log("%{public}@", log: osLog, type: .default, logMessage)
        case .error:
            os_log("%{public}@", log: osLog, type: .error, logMessage)
        }
    }
}

// MARK: - Log Levels

enum LogLevel: Int {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
}

// MARK: - Performance Logger

class PerformanceLogger {
    static let shared = PerformanceLogger()
    
    private var startTimes: [String: Date] = [:]
    
    private init() {}
    
    func startTimer(for operation: String) {
        startTimes[operation] = Date()
    }
    
    func endTimer(for operation: String) -> TimeInterval? {
        guard let startTime = startTimes[operation] else { return nil }
        let duration = Date().timeIntervalSince(startTime)
        startTimes.removeValue(forKey: operation)
        
        Logger.shared.info("\(operation) completed in \(String(format: "%.3f", duration)) seconds")
        return duration
    }
    
    func logPerformance<T>(operation: String, block: () throws -> T) rethrows -> T {
        startTimer(for: operation)
        let result = try block()
        _ = endTimer(for: operation)
        return result
    }
}

// MARK: - Memory Logger

class MemoryLogger {
    static let shared = MemoryLogger()
    
    private init() {}
    
    func logMemoryUsage(context: String) {
        let memoryInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &memoryInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let memoryUsage = memoryInfo.resident_size
            Logger.shared.info("Memory usage in \(context): \(formatBytes(memoryUsage))")
        }
    }
    
    private func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

// MARK: - Convenience Extensions

extension Logger {
    func logFaceDetection(count: Int, confidence: Float) {
        info("Face detection: \(count) faces found with confidence \(confidence)")
    }
    
    func logProcessingStart(operation: String) {
        info("Starting \(operation)")
    }
    
    func logProcessingEnd(operation: String, duration: TimeInterval) {
        info("Completed \(operation) in \(String(format: "%.3f", duration)) seconds")
    }
    
    func logError(_ error: Error, context: String) {
        error("Error in \(context): \(error.localizedDescription)")
    }
    
    func logUserAction(_ action: String) {
        info("User action: \(action)")
    }
}
