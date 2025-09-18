import SwiftUI

struct ProcessingView: View {
    @ObservedObject var videoProcessor: VideoProcessor
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 30) {
            // Progress Circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: videoProcessor.progress)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: videoProcessor.progress)
                
                VStack {
                    Text("\(Int(videoProcessor.progress * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Processing")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Status Text
            VStack(spacing: 10) {
                Text("Processing Video")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Please wait while we process your video...")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Processing Steps
            VStack(alignment: .leading, spacing: 15) {
                ProcessingStepView(
                    title: "Analyzing Faces",
                    isCompleted: videoProcessor.progress > 0.2
                )
                
                ProcessingStepView(
                    title: "Applying Face Swap",
                    isCompleted: videoProcessor.progress > 0.6
                )
                
                ProcessingStepView(
                    title: "Enhancing Quality",
                    isCompleted: videoProcessor.progress > 0.8
                )
                
                ProcessingStepView(
                    title: "Finalizing Video",
                    isCompleted: videoProcessor.progress >= 1.0
                )
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Cancel Button
            if videoProcessor.isProcessing {
                Button("Cancel") {
                    // Cancel processing
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.red)
                .padding()
            }
        }
        .padding()
        .navigationBarHidden(true)
    }
}

struct ProcessingStepView: View {
    let title: String
    let isCompleted: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isCompleted ? .green : .gray)
                .font(.title3)
            
            Text(title)
                .font(.body)
                .foregroundColor(isCompleted ? .primary : .secondary)
            
            Spacer()
            
            if isCompleted {
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
                    .font(.caption)
            }
        }
    }
}

#Preview {
    ProcessingView(videoProcessor: VideoProcessor())
}
