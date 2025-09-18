import SwiftUI

struct MainTabView: View {
    @StateObject private var appState = AppStateManager()
    @StateObject private var permissionManager = PermissionManager.shared
    @StateObject private var notificationManager = NotificationManager()
    
    var body: some View {
        TabView {
            // Main Camera View
            ContentView()
                .tabItem {
                    Image(systemName: "camera.fill")
                    Text("Camera")
                }
                .tag(0)
            
            // Gallery View
            GalleryView(isPresented: .constant(false))
                .tabItem {
                    Image(systemName: "photo.on.rectangle")
                    Text("Gallery")
                }
                .tag(1)
            
            // Settings View
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(2)
            
            // Statistics View
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Statistics")
                }
                .tag(3)
        }
        .accentColor(.blue)
        .overlay(
            // Permission View Overlay
            Group {
                if !permissionManager.canUseApp {
                    PermissionView()
                        .background(Color(.systemBackground))
                }
            }
        )
        .overlay(
            // Notification Overlay
            VStack {
                Spacer()
                NotificationContainerView(notificationManager: notificationManager)
            }
        )
        .onAppear {
            // Track app launch
            AnalyticsManager.shared.startSession()
            AnalyticsManager.shared.trackScreenView("main_tab")
        }
        .onDisappear {
            // Track app close
            AnalyticsManager.shared.endSession()
        }
    }
}

#Preview {
    MainTabView()
}
