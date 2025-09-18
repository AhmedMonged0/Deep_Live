import SwiftUI

struct AccessibilityView: View {
    @StateObject private var accessibilityManager = AccessibilityManager.shared
    @State private var showingAuditResults = false
    @State private var auditResults: [AccessibilityIssue] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "accessibility")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Accessibility")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Make the app accessible to everyone")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // Current Settings
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Current Settings")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            SettingRow(
                                title: "VoiceOver",
                                isEnabled: accessibilityManager.isVoiceOverEnabled,
                                icon: "eye"
                            )
                            
                            SettingRow(
                                title: "Reduce Motion",
                                isEnabled: accessibilityManager.isReduceMotionEnabled,
                                icon: "slowmo"
                            )
                            
                            SettingRow(
                                title: "Reduce Transparency",
                                isEnabled: accessibilityManager.isReduceTransparencyEnabled,
                                icon: "square.stack.3d.up"
                            )
                            
                            SettingRow(
                                title: "Bold Text",
                                isEnabled: accessibilityManager.isBoldTextEnabled,
                                icon: "bold"
                            )
                            
                            SettingRow(
                                title: "Increase Contrast",
                                isEnabled: accessibilityManager.isIncreaseContrastEnabled,
                                icon: "circle.lefthalf.filled"
                            )
                            
                            SettingRow(
                                title: "Dark Mode",
                                isEnabled: accessibilityManager.isDarkModeEnabled,
                                icon: "moon"
                            )
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Accessibility Features
                    VStack(alignment: .leading, spacing: 15) {
                        Text("App Features")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            FeatureRow(
                                title: "VoiceOver Support",
                                description: "Full VoiceOver support for all interface elements",
                                isSupported: true
                            )
                            
                            FeatureRow(
                                title: "Dynamic Type",
                                description: "Supports system font size preferences",
                                isSupported: true
                            )
                            
                            FeatureRow(
                                title: "High Contrast",
                                description: "Enhanced contrast for better visibility",
                                isSupported: true
                            )
                            
                            FeatureRow(
                                title: "Reduced Motion",
                                description: "Respects motion reduction preferences",
                                isSupported: true
                            )
                            
                            FeatureRow(
                                title: "Touch Targets",
                                description: "Minimum 44pt touch targets for all interactive elements",
                                isSupported: true
                            )
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Actions
                    VStack(spacing: 15) {
                        Button("Run Accessibility Audit") {
                            runAccessibilityAudit()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        
                        Button("Open Accessibility Settings") {
                            openAccessibilitySettings()
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
                    
                    // Information
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Accessibility Information")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoText("• This app is designed to be accessible to users with disabilities")
                            InfoText("• All features support VoiceOver and other assistive technologies")
                            InfoText("• The app respects system accessibility preferences")
                            InfoText("• Touch targets meet minimum size requirements")
                            InfoText("• Color contrast meets WCAG guidelines")
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Accessibility")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAuditResults) {
                AccessibilityAuditView(issues: auditResults)
            }
        }
    }
    
    private func runAccessibilityAudit() {
        auditResults = accessibilityManager.runAccessibilityAudit()
        showingAuditResults = true
    }
    
    private func openAccessibilitySettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
}

struct SettingRow: View {
    let title: String
    let isEnabled: Bool
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
            
            Text(isEnabled ? "Enabled" : "Disabled")
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(isEnabled ? .green : .secondary)
        }
    }
}

struct FeatureRow: View {
    let title: String
    let description: String
    let isSupported: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isSupported ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isSupported ? .green : .red)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct AccessibilityAuditView: View {
    let issues: [AccessibilityIssue]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                if issues.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("No Issues Found")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Great! Your app meets accessibility standards.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    ForEach(Array(issues.enumerated()), id: \.offset) { index, issue in
                        IssueRow(issue: issue)
                    }
                }
            }
            .navigationTitle("Accessibility Audit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct IssueRow: View {
    let issue: AccessibilityIssue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
                    .font(.title3)
                
                Text(issue.type.rawValue.capitalized)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Text(issue.description)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private var iconName: String {
        switch issue.type {
        case .missingLabel:
            return "exclamationmark.triangle.fill"
        case .lowContrast:
            return "eye.trianglebadge.exclamationmark.fill"
        case .smallTouchTarget:
            return "hand.tap.fill"
        case .missingHint:
            return "questionmark.circle.fill"
        case .missingTraits:
            return "info.circle.fill"
        }
    }
    
    private var iconColor: Color {
        switch issue.type {
        case .missingLabel:
            return .orange
        case .lowContrast:
            return .red
        case .smallTouchTarget:
            return .yellow
        case .missingHint:
            return .blue
        case .missingTraits:
            return .purple
        }
    }
}

#Preview {
    AccessibilityView()
}
