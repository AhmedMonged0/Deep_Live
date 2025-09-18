import SwiftUI

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // App Icon and Name
                    VStack(spacing: 15) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text(Constants.App.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Version \(Constants.App.version)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // App Description
                    VStack(alignment: .leading, spacing: 15) {
                        Text("About")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Deep Live Cam is an advanced iOS application that uses artificial intelligence to perform real-time face swapping. Built with SwiftUI and Core ML, it provides a seamless and intuitive experience for creating face-swapped content.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Features
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Features")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            FeatureRow(icon: "camera.fill", title: "Real-time Face Swapping", description: "Live camera face swapping with AI")
                            FeatureRow(icon: "photo.on.rectangle", title: "Photo Library Integration", description: "Select source images from your photos")
                            FeatureRow(icon: "gear", title: "Customizable Settings", description: "Adjust quality and processing options")
                            FeatureRow(icon: "square.and.arrow.down", title: "Save & Share", description: "Save your creations to Photos")
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Technical Details
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Technical Details")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            DetailRow(title: "Platform", value: "iOS 17.0+")
                            DetailRow(title: "Framework", value: "SwiftUI")
                            DetailRow(title: "AI Engine", value: "Core ML + Vision")
                            DetailRow(title: "Language", value: "Swift 5.0")
                            DetailRow(title: "Architecture", value: "MVVM")
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Links
                    VStack(spacing: 15) {
                        LinkButton(
                            title: "Privacy Policy",
                            icon: "hand.raised.fill",
                            url: Constants.URLs.privacyPolicy
                        )
                        
                        LinkButton(
                            title: "Terms of Service",
                            icon: "doc.text.fill",
                            url: Constants.URLs.termsOfService
                        )
                        
                        LinkButton(
                            title: "Support",
                            icon: "questionmark.circle.fill",
                            url: Constants.URLs.support
                        )
                        
                        LinkButton(
                            title: "GitHub",
                            icon: "link",
                            url: Constants.URLs.github
                        )
                    }
                    
                    // Copyright
                    VStack(spacing: 5) {
                        Text("© 2024 Deep Live Cam")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Made with ❤️ for the iOS community")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("About")
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

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
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

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

struct LinkButton: View {
    let title: String
    let icon: String
    let url: String
    
    var body: some View {
        Button(action: {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.title3)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AboutView()
}
