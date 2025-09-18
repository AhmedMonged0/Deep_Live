import SwiftUI

struct LoadingView: View {
    let message: String
    let progress: Double?
    @State private var isAnimating = false
    
    init(message: String = "Loading...", progress: Double? = nil) {
        self.message = message
        self.progress = progress
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Animated Loading Indicator
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                if let progress = progress {
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: progress)
                } else {
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                }
            }
            
            // Loading Message
            VStack(spacing: 8) {
                Text(message)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let progress = progress {
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .onAppear {
            isAnimating = true
        }
    }
}

struct FullScreenLoadingView: View {
    let message: String
    let progress: Double?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            LoadingView(message: message, progress: progress)
        }
    }
}

struct ProcessingStepsView: View {
    let steps: [ProcessingStep]
    let currentStep: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                ProcessingStepRow(
                    step: step,
                    isCompleted: index < currentStep,
                    isCurrent: index == currentStep
                )
            }
        }
        .padding()
    }
}

struct ProcessingStep {
    let title: String
    let description: String
    let icon: String
}

struct ProcessingStepRow: View {
    let step: ProcessingStep
    let isCompleted: Bool
    let isCurrent: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            // Step Icon
            ZStack {
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 30, height: 30)
                
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
                    .font(.system(size: 14, weight: .medium))
            }
            
            // Step Content
            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.body)
                    .fontWeight(isCurrent ? .semibold : .regular)
                    .foregroundColor(textColor)
                
                Text(step.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Status Indicator
            if isCompleted {
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
                    .font(.system(size: 16, weight: .medium))
            } else if isCurrent {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
    }
    
    private var iconBackgroundColor: Color {
        if isCompleted {
            return .green.opacity(0.2)
        } else if isCurrent {
            return .blue.opacity(0.2)
        } else {
            return .gray.opacity(0.2)
        }
    }
    
    private var iconColor: Color {
        if isCompleted {
            return .green
        } else if isCurrent {
            return .blue
        } else {
            return .gray
        }
    }
    
    private var iconName: String {
        if isCompleted {
            return "checkmark"
        } else {
            return step.icon
        }
    }
    
    private var textColor: Color {
        if isCompleted {
            return .primary
        } else if isCurrent {
            return .primary
        } else {
            return .secondary
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        LoadingView(message: "Processing...", progress: 0.6)
        
        ProcessingStepsView(
            steps: [
                ProcessingStep(title: "Detecting Faces", description: "Analyzing the image", icon: "eye"),
                ProcessingStep(title: "Processing", description: "Applying face swap", icon: "gear"),
                ProcessingStep(title: "Enhancing", description: "Improving quality", icon: "sparkles"),
                ProcessingStep(title: "Finalizing", description: "Saving result", icon: "checkmark")
            ],
            currentStep: 2
        )
    }
    .padding()
}
