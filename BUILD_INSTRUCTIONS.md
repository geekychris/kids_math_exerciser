# Math Whizz - Build & Deployment Instructions

## 📋 Prerequisites

Before building the Math Whizz app, ensure you have the following installed:

### Required Software
- **Flutter SDK** (version 3.0 or higher)
- **Dart SDK** (comes with Flutter)
- **Xcode** (latest version for macOS/iOS development)
- **Xcode Command Line Tools**

### Verify Installation
```bash
# Check Flutter installation
flutter --version
flutter doctor

# Check Xcode installation
xcode-select --version

# Verify devices are available
flutter devices
```

---

## 🧹 Cleaning Builds

### Clean Flutter Build Cache
```bash
# Navigate to project directory
cd /path/to/math_whizz_app

# Clean Flutter build files
flutter clean

# Get dependencies again
flutter pub get

# Clean and reset pub cache (if needed)
flutter pub cache clean
flutter pub cache repair
```

### Clean Xcode Build Cache
```bash
# Clean iOS build files
rm -rf ios/build/
rm -rf build/

# Clean Xcode derived data (optional but thorough)
rm -rf ~/Library/Developer/Xcode/DerivedData/

# Clean Xcode archives (if you've created any)
rm -rf ~/Library/Developer/Xcode/Archives/
```

### Complete Clean (Nuclear Option)
```bash
# Remove all build artifacts and caches
flutter clean
rm -rf ios/build/
rm -rf build/
rm -rf ios/Pods/
rm -rf ios/Podfile.lock
rm -rf ios/.symlinks/
cd ios && pod cache clean --all && cd ..
flutter pub get
cd ios && pod install && cd ..
```

---

## 🖥️ macOS Development

### Running in macOS Simulator/Debug Mode
```bash
# Check available macOS devices
flutter devices | grep macOS

# Run on macOS desktop
flutter run -d macos

# Run with specific configuration
flutter run -d macos --debug
flutter run -d macos --profile
flutter run -d macos --release
```

### Building for macOS Distribution

#### Debug Build
```bash
# Build debug version for testing
flutter build macos --debug
```

#### Release Build
```bash
# Build optimized release version
flutter build macos --release

# Build with specific target
flutter build macos --release --target=lib/main.dart
```

#### Build Output Location
```bash
# Built app will be located at:
build/macos/Build/Products/Release/math_whizz_app.app
```

### Running Built macOS App
```bash
# Run the built app directly
open build/macos/Build/Products/Release/math_whizz_app.app

# Or from command line
build/macos/Build/Products/Release/math_whizz_app.app/Contents/MacOS/math_whizz_app
```

### Code Signing & Distribution (for Mac App Store)
```bash
# Build with code signing
flutter build macos --release --obfuscate --split-debug-info=symbols/

# For Mac App Store distribution
flutter build macos --release --target=lib/main.dart --dart-define=MAC_APP_STORE=true
```

---

## 📱 iPad/iOS Development

### Setting Up iOS Simulators

#### List Available Simulators
```bash
# List all iOS simulators
xcrun simctl list devices available

# List only iPad simulators
xcrun simctl list devices available | grep iPad
```

#### Start Specific iPad Simulator
```bash
# Start iPad Pro 11-inch (example)
xcrun simctl boot "iPad Pro 11-inch (M4)"

# Or use device ID
xcrun simctl boot "10BE0A76-1F2A-4EFD-ABD0-0640B7EB8A5C"

# Open Simulator app
open -a Simulator
```

#### Common iPad Simulators
```bash
# iPad Pro 11-inch (M4)
xcrun simctl boot "iPad Pro 11-inch (M4)"

# iPad Pro 13-inch (M4)
xcrun simctl boot "iPad Pro 13-inch (M4)"

# iPad Air 11-inch (M2)
xcrun simctl boot "iPad Air 11-inch (M2)"

# iPad (10th generation)
xcrun simctl boot "iPad (10th generation)"
```

### Running on iPad Simulator
```bash
# Check available iOS devices
flutter devices | grep iOS

# Run on any available iPad simulator
flutter run -d ios

# Run on specific iPad simulator
flutter run -d "iPad Pro 11-inch (M4)"

# Run with device ID
flutter run -d "10BE0A76-1F2A-4EFD-ABD0-0640B7EB8A5C"

# Run with different build modes
flutter run -d ios --debug
flutter run -d ios --profile
flutter run -d ios --release
```

### Building for iPad/iOS

#### Debug Build
```bash
# Build debug version for simulator
flutter build ios --debug --simulator

# Build debug version for device
flutter build ios --debug --no-simulator
```

#### Release Build
```bash
# Build release version for simulator
flutter build ios --release --simulator

# Build release version for device
flutter build ios --release --no-simulator
```

#### Build with Code Signing
```bash
# Build for device with automatic signing
flutter build ios --release --no-simulator --dart-define=DEVELOPMENT_TEAM=YOUR_TEAM_ID

# Build with specific provisioning profile
flutter build ios --release --no-simulator --export-options-plist=ios/ExportOptions.plist
```

