import SwiftUI

struct NotificationView: View {
    let notification: AppNotification
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: notification.type.icon)
                .foregroundColor(notification.type.color)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(notification.message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

struct NotificationContainerView: View {
    @ObservedObject var notificationManager: NotificationManager
    
    var body: some View {
        VStack {
            ForEach(notificationManager.notifications) { notification in
                NotificationView(notification: notification) {
                    notificationManager.removeNotification(notification.id)
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
            
            Spacer()
        }
        .animation(.easeInOut(duration: 0.3), value: notificationManager.notifications.count)
    }
}

#Preview {
    NotificationContainerView(notificationManager: NotificationManager())
}
