import Foundation
import UIKit
import SwiftUI

class AccessibilityManager: ObservableObject {
    static let shared = AccessibilityManager()
    
    @Published var isVoiceOverEnabled = false
    @Published var isReduceMotionEnabled = false
    @Published var isReduceTransparencyEnabled = false
    @Published var isBoldTextEnabled = false
    @Published var isIncreaseContrastEnabled = false
    @Published var isDarkModeEnabled = false
    
    private init() {
        setupAccessibilityObservers()
        updateAccessibilitySettings()
    }
    
    // MARK: - Accessibility Setup
    
    private func setupAccessibilityObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accessibilitySettingsChanged),
            name: UIAccessibility.voiceOverStatusDidChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accessibilitySettingsChanged),
            name: UIAccessibility.reduceMotionStatusDidChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accessibilitySettingsChanged),
            name: UIAccessibility.reduceTransparencyStatusDidChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accessibilitySettingsChanged),
            name: UIAccessibility.boldTextStatusDidChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accessibilitySettingsChanged),
            name: UIAccessibility.increaseContrastStatusDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func accessibilitySettingsChanged() {
        updateAccessibilitySettings()
    }
    
    private func updateAccessibilitySettings() {
        DispatchQueue.main.async {
            self.isVoiceOverEnabled = UIAccessibility.isVoiceOverRunning
            self.isReduceMotionEnabled = UIAccessibility.isReduceMotionEnabled
            self.isReduceTransparencyEnabled = UIAccessibility.isReduceTransparencyEnabled
            self.isBoldTextEnabled = UIAccessibility.isBoldTextEnabled
            self.isIncreaseContrastEnabled = UIAccessibility.isIncreaseContrastEnabled
            self.isDarkModeEnabled = UIAccessibility.isDarkModeEnabled
        }
    }
    
    // MARK: - Accessibility Helpers
    
    func announce(_ message: String) {
        if isVoiceOverEnabled {
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }
    
    func announceScreenChange(_ screenName: String) {
        if isVoiceOverEnabled {
            UIAccessibility.post(notification: .screenChanged, argument: screenName)
        }
    }
    
    func setAccessibilityLabel(_ label: String, for view: UIView) {
        view.accessibilityLabel = label
    }
    
    func setAccessibilityHint(_ hint: String, for view: UIView) {
        view.accessibilityHint = hint
    }
    
    func setAccessibilityTraits(_ traits: UIAccessibilityTraits, for view: UIView) {
        view.accessibilityTraits = traits
    }
    
    // MARK: - Dynamic Type Support
    
    func getPreferredFont(for style: UIFont.TextStyle) -> UIFont {
        let font = UIFont.preferredFont(forTextStyle: style)
        
        if isBoldTextEnabled {
            return UIFont.boldSystemFont(ofSize: font.pointSize)
        }
        
        return font
    }
    
    func getScaledFont(for style: UIFont.TextStyle, size: CGFloat) -> UIFont {
        let font = UIFont.preferredFont(forTextStyle: style)
        let scaledSize = font.pointSize * size
        
        if isBoldTextEnabled {
            return UIFont.boldSystemFont(ofSize: scaledSize)
        }
        
        return UIFont.systemFont(ofSize: scaledSize)
    }
    
    // MARK: - Color Accessibility
    
    func getAccessibleColor(_ color: UIColor) -> UIColor {
        if isIncreaseContrastEnabled {
            return color.withAlphaComponent(1.0)
        }
        
        return color
    }
    
    func getHighContrastColor(_ color: UIColor) -> UIColor {
        if isIncreaseContrastEnabled {
            return color.withAlphaComponent(0.9)
        }
        
        return color
    }
    
    // MARK: - Motion Accessibility
    
    func shouldReduceMotion() -> Bool {
        return isReduceMotionEnabled
    }
    
    func getAnimationDuration() -> Double {
        return shouldReduceMotion() ? 0.0 : 0.3
    }
    
    func getAnimationDelay() -> Double {
        return shouldReduceMotion() ? 0.0 : 0.1
    }
    
    // MARK: - Transparency Accessibility
    
    func shouldReduceTransparency() -> Bool {
        return isReduceTransparencyEnabled
    }
    
    func getBackgroundOpacity() -> Double {
        return shouldReduceTransparency() ? 1.0 : 0.8
    }
    
    // MARK: - VoiceOver Support
    
    func isVoiceOverRunning() -> Bool {
        return isVoiceOverEnabled
    }
    
    func setVoiceOverFocus(_ view: UIView) {
        if isVoiceOverEnabled {
            UIAccessibility.post(notification: .layoutChanged, argument: view)
        }
    }
    
    func setVoiceOverFocusToFirstElement() {
        if isVoiceOverEnabled {
            UIAccessibility.post(notification: .screenChanged, argument: nil)
        }
    }
    
    // MARK: - Accessibility Testing
    
    func runAccessibilityAudit() -> [AccessibilityIssue] {
        var issues: [AccessibilityIssue] = []
        
        // Check for missing accessibility labels
        if let window = UIApplication.shared.windows.first {
            checkAccessibilityLabels(in: window, issues: &issues)
        }
        
        // Check for color contrast
        checkColorContrast(issues: &issues)
        
        // Check for touch target sizes
        checkTouchTargetSizes(issues: &issues)
        
        return issues
    }
    
    private func checkAccessibilityLabels(in view: UIView, issues: inout [AccessibilityIssue]) {
        if view.isAccessibilityElement && view.accessibilityLabel == nil {
            issues.append(AccessibilityIssue(
                type: .missingLabel,
                description: "View is accessible but missing label",
                view: view
            ))
        }
        
        for subview in view.subviews {
            checkAccessibilityLabels(in: subview, issues: &issues)
        }
    }
    
    private func checkColorContrast(issues: inout [AccessibilityIssue]) {
        // This would check color contrast ratios
        // Implementation depends on specific color combinations
    }
    
    private func checkTouchTargetSizes(issues: inout [AccessibilityIssue]) {
        // This would check if touch targets are at least 44x44 points
        // Implementation depends on specific views
    }
}

