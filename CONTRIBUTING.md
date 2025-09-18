# Contributing to Deep Live Cam

Thank you for your interest in contributing to Deep Live Cam! This document provides guidelines and information for contributors.

## How to Contribute

### 1. Reporting Issues

Before creating an issue, please:

- Check if the issue already exists
- Use the latest version of the app
- Provide detailed information about the problem

When creating an issue, include:

- **Device Information**: iOS version, device model
- **App Version**: Version number from Settings
- **Steps to Reproduce**: Clear, step-by-step instructions
- **Expected Behavior**: What should happen
- **Actual Behavior**: What actually happens
- **Screenshots**: If applicable
- **Logs**: Any error messages or logs

### 2. Suggesting Features

We welcome feature suggestions! Please:

- Check if the feature already exists
- Provide a clear description
- Explain the use case
- Consider the impact on existing users

### 3. Code Contributions

#### Getting Started

1. **Fork the Repository**
   ```bash
   git clone https://github.com/yourusername/IOS_DEEP_Live4.git
   cd IOS_DEEP_Live4
   ```

2. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make Changes**
   - Follow the coding standards
   - Write tests for new features
   - Update documentation

4. **Test Your Changes**
   - Run the app on different devices
   - Test edge cases
   - Check for memory leaks

5. **Submit a Pull Request**
   - Provide a clear description
   - Link to related issues
   - Include screenshots if applicable

#### Coding Standards

- **Swift**: Follow Apple's Swift API Design Guidelines
- **SwiftUI**: Use modern SwiftUI patterns
- **Architecture**: Follow MVVM pattern
- **Naming**: Use descriptive, clear names
- **Comments**: Document complex logic
- **Error Handling**: Handle errors gracefully

#### Code Style

```swift
// Good
class FaceDetectionService: ObservableObject {
    private let faceDetectionRequest = VNDetectFaceRectanglesRequest()
    
    func detectFaces(in image: UIImage) -> [VNFaceObservation] {
        // Implementation
    }
}

// Bad
class facedetectionservice {
    var facedetectionrequest = VNDetectFaceRectanglesRequest()
    
    func detectfaces(image: UIImage) -> [VNFaceObservation] {
        // Implementation
    }
}
```

### 4. Documentation

Help improve our documentation:

- Fix typos and grammar
- Add missing information
- Improve clarity
- Add examples

## Development Setup

### Prerequisites

- macOS 13.0 or later
- Xcode 15.0 or later
- iOS 17.0 or later
- CocoaPods (optional)

### Setup Steps

1. **Clone and Setup**
   ```bash
   git clone https://github.com/yourusername/IOS_DEEP_Live4.git
   cd IOS_DEEP_Live4
   pod install
   ```

2. **Open in Xcode**
   ```bash
   open DeepLiveCam.xcworkspace
   ```

3. **Configure Project**
   - Set your development team
   - Update Bundle Identifier
   - Set iOS Deployment Target

### Project Structure

```
DeepLiveCam/
├── DeepLiveCamApp.swift          # App entry point
├── ContentView.swift             # Main interface
├── Views/                        # SwiftUI views
│   ├── CameraView.swift
│   ├── ImagePicker.swift
│   ├── SettingsView.swift
│   └── ...
├── Services/                     # Business logic
│   ├── FaceSwapProcessor.swift
│   ├── FaceDetectionService.swift
│   └── ...
├── Models/                       # Data models
│   ├── FaceData.swift
│   └── ...
├── Utils/                        # Utilities
│   ├── Constants.swift
│   ├── Logger.swift
│   └── ...
└── Assets.xcassets/              # App assets
```

## Testing

### Unit Tests

Write unit tests for:

- Business logic
- Utility functions
- Data processing
- Error handling

### UI Tests

Test user interactions:

- Button taps
- Navigation
- Form submissions
- Camera functionality

### Manual Testing

Test on different:

- iOS versions
- Device sizes
- Orientations
- Memory conditions

## Pull Request Process

### Before Submitting

1. **Code Review**
   - Review your own code
   - Check for bugs
   - Ensure it follows standards

2. **Testing**
   - Test all functionality
   - Check edge cases
   - Verify performance

3. **Documentation**
   - Update README if needed
   - Add code comments
   - Update changelog

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] UI tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes
```

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors.

### Expected Behavior

- Be respectful and inclusive
- Accept constructive criticism
- Focus on what's best for the community
- Show empathy towards others

### Unacceptable Behavior

- Harassment or discrimination
- Trolling or inflammatory comments
- Personal attacks
- Inappropriate language

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Recognition

Contributors will be:

- Listed in the README
- Mentioned in release notes
- Credited in the app

## Questions?

If you have questions:

- Open a discussion on GitHub
- Contact us at support@deeplivecam.app
- Join our Discord community

---

Thank you for contributing to Deep Live Cam! 🚀