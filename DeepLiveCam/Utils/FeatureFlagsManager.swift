import Foundation

class FeatureFlagsManager: ObservableObject {
    static let shared = FeatureFlagsManager()
    
    @Published var featureFlags: [String: Bool] = [:]
    
    private init() {
        loadFeatureFlags()
    }
    
    // MARK: - Feature Flag Management
    
    func isFeatureEnabled(_ feature: FeatureFlag) -> Bool {
        return featureFlags[feature.rawValue] ?? feature.defaultValue
    }
    
    func setFeatureEnabled(_ feature: FeatureFlag, enabled: Bool) {
        featureFlags[feature.rawValue] = enabled
        saveFeatureFlags()
    }
    
    func toggleFeature(_ feature: FeatureFlag) {
        let currentValue = isFeatureEnabled(feature)
        setFeatureEnabled(feature, enabled: !currentValue)
    }
    
    // MARK: - Feature Flag Loading
    
    private func loadFeatureFlags() {
        // Load from UserDefaults
        if let savedFlags = UserDefaults.standard.dictionary(forKey: "FeatureFlags") as? [String: Bool] {
            featureFlags = savedFlags
        } else {
            // Load default values
            loadDefaultFeatureFlags()
        }
        
        // Load from remote (in a real app, this would be from a server)
        loadRemoteFeatureFlags()
    }
    
    private func loadDefaultFeatureFlags() {
        for feature in FeatureFlag.allCases {
            featureFlags[feature.rawValue] = feature.defaultValue
        }
    }
    
    private func loadRemoteFeatureFlags() {
        // In a real app, you would fetch feature flags from a remote server
        // For now, we'll simulate this with some default values
        
        let remoteFlags: [String: Bool] = [
            FeatureFlag.advancedFaceProcessing.rawValue: true,
            FeatureFlag.realTimeEnhancement.rawValue: false,
            FeatureFlag.cloudProcessing.rawValue: false,
            FeatureFlag.socialSharing.rawValue: true,
            FeatureFlag.batchProcessing.rawValue: false,
            FeatureFlag.customModels.rawValue: false,
            FeatureFlag.advancedFilters.rawValue: true,
            FeatureFlag.collaboration.rawValue: false,
            FeatureFlag.exportOptions.rawValue: true,
            FeatureFlag.analytics.rawValue: true
        ]
        
        // Merge remote flags with local flags
        for (key, value) in remoteFlags {
            if featureFlags[key] == nil {
                featureFlags[key] = value
            }
        }
        
        saveFeatureFlags()
    }
    
    private func saveFeatureFlags() {
        UserDefaults.standard.set(featureFlags, forKey: "FeatureFlags")
    }
    
    // MARK: - Feature Flag Validation
    
    func validateFeatureFlags() -> [FeatureFlagValidationError] {
        var errors: [FeatureFlagValidationError] = []
        
        for feature in FeatureFlag.allCases {
            if !featureFlags.keys.contains(feature.rawValue) {
                errors.append(.missingFlag(feature))
            }
        }
        
        return errors
    }
    
    // MARK: - Feature Flag Reset
    
    func resetToDefaults() {
        loadDefaultFeatureFlags()
        saveFeatureFlags()
    }
    
    func resetToRemote() {
        loadRemoteFeatureFlags()
    }
}

// MARK: - Feature Flag Enum

enum FeatureFlag: String, CaseIterable {
    case advancedFaceProcessing = "advanced_face_processing"
    case realTimeEnhancement = "real_time_enhancement"
    case cloudProcessing = "cloud_processing"
    case socialSharing = "social_sharing"
    case batchProcessing = "batch_processing"
    case customModels = "custom_models"
    case advancedFilters = "advanced_filters"
    case collaboration = "collaboration"
    case exportOptions = "export_options"
    case analytics = "analytics"
    
