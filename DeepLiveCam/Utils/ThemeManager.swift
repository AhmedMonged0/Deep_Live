import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: AppTheme = .system
    @Published var colorScheme: ColorScheme = .light
    
    private init() {
        loadTheme()
    }
    
    // MARK: - Theme Management
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        updateColorScheme()
        saveTheme()
    }
    
    private func updateColorScheme() {
        switch currentTheme {
        case .light:
            colorScheme = .light
        case .dark:
            colorScheme = .dark
        case .system:
            colorScheme = .light // Will be updated by system
        }
    }
    
    private func loadTheme() {
        if let themeRawValue = UserDefaults.standard.object(forKey: "AppTheme") as? Int,
           let theme = AppTheme(rawValue: themeRawValue) {
            currentTheme = theme
            updateColorScheme()
        }
    }
    
    private func saveTheme() {
        UserDefaults.standard.set(currentTheme.rawValue, forKey: "AppTheme")
    }
    
    // MARK: - Color Management
    
    func getPrimaryColor() -> Color {
        return .blue
    }
    
    func getSecondaryColor() -> Color {
        return .gray
    }
    
    func getAccentColor() -> Color {
        return .purple
    }
    
    func getBackgroundColor() -> Color {
        return Color(.systemBackground)
    }
    
    func getSurfaceColor() -> Color {
        return Color(.secondarySystemBackground)
    }
}

// MARK: - App Theme

enum AppTheme: Int, CaseIterable {
    case light = 0
    case dark = 1
    case system = 2
    
    var name: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case .system:
            return "System"
        }
    }
    
    var icon: String {
        switch self {
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        case .system:
            return "gear"
        }
    }
}

// MARK: - Custom Colors

extension Color {
    static let appPrimary = Color.blue
    static let appSecondary = Color.gray
    static let appAccent = Color.purple
    static let appBackground = Color(.systemBackground)
    static let appSurface = Color(.secondarySystemBackground)
    
    // Custom colors for the app
    static let deepLiveCamBlue = Color(red: 0.0, green: 0.48, blue: 1.0)
    static let deepLiveCamPurple = Color(red: 0.5, green: 0.0, blue: 1.0)
    static let deepLiveCamGreen = Color(red: 0.0, green: 0.8, blue: 0.4)
    static let deepLiveCamOrange = Color(red: 1.0, green: 0.6, blue: 0.0)
    static let deepLiveCamRed = Color(red: 1.0, green: 0.3, blue: 0.3)
}

// MARK: - Custom Fonts

extension Font {
    static let appTitle = Font.largeTitle.weight(.bold)
    static let appHeadline = Font.headline.weight(.semibold)
    static let appBody = Font.body
    static let appCaption = Font.caption
    static let appButton = Font.body.weight(.medium)
}

// MARK: - Custom Styles

struct AppButtonStyle: ButtonStyle {
    let color: Color
    let isFilled: Bool
    
    init(color: Color = .appPrimary, isFilled: Bool = true) {
        self.color = color
        self.isFilled = isFilled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(isFilled ? .white : color)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isFilled ? color : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(color, lineWidth: isFilled ? 0 : 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct AppCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

extension View {
    func appCard() -> some View {
        modifier(AppCardStyle())
    }
}

// MARK: - Theme Preview

struct ThemePreview: View {
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Theme Preview")
                .font(.appTitle)
                .foregroundColor(.primary)
            
            VStack(spacing: 15) {
                Button("Primary Button") { }
                    .buttonStyle(AppButtonStyle(color: .appPrimary))
                
                Button("Secondary Button") { }
                    .buttonStyle(AppButtonStyle(color: .appSecondary))
                
                Button("Accent Button") { }
                    .buttonStyle(AppButtonStyle(color: .appAccent))
                
                Button("Outlined Button") { }
                    .buttonStyle(AppButtonStyle(color: .appPrimary, isFilled: false))
            }
            .appCard()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Sample Text")
                    .font(.appHeadline)
                
                Text("This is a sample body text to demonstrate the theme colors and fonts.")
                    .font(.appBody)
                    .foregroundColor(.secondary)
                
                Text("Caption text")
                    .font(.appCaption)
                    .foregroundColor(.secondary)
            }
            .appCard()
        }
        .padding()
        .preferredColorScheme(themeManager.colorScheme)
    }
}

#Preview {
    ThemePreview()
}
