#!/bin/bash

# Math Whizz App - Build Automation Script
# Usage: ./build.sh [command]
# Make executable with: chmod +x build.sh

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# App configuration
APP_NAME="Math Whizz"
BUNDLE_ID="com.mathwhizz.app"
VERSION=$(grep "version:" pubspec.yaml | cut -d' ' -f2)

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}=================================${NC}"
    echo -e "${PURPLE} $1${NC}"
    echo -e "${PURPLE}=================================${NC}"
}

# Show help
show_help() {
    echo -e "${BLUE}Math Whizz Build Script${NC}"
    echo ""
    echo "Usage: ./build.sh [command]"
    echo ""
    echo "Commands:"
    echo "  help              Show this help message"
    echo "  clean             Clean all build files and caches"
    echo "  clean-nuclear     Complete clean (removes all dependencies)"
    echo "  deps              Get/update dependencies"
    echo "  analyze           Run Flutter analyzer"
    echo "  test              Run tests"
    echo ""
    echo "Development:"
    echo "  run-macos         Run on macOS"
    echo "  run-ios           Run on iOS simulator"
    echo "  run-ipad          Run on iPad simulator specifically"
    echo ""
    echo "Building:"
    echo "  build-macos       Build macOS release version"
    echo "  build-ios         Build iOS release for simulator"
    echo "  build-ios-device  Build iOS release for device"
    echo "  build-ipa         Build IPA for distribution"
    echo "  build-all         Build all platforms"
    echo ""
    echo "Simulators:"
    echo "  list-simulators   List available iOS simulators"
    echo "  start-ipad        Start iPad Pro 11-inch simulator"
    echo "  start-simulator   Open Simulator app"
    echo ""
    echo "Examples:"
    echo "  ./build.sh clean && ./build.sh run-macos"
    echo "  ./build.sh build-all"
    echo "  ./build.sh start-ipad && ./build.sh run-ios"
    echo ""
}

# Check if Flutter is installed
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
}

# Check if we're in the right directory
check_directory() {
    if [[ ! -f "pubspec.yaml" ]]; then
        print_error "Not in a Flutter project directory (pubspec.yaml not found)"
        exit 1
    fi
}

# Clean build files
clean_build() {
    print_header "Cleaning Build Files"
    print_status "Running flutter clean..."
    flutter clean
    
    print_status "Removing additional build artifacts..."
    rm -rf build/
    rm -rf ios/build/
    rm -rf .dart_tool/build/
    
    print_success "Clean completed"
}

# Nuclear clean - removes everything
clean_nuclear() {
    print_header "Nuclear Clean - Removing All Build Files"
    print_warning "This will remove all dependencies and build files"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        flutter clean
        rm -rf build/
        rm -rf ios/build/
        rm -rf ios/Pods/
        rm -rf ios/Podfile.lock
        rm -rf ios/.symlinks/
        rm -rf .dart_tool/
        rm -rf android/app/build/
        
        print_status "Clearing pub cache..."
        flutter pub cache clean
        
        print_success "Nuclear clean completed"
        print_status "Run './build.sh deps' to restore dependencies"
    else
        print_status "Clean cancelled"
    fi
}

# Get dependencies
get_dependencies() {
    print_header "Getting Dependencies"
    flutter pub get
    
    if [[ -d "ios" ]]; then
        print_status "Installing iOS pods..."
        cd ios
        pod install
        cd ..
    fi
    
    print_success "Dependencies updated"
}

# Run analyzer
run_analyzer() {
    print_header "Running Flutter Analyzer"
    flutter analyze --no-fatal-infos
    print_success "Analysis completed"
}

# Run tests
run_tests() {
    print_header "Running Tests"
    if [[ -d "test" ]]; then
        flutter test
        print_success "Tests completed"
    else
        print_warning "No test directory found"
    fi
}

# Run on macOS
run_macos() {
    print_header "Running on macOS"
    print_status "Starting Math Whizz on macOS..."
    flutter run -d macos
}

# Run on iOS simulator
run_ios() {
    print_header "Running on iOS Simulator"
    # Check if any iOS simulator is available
    if flutter devices | grep -q "iOS"; then
        print_status "Starting Math Whizz on iOS simulator..."
        flutter run -d ios
    else
        print_warning "No iOS simulator detected. Starting iPad simulator..."
        start_ipad_simulator
        sleep 3
        flutter run -d ios
    fi
}

# Run specifically on iPad
run_ipad() {
    print_header "Running on iPad Simulator"
    start_ipad_simulator
    sleep 3
    print_status "Starting Math Whizz on iPad..."
    flutter run -d ios
}

