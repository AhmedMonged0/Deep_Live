import SwiftUI

struct SettingsView: View {
    @State private var settings = AppSettings.load()
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Video Settings") {
                    Picker("Quality", selection: $settings.defaultQuality) {
                        ForEach(VideoProcessingSettings.VideoQuality.allCases, id: \.self) { quality in
                            Text(quality.rawValue).tag(quality)
                        }
                    }
                    
                    Picker("Format", selection: $settings.defaultFormat) {
                        ForEach(VideoProcessingSettings.OutputFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                }
                
                Section("Face Swap Settings") {
                    Toggle("Preserve Mouth", isOn: $settings.preserveMouth)
                    Toggle("Preserve Eyes", isOn: $settings.preserveEyes)
                    Toggle("Enable Enhancement", isOn: $settings.enableEnhancement)
                    
                    VStack(alignment: .leading) {
                        Text("Blend Intensity: \(Int(settings.blendIntensity * 100))%")
                        Slider(value: $settings.blendIntensity, in: 0...1)
                    }
                }
                
                Section("Display Settings") {
                    Toggle("Auto Save", isOn: $settings.autoSave)
                    Toggle("Show Face Boxes", isOn: $settings.showFaceBoxes)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button("Reset to Defaults") {
                        showingResetAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                settings.save()
            }
        }
        .alert("Reset Settings", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                settings = AppSettings()
                settings.save()
            }
        } message: {
            Text("Are you sure you want to reset all settings to their default values?")
        }
    }
}

#Preview {
    SettingsView()
}
