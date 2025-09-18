import Foundation
import os.log

class CrashReporter {
    static let shared = CrashReporter()
    
    private let logger = Logger.shared
    private var crashReports: [CrashReport] = []
    
    private init() {
        setupCrashHandling()
    }
    
    // MARK: - Crash Handling Setup
    
    private func setupCrashHandling() {
        // Set up signal handlers for common crashes
        signal(SIGABRT, crashHandler)
        signal(SIGILL, crashHandler)
        signal(SIGSEGV, crashHandler)
        signal(SIGFPE, crashHandler)
        signal(SIGBUS, crashHandler)
        signal(SIGPIPE, crashHandler)
        
        // Set up uncaught exception handler
        NSSetUncaughtExceptionHandler(exceptionHandler)
    }
    
    // MARK: - Signal Handlers
    
    private let crashHandler: @convention(c) (Int32) -> Void = { signal in
        let crashReport = CrashReport(
            type: .signal,
            signal: signal,
            timestamp: Date(),
            thread: Thread.current,
            callStack: Thread.callStackSymbols
        )
        
        CrashReporter.shared.handleCrash(crashReport)
    }
    
    private let exceptionHandler: @convention(c) (NSException) -> Void = { exception in
        let crashReport = CrashReport(
            type: .exception,
            exception: exception,
            timestamp: Date(),
            thread: Thread.current,
            callStack: Thread.callStackSymbols
        )
        
        CrashReporter.shared.handleCrash(crashReport)
    }
    
    // MARK: - Crash Handling
    
    private func handleCrash(_ report: CrashReport) {
        logger.error("Crash detected: \(report.description)")
        
        // Save crash report
        crashReports.append(report)
        saveCrashReports()
        
        // Send crash report if possible
        sendCrashReport(report)
        
        // Perform cleanup
        performCrashCleanup()
    }
    
    private func saveCrashReports() {
        do {
            let data = try JSONEncoder().encode(crashReports)
            UserDefaults.standard.set(data, forKey: "CrashReports")
        } catch {
            logger.error("Failed to save crash reports: \(error)")
        }
    }
    
    private func sendCrashReport(_ report: CrashReport) {
        // In a real app, you would send this to a crash reporting service
        // like Crashlytics, Sentry, or Bugsnag
        
        logger.info("Crash report would be sent: \(report.id)")
    }
    
    private func performCrashCleanup() {
        // Clean up resources
        MemoryManager.shared.optimizeMemoryUsage()
        
        // Save any pending data
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Public Methods
    
    func logError(_ error: Error, context: String) {
        let crashReport = CrashReport(
            type: .error,
            error: error,
            timestamp: Date(),
            thread: Thread.current,
            callStack: Thread.callStackSymbols
        )
        
        handleCrash(crashReport)
    }
    
    func logFatalError(_ message: String, context: String) {
        let crashReport = CrashReport(
            type: .fatal,
            message: message,
            context: context,
            timestamp: Date(),
            thread: Thread.current,
            callStack: Thread.callStackSymbols
        )
        
        handleCrash(crashReport)
    }
    
    func getCrashReports() -> [CrashReport] {
        return crashReports
    }
    
    func clearCrashReports() {
        crashReports.removeAll()
        UserDefaults.standard.removeObject(forKey: "CrashReports")
    }
    
    func loadCrashReports() {
        guard let data = UserDefaults.standard.data(forKey: "CrashReports"),
              let reports = try? JSONDecoder().decode([CrashReport].self, from: data) else {
            return
        }
        crashReports = reports
    }
}

// MARK: - Crash Report Model

struct CrashReport: Codable {
    let id = UUID()
    let type: CrashType
    let timestamp: Date
    let thread: String
    let callStack: [String]
    let signal: Int32?
    let exception: String?
    let error: String?
    let message: String?
    let context: String?
    
    init(type: CrashType, signal: Int32, timestamp: Date, thread: Thread, callStack: [String]) {
        self.type = type
        self.signal = signal
        self.timestamp = timestamp
        self.thread = thread.description
        self.callStack = callStack
        self.exception = nil
        self.error = nil
        self.message = nil
        self.context = nil
    }
    
    init(type: CrashType, exception: NSException, timestamp: Date, thread: Thread, callStack: [String]) {
        self.type = type
        self.signal = nil
        self.timestamp = timestamp
        self.thread = thread.description
        self.callStack = callStack
        self.exception = exception.description
        self.error = nil
        self.message = nil
        self.context = nil
    }
    
    init(type: CrashType, error: Error, timestamp: Date, thread: Thread, callStack: [String]) {
        self.type = type
        self.signal = nil
        self.timestamp = timestamp
        self.thread = thread.description
        self.callStack = callStack
        self.exception = nil
        self.error = error.localizedDescription
        self.message = nil
        self.context = nil
    }
    
    init(type: CrashType, message: String, context: String, timestamp: Date, thread: Thread, callStack: [String]) {
        self.type = type
        self.signal = nil
        self.timestamp = timestamp
        self.thread = thread.description
        self.callStack = callStack
        self.exception = nil
        self.error = nil
        self.message = message
        self.context = context
    }
    
    var description: String {
        var desc = "Crash Report [\(type.rawValue)] at \(timestamp)"
        
        if let signal = signal {
            desc += "\nSignal: \(signal)"
        }
        
        if let exception = exception {
            desc += "\nException: \(exception)"
        }
        
        if let error = error {
            desc += "\nError: \(error)"
        }
        
        if let message = message {
            desc += "\nMessage: \(message)"
        }
        
        if let context = context {
            desc += "\nContext: \(context)"
        }
        
        desc += "\nThread: \(thread)"
        desc += "\nCall Stack:\n\(callStack.joined(separator: "\n"))"
        
        return desc
    }
}

// MARK: - Crash Types

enum CrashType: String, Codable {
    case signal = "signal"
    case exception = "exception"
    case error = "error"
    case fatal = "fatal"
}

// MARK: - Thread Extension

extension Thread {
    var description: String {
        return "Thread-\(threadId)"
    }
    
    private var threadId: String {
        return "\(pthread_mach_thread_np(pthread_self()))"
    }
}