// MARK: - Accessibility Issue

struct AccessibilityIssue {
    let type: IssueType
    let description: String
    let view: UIView?
    
    enum IssueType {
        case missingLabel
        case lowContrast
        case smallTouchTarget
        case missingHint
        case missingTraits
    }
}

// MARK: - Accessibility Extensions

extension View {
    func accessibilityAnnouncement(_ message: String) -> some View {
        self.onAppear {
            AccessibilityManager.shared.announce(message)
        }
    }
    
    func accessibilityScreenChange(_ screenName: String) -> some View {
        self.onAppear {
            AccessibilityManager.shared.announceScreenChange(screenName)
        }
    }
    
    func accessibilityLabel(_ label: String) -> some View {
        self.accessibilityLabel(label)
    }
    
    func accessibilityHint(_ hint: String) -> some View {
        self.accessibilityHint(hint)
    }
    
    func accessibilityTraits(_ traits: AccessibilityTraits) -> some View {
        self.accessibilityTraits(traits)
    }
}

// MARK: - Accessibility Constants

struct AccessibilityConstants {
    static let minimumTouchTargetSize: CGFloat = 44.0
    static let minimumContrastRatio: Double = 4.5
    static let preferredFontSize: CGFloat = 17.0
    static let maximumFontSize: CGFloat = 35.0
    static let minimumFontSize: CGFloat = 12.0
}

// MARK: - Accessibility Manager Delegate

protocol AccessibilityManagerDelegate: AnyObject {
    func accessibilityManagerDidDetectIssue(_ manager: AccessibilityManager, issue: AccessibilityIssue)
    func accessibilityManagerDidUpdateSettings(_ manager: AccessibilityManager)
}

// MARK: - Accessibility Manager Extension

extension AccessibilityManager {
    func logAccessibilityEvent(_ event: String) {
        Logger.shared.info("Accessibility Event: \(event)")
    }
    
    func getAccessibilitySummary() -> String {
        var summary = "Accessibility Settings:\n"
        summary += "VoiceOver: \(isVoiceOverEnabled ? "Enabled" : "Disabled")\n"
        summary += "Reduce Motion: \(isReduceMotionEnabled ? "Enabled" : "Disabled")\n"
        summary += "Reduce Transparency: \(isReduceTransparencyEnabled ? "Enabled" : "Disabled")\n"
        summary += "Bold Text: \(isBoldTextEnabled ? "Enabled" : "Disabled")\n"
        summary += "Increase Contrast: \(isIncreaseContrastEnabled ? "Enabled" : "Disabled")\n"
        summary += "Dark Mode: \(isDarkModeEnabled ? "Enabled" : "Disabled")\n"
        return summary
    }
}