    var name: String {
        switch self {
        case .advancedFaceProcessing:
            return "Advanced Face Processing"
        case .realTimeEnhancement:
            return "Real-time Enhancement"
        case .cloudProcessing:
            return "Cloud Processing"
        case .socialSharing:
            return "Social Sharing"
        case .batchProcessing:
            return "Batch Processing"
        case .customModels:
            return "Custom Models"
        case .advancedFilters:
            return "Advanced Filters"
        case .collaboration:
            return "Collaboration"
        case .exportOptions:
            return "Export Options"
        case .analytics:
            return "Analytics"
        }
    }
    
    var description: String {
        switch self {
        case .advancedFaceProcessing:
            return "Enable advanced face processing algorithms for better results"
        case .realTimeEnhancement:
            return "Apply real-time enhancement to processed images"
        case .cloudProcessing:
            return "Use cloud-based processing for better performance"
        case .socialSharing:
            return "Enable sharing to social media platforms"
        case .batchProcessing:
            return "Process multiple images at once"
        case .customModels:
            return "Allow users to upload custom AI models"
        case .advancedFilters:
            return "Enable advanced image filters and effects"
        case .collaboration:
            return "Enable real-time collaboration features"
        case .exportOptions:
            return "Provide various export format options"
        case .analytics:
            return "Collect usage analytics and statistics"
        }
    }
    
    var defaultValue: Bool {
        switch self {
        case .advancedFaceProcessing:
            return true
        case .realTimeEnhancement:
            return false
        case .cloudProcessing:
            return false
        case .socialSharing:
            return true
        case .batchProcessing:
            return false
        case .customModels:
            return false
        case .advancedFilters:
            return true
        case .collaboration:
            return false
        case .exportOptions:
            return true
        case .analytics:
            return true
        }
    }
    
    var category: FeatureCategory {
        switch self {
        case .advancedFaceProcessing, .realTimeEnhancement, .cloudProcessing:
            return .processing
        case .socialSharing, .exportOptions:
            return .sharing
        case .batchProcessing, .customModels:
            return .advanced
        case .advancedFilters, .collaboration:
            return .features
        case .analytics:
            return .system
        }
    }
}

// MARK: - Feature Category

enum FeatureCategory: String, CaseIterable {
    case processing = "Processing"
    case sharing = "Sharing"
    case advanced = "Advanced"
    case features = "Features"
    case system = "System"
    
    var icon: String {
        switch self {
        case .processing:
            return "gear"
        case .sharing:
            return "square.and.arrow.up"
        case .advanced:
            return "star"
        case .features:
            return "sparkles"
        case .system:
            return "gear.badge"
        }
    }
}

// MARK: - Feature Flag Validation Error

enum FeatureFlagValidationError: Error {
    case missingFlag(FeatureFlag)
    
    var description: String {
        switch self {
        case .missingFlag(let flag):
            return "Missing feature flag: \(flag.name)"
        }
    }
}

// MARK: - Feature Flag View

struct FeatureFlagsView: View {
    @StateObject private var featureFlagsManager = FeatureFlagsManager.shared
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(FeatureCategory.allCases, id: \.rawValue) { category in
                    Section(header: Text(category.rawValue)) {
                        ForEach(FeatureFlag.allCases.filter { $0.category == category }, id: \.rawValue) { feature in
                            FeatureFlagRow(
                                feature: feature,
                                isEnabled: featureFlagsManager.isFeatureEnabled(feature)
                            ) {
                                featureFlagsManager.toggleFeature(feature)
                            }
                        }
                    }
                }
                
                Section {
                    Button("Reset to Defaults") {
                        showingResetAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Feature Flags")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Reset Feature Flags", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    featureFlagsManager.resetToDefaults()
                }
            } message: {
                Text("Are you sure you want to reset all feature flags to their default values?")
            }
        }
    }
}

struct FeatureFlagRow: View {
    let feature: FeatureFlag
    let isEnabled: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(feature.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(feature.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { isEnabled },
                    set: { _ in onToggle() }
                ))
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    FeatureFlagsView()
}