# List available simulators
list_simulators() {
    print_header "Available iOS Simulators"
    xcrun simctl list devices available | grep -E "(iPad|iPhone)"
}

# Start iPad simulator
start_ipad_simulator() {
    print_status "Starting iPad Pro 11-inch simulator..."
    
    # Find iPad Pro 11-inch simulator
    IPAD_ID=$(xcrun simctl list devices available | grep "iPad Pro 11-inch (M4)" | head -1 | grep -o -E '\([A-F0-9-]+\)' | tr -d '()')
    
    if [[ -n "$IPAD_ID" ]]; then
        xcrun simctl boot "$IPAD_ID" 2>/dev/null || true
        open -a Simulator
        print_success "iPad simulator started"
    else
        print_warning "iPad Pro 11-inch simulator not found, using any available iPad"
        # Try to find any iPad
        IPAD_ID=$(xcrun simctl list devices available | grep "iPad" | head -1 | grep -o -E '\([A-F0-9-]+\)' | tr -d '()')
        if [[ -n "$IPAD_ID" ]]; then
            xcrun simctl boot "$IPAD_ID" 2>/dev/null || true
            open -a Simulator
            print_success "iPad simulator started"
        else
            print_error "No iPad simulator found"
            exit 1
        fi
    fi
}

# Start simulator app
start_simulator() {
    print_status "Opening Simulator app..."
    open -a Simulator
    print_success "Simulator app opened"
}

# Build macOS release
build_macos() {
    print_header "Building macOS Release"
    flutter build macos --release
    
    BUILD_PATH="build/macos/Build/Products/Release/math_whizz_app.app"
    if [[ -d "$BUILD_PATH" ]]; then
        print_success "macOS build completed"
        print_status "Built app location: $BUILD_PATH"
        print_status "Run with: open $BUILD_PATH"
    else
        print_error "macOS build failed"
        exit 1
    fi
}

# Build iOS for simulator
build_ios() {
    print_header "Building iOS Release for Simulator"
    flutter build ios --release --simulator
    
    BUILD_PATH="build/ios/iphonesimulator/Runner.app"
    if [[ -d "$BUILD_PATH" ]]; then
        print_success "iOS simulator build completed"
        print_status "Built app location: $BUILD_PATH"
    else
        print_error "iOS build failed"
        exit 1
    fi
}

# Build iOS for device
build_ios_device() {
    print_header "Building iOS Release for Device"
    flutter build ios --release --no-simulator
    
    BUILD_PATH="build/ios/iphoneos/Runner.app"
    if [[ -d "$BUILD_PATH" ]]; then
        print_success "iOS device build completed"
        print_status "Built app location: $BUILD_PATH"
    else
        print_error "iOS device build failed"
        exit 1
    fi
}

# Build IPA for distribution
build_ipa() {
    print_header "Building IPA for Distribution"
    flutter build ipa --release
    
    IPA_PATH="build/ios/ipa/math_whizz_app.ipa"
    if [[ -f "$IPA_PATH" ]]; then
        print_success "IPA build completed"
        print_status "IPA location: $IPA_PATH"
        print_status "Upload to App Store Connect or distribute via TestFlight"
    else
        print_error "IPA build failed"
        exit 1
    fi
}

# Build all platforms
build_all() {
    print_header "Building All Platforms"
    
    print_status "Building macOS..."
    build_macos
    
    print_status "Building iOS for simulator..."
    build_ios
    
    print_success "All builds completed successfully!"
}

# Main script logic
main() {
    check_flutter
    check_directory
    
    case "${1:-help}" in
        "help"|"-h"|"--help")
            show_help
            ;;
        "clean")
            clean_build
            ;;
        "clean-nuclear")
            clean_nuclear
            ;;
        "deps")
            get_dependencies
            ;;
        "analyze")
            run_analyzer
            ;;
        "test")
            run_tests
            ;;
        "run-macos")
            run_macos
            ;;
        "run-ios")
            run_ios
            ;;
        "run-ipad")
            run_ipad
            ;;
        "list-simulators")
            list_simulators
            ;;
        "start-ipad")
            start_ipad_simulator
            ;;
        "start-simulator")
            start_simulator
            ;;
        "build-macos")
            build_macos
            ;;
        "build-ios")
            build_ios
            ;;
        "build-ios-device")
            build_ios_device
            ;;
        "build-ipa")
            build_ipa
            ;;
        "build-all")
            build_all
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
