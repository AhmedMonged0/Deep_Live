import Foundation
import os.log

class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private let logger = Logger.shared
    private var events: [AnalyticsEvent] = []
    
    private init() {}
    
    // MARK: - Event Tracking
    
    func trackEvent(_ event: AnalyticsEvent) {
        events.append(event)
        logger.info("Analytics: \(event.name) - \(event.properties)")
        
        // In a real app, you would send this to your analytics service
        // sendToAnalyticsService(event)
    }
    
    func trackScreenView(_ screenName: String) {
        let event = AnalyticsEvent(
            name: "screen_view",
            properties: ["screen_name": screenName]
        )
        trackEvent(event)
    }
    
    func trackUserAction(_ action: String, properties: [String: Any] = [:]) {
        let event = AnalyticsEvent(
            name: "user_action",
            properties: ["action": action].merging(properties) { _, new in new }
        )
        trackEvent(event)
    }
    
    func trackError(_ error: Error, context: String) {
        let event = AnalyticsEvent(
            name: "error",
            properties: [
                "error_description": error.localizedDescription,
                "context": context
            ]
        )
        trackEvent(event)
    }
    
    func trackPerformance(_ operation: String, duration: TimeInterval) {
        let event = AnalyticsEvent(
            name: "performance",
            properties: [
                "operation": operation,
                "duration": duration
            ]
        )
        trackEvent(event)
    }
    
    // MARK: - App-Specific Events
    
    func trackFaceSwapStarted() {
        trackUserAction("face_swap_started")
    }
    
    func trackFaceSwapCompleted(duration: TimeInterval) {
        trackUserAction("face_swap_completed", properties: ["duration": duration])
    }
    
    func trackImageSelected(source: String) {
        trackUserAction("image_selected", properties: ["source": source])
    }
    
    func trackCameraStarted() {
        trackUserAction("camera_started")
    }
    
    func trackCameraStopped() {
        trackUserAction("camera_stopped")
    }
    
    func trackImageSaved() {
        trackUserAction("image_saved")
    }
    
    func trackSettingsChanged(setting: String, value: Any) {
        trackUserAction("settings_changed", properties: [
            "setting": setting,
            "value": value
        ])
    }
    
    func trackPermissionRequested(permission: String) {
        trackUserAction("permission_requested", properties: ["permission": permission])
    }
    
    func trackPermissionGranted(permission: String) {
        trackUserAction("permission_granted", properties: ["permission": permission])
    }
    
    func trackPermissionDenied(permission: String) {
        trackUserAction("permission_denied", properties: ["permission": permission])
    }
    
    // MARK: - User Properties
    
    func setUserProperty(_ key: String, value: Any) {
        let event = AnalyticsEvent(
            name: "user_property",
            properties: [key: value]
        )
        trackEvent(event)
    }
    
    func setUserId(_ userId: String) {
        setUserProperty("user_id", value: userId)
    }
    
    // MARK: - Session Management
    
    func startSession() {
        let event = AnalyticsEvent(
            name: "session_start",
            properties: ["timestamp": Date().timeIntervalSince1970]
        )
        trackEvent(event)
    }
    
    func endSession() {
        let event = AnalyticsEvent(
            name: "session_end",
            properties: ["timestamp": Date().timeIntervalSince1970]
        )
        trackEvent(event)
    }
    
    // MARK: - Data Export
    
    func exportEvents() -> [AnalyticsEvent] {
        return events
    }
    
    func clearEvents() {
        events.removeAll()
    }
}

// MARK: - Analytics Event

struct AnalyticsEvent {
    let id = UUID()
    let name: String
    let properties: [String: Any]
    let timestamp = Date()
    
    init(name: String, properties: [String: Any] = [:]) {
        self.name = name
        self.properties = properties
    }
}

// MARK: - Usage Statistics

class UsageStatistics {
    static let shared = UsageStatistics()
    
    private var statistics: [String: Any] = [:]
    
    private init() {
        loadStatistics()
    }
    
    func incrementCounter(_ key: String) {
        let currentValue = statistics[key] as? Int ?? 0
        statistics[key] = currentValue + 1
        saveStatistics()
    }
    
    func setValue(_ key: String, value: Any) {
        statistics[key] = value
        saveStatistics()
    }
    
    func getValue(_ key: String) -> Any? {
        return statistics[key]
    }
    
    func getCounter(_ key: String) -> Int {
        return statistics[key] as? Int ?? 0
    }
    
    private func loadStatistics() {
        if let data = UserDefaults.standard.data(forKey: "UsageStatistics"),
           let stats = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            statistics = stats
        }
    }
    
    private func saveStatistics() {
        if let data = try? JSONSerialization.data(withJSONObject: statistics) {
            UserDefaults.standard.set(data, forKey: "UsageStatistics")
        }
    }
    
    // MARK: - App-Specific Statistics
    
    func incrementFaceSwaps() {
        incrementCounter("face_swaps_count")
    }
    
    func incrementImagesSaved() {
        incrementCounter("images_saved_count")
    }
    
    func incrementCameraSessions() {
        incrementCounter("camera_sessions_count")
    }
    
    func setLastUsedDate() {
        setValue("last_used_date", value: Date().timeIntervalSince1970)
    }
    
    func getFaceSwapsCount() -> Int {
        return getCounter("face_swaps_count")
    }
    
    func getImagesSavedCount() -> Int {
        return getCounter("images_saved_count")
    }
    
    func getCameraSessionsCount() -> Int {
        return getCounter("camera_sessions_count")
    }
    
    func getLastUsedDate() -> Date? {
        if let timestamp = getValue("last_used_date") as? TimeInterval {
            return Date(timeIntervalSince1970: timestamp)
        }
        return nil
    }
}
