# Installation Guide - Deep Live Cam iOS

This guide will help you install and set up Deep Live Cam on your iOS device.

## Prerequisites

Before installing Deep Live Cam, make sure you have:

- **macOS 13.0 or later** (for development)
- **Xcode 15.0 or later**
- **iOS 17.0 or later** (target device)
- **Apple Developer Account** (for device installation)
- **CocoaPods** (optional, for additional dependencies)

## Installation Methods

### Method 1: Xcode Development (Recommended)

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/IOS_DEEP_Live4.git
   cd IOS_DEEP_Live4
   ```

2. **Open in Xcode**
   ```bash
   open DeepLiveCam.xcodeproj
   ```

3. **Configure the Project**
   - Select your development team in project settings
   - Change Bundle Identifier if needed
   - Set iOS Deployment Target to 17.0

4. **Install Dependencies (Optional)**
   ```bash
   pod install
   ```

5. **Build and Run**
   - Select your target device or simulator
   - Press ⌘+R to build and run

### Method 2: App Store (Future Release)

Once the app is released on the App Store, you can install it directly from there.

## Configuration

### 1. Permissions

The app requires the following permissions:

- **Camera Access**: For real-time face swapping
- **Photo Library Access**: To select source images

These permissions will be requested when you first use the app.

### 2. Settings

You can customize the app settings:

- **Video Quality**: Choose between Low, Medium, High, or Ultra
- **Output Format**: MOV, MP4, or M4V
- **Face Swap Settings**: Preserve mouth, eyes, blend intensity
- **Display Settings**: Auto-save, show face boxes

### 3. Models

The app uses Core ML models for face detection and processing. These are included in the app bundle and will be downloaded automatically on first use.

## Troubleshooting

### Common Issues

1. **Build Errors**
   - Make sure Xcode is up to date
   - Clean build folder (⇧⌘K)
   - Check iOS Deployment Target

2. **Permission Denied**
   - Go to Settings > Privacy & Security > Camera
   - Enable access for Deep Live Cam

3. **App Crashes**
   - Check device compatibility (iOS 17.0+)
   - Restart the app
   - Clear app data if needed

4. **Performance Issues**
   - Close other apps to free memory
   - Reduce video quality settings
   - Use a newer device for better performance

### Performance Optimization

- **Memory Management**: The app automatically manages memory usage
- **Image Processing**: Large images are automatically resized
- **Cache Management**: Use the clear cache option in settings

## Development Setup

### For Developers

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/IOS_DEEP_Live4.git
   cd IOS_DEEP_Live4
   ```

2. **Install Dependencies**
   ```bash
   pod install
   ```

3. **Open Workspace**
   ```bash
   open DeepLiveCam.xcworkspace
   ```

4. **Configure Development Team**
   - Select your team in project settings
   - Update Bundle Identifier
   - Set proper code signing

### Building for Distribution

1. **Archive the App**
   - Product > Archive in Xcode
   - Select your distribution method

2. **TestFlight**
   - Upload to App Store Connect
   - Add internal/external testers

3. **App Store**
   - Submit for review
   - Wait for approval

## System Requirements

### Minimum Requirements

- **iOS**: 17.0 or later
- **Device**: iPhone 12 or later, iPad (6th generation) or later
- **Storage**: 100 MB available space
- **Camera**: Front-facing camera required

### Recommended Requirements

- **iOS**: 17.2 or later
- **Device**: iPhone 14 or later, iPad Pro
- **Storage**: 500 MB available space
- **Memory**: 6 GB RAM or more

## Support

If you encounter any issues:

1. Check this troubleshooting guide
2. Visit our GitHub Issues page
3. Contact support at support@deeplivecam.app

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Note**: This is a development version. Some features may not work as expected and the app may be unstable.
