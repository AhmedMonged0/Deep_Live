import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var faceProcessor = FaceSwapProcessor()
    @StateObject private var modelManager = ModelManager()
    @State private var selectedSourceImage: UIImage?
    @State private var showingImagePicker = false
    @State private var isProcessing = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingSettings = false
    @State private var settings = AppSettings.load()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Deep Live Cam")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Real-time Face Swap")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Source Image Selection
                VStack(alignment: .leading, spacing: 10) {
                    Text("Source Face")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let sourceImage = selectedSourceImage {
                        Image(uiImage: sourceImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 150)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 150)
                            .overlay(
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    Text("Select Source Image")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            )
                    }
                    
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text(selectedSourceImage == nil ? "Select Source Image" : "Change Source Image")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                // Camera Preview
                VStack(alignment: .leading, spacing: 10) {
                    Text("Live Camera")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    CameraView(
                        cameraManager: cameraManager,
                        faceProcessor: faceProcessor,
                        sourceImage: selectedSourceImage
                    )
                    .frame(height: 300)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                }
                .padding(.horizontal)
                
                // Control Buttons
                HStack(spacing: 20) {
                    Button(action: {
                        if cameraManager.isSessionRunning {
                            cameraManager.stopSession()
                        } else {
                            cameraManager.startSession()
                        }
                    }) {
                        HStack {
                            Image(systemName: cameraManager.isSessionRunning ? "stop.circle.fill" : "play.circle.fill")
                            Text(cameraManager.isSessionRunning ? "Stop" : "Start")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(cameraManager.isSessionRunning ? Color.red : Color.green)
                        .cornerRadius(10)
                    }
                    .disabled(selectedSourceImage == nil)
                    
                    Button(action: {
                        // Save current frame
                        if let currentFrame = cameraManager.currentFrame {
                            UIImageWriteToSavedPhotosAlbum(currentFrame, nil, nil, nil)
                            alertMessage = "Frame saved to Photos!"
                            showingAlert = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Save Frame")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(10)
                    }
                    .disabled(!cameraManager.isSessionRunning)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedSourceImage)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .alert("Info", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            // Request camera permission
            cameraManager.requestCameraPermission()
            // Load AI models
            modelManager.loadModels()
        }
        .onChange(of: selectedSourceImage) { newImage in
            if let image = newImage {
                // Process the selected image when it changes
                faceProcessor.processFrame(image, with: selectedSourceImage)
            }
        }
    }
}

#Preview {
    ContentView()
}
