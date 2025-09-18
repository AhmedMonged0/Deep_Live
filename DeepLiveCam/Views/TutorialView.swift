import SwiftUI

struct TutorialView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    private let tutorialPages = [
        TutorialPage(
            title: "Welcome to Deep Live Cam",
            description: "Transform your face in real-time with AI-powered face swapping technology.",
            imageName: "face.smiling",
            color: .blue
        ),
        TutorialPage(
            title: "Select Your Source Face",
            description: "Choose a photo from your library to use as the source face for swapping.",
            imageName: "photo.on.rectangle",
            color: .green
        ),
        TutorialPage(
            title: "Start the Camera",
            description: "Tap the start button to begin real-time face swapping with your camera.",
            imageName: "camera.fill",
            color: .orange
        ),
        TutorialPage(
            title: "Save Your Creations",
            description: "Capture and save your face-swapped photos and videos to share with friends.",
            imageName: "square.and.arrow.down",
            color: .purple
        )
    ]
    
    var body: some View {
        VStack {
            // Page Content
            TabView(selection: $currentPage) {
                ForEach(0..<tutorialPages.count, id: \.self) { index in
                    TutorialPageView(page: tutorialPages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            
            // Navigation Buttons
            HStack {
                if currentPage > 0 {
                    Button("Previous") {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                if currentPage < tutorialPages.count - 1 {
                    Button("Next") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .foregroundColor(.blue)
                } else {
                    Button("Get Started") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }
}

struct TutorialPage {
    let title: String
    let description: String
    let imageName: String
    let color: Color
}

struct TutorialPageView: View {
    let page: TutorialPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            Image(systemName: page.imageName)
                .font(.system(size: 80))
                .foregroundColor(page.color)
            
            // Title
            Text(page.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Description
            Text(page.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    TutorialView(isPresented: .constant(true))
}