#### Build Output Locations
```bash
# Simulator build
build/ios/iphonesimulator/Runner.app

# Device build
build/ios/iphoneos/Runner.app

# IPA for distribution
build/ios/ipa/math_whizz_app.ipa
```

### Building IPA for Distribution
```bash
# Build IPA for App Store or TestFlight
flutter build ipa --release

# Build IPA with specific export method
flutter build ipa --release --export-method=app-store

# Build IPA for ad-hoc distribution
flutter build ipa --release --export-method=ad-hoc
```

---

## 🚀 Quick Start Commands

### Development Workflow
```bash
# 1. Clean and prepare
flutter clean && flutter pub get

# 2. Run on macOS for development
flutter run -d macos

# 3. Run on iPad simulator for testing
flutter run -d ios

# 4. Build release versions
flutter build macos --release
flutter build ios --release --simulator
```

### One-Line Build Commands
```bash
# Build everything clean
flutter clean && flutter pub get && flutter build macos --release && flutter build ios --release --simulator

# Quick development setup
flutter clean && flutter pub get && flutter run -d macos

# iPad simulator quick start
xcrun simctl boot "iPad Pro 11-inch (M4)" && open -a Simulator && flutter run -d ios
```

---

## 🔧 Advanced Build Options

### Custom Build Configurations
```bash
# Build with custom app name
flutter build macos --release --dart-define=APP_NAME="Math Whizz Pro"

# Build with environment-specific settings
flutter build ios --release --dart-define=ENVIRONMENT=production

# Build with obfuscation (release only)
flutter build macos --release --obfuscate --split-debug-info=symbols/
flutter build ios --release --obfuscate --split-debug-info=symbols/
```

### Performance Optimization
```bash
# Build with tree-shaking
flutter build macos --release --tree-shake-icons

# Build with web renderers optimization (if web support added)
flutter build web --web-renderer canvaskit

# Profile build for performance testing
flutter run --profile -d macos
flutter run --profile -d ios
```

---

## 🐛 Troubleshooting

### Common Issues and Solutions

#### Flutter Clean Not Working
```bash
# Nuclear clean option
flutter clean
rm -rf build/
rm -rf ios/build/
rm -rf ios/Pods/
rm -rf ios/.symlinks/
rm -rf .dart_tool/
flutter pub get
```

#### iOS Build Errors
```bash
# Clean iOS specific files
cd ios
rm -rf build/
rm -rf Pods/
rm Podfile.lock
pod install
cd ..
flutter build ios --debug --simulator
```

#### macOS Build Errors
```bash
# Clean macOS specific files
rm -rf build/macos/
flutter build macos --debug
```

#### Simulator Not Detected
```bash
# Restart simulator services
sudo killall -9 com.apple.CoreSimulator.CoreSimulatorService
xcrun simctl list devices

# Open Xcode and check simulator settings
open -a Xcode
```

### Performance Issues
```bash
# Check Flutter doctor for issues
flutter doctor -v

# Update Flutter to latest
flutter upgrade
flutter pub upgrade

# Clear pub cache
flutter pub cache clean
```

---

## 📦 Distribution Checklist

### Before Building for Production

#### macOS Distribution
- [ ] Update version in `pubspec.yaml`
- [ ] Update macOS bundle identifier in `macos/Runner/Configs/AppInfo.xcconfig`
- [ ] Verify app signing certificates
- [ ] Test on clean macOS system
- [ ] Build release version: `flutter build macos --release`
- [ ] Test built app: `open build/macos/Build/Products/Release/math_whizz_app.app`

#### iOS/iPad Distribution
- [ ] Update version and build number in `ios/Runner/Info.plist`
- [ ] Verify provisioning profiles
- [ ] Test on multiple iPad sizes/models
- [ ] Build IPA: `flutter build ipa --release`
- [ ] Upload to TestFlight or App Store Connect

### App Store Submission
```bash
# Build for App Store
flutter build ipa --release --export-method=app-store

# Upload using Xcode or Application Loader
# The IPA will be at: build/ios/ipa/math_whizz_app.ipa
```

---

## 📖 Additional Resources

- **Flutter Documentation**: https://docs.flutter.dev/
- **iOS Deployment Guide**: https://docs.flutter.dev/deployment/ios
- **macOS Deployment Guide**: https://docs.flutter.dev/deployment/macos
- **App Store Guidelines**: https://developer.apple.com/app-store/guidelines/
- **Xcode Documentation**: https://developer.apple.com/documentation/xcode

---

## 🎯 Quick Reference

| Command | Description |
|---------|-------------|
| `flutter clean` | Clean build cache |
| `flutter pub get` | Get dependencies |
| `flutter devices` | List available devices |
| `flutter run -d macos` | Run on macOS |
| `flutter run -d ios` | Run on iOS simulator |
| `flutter build macos --release` | Build macOS release |
| `flutter build ios --release --simulator` | Build iOS release |
| `flutter build ipa --release` | Build iOS IPA |
| `xcrun simctl list devices` | List iOS simulators |
| `open -a Simulator` | Open iOS Simulator |

---

**Made with ❤️ for the Math Whizz app**
