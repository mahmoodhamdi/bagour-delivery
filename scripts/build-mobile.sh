#!/bin/bash

# Bagour Delivery Mobile Apps Build Script
# Usage: ./build-mobile.sh [customer|delivery|all] [apk|aab|ios]

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${GREEN}[BUILD]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

build_customer_app() {
    local build_type=$1
    print_step "Building Customer App ($build_type)..."

    cd "$ROOT_DIR/customer-app"

    # Clean and get dependencies
    flutter clean
    flutter pub get

    # Generate Freezed files
    dart run build_runner build --delete-conflicting-outputs

    case $build_type in
        apk)
            flutter build apk --release
            print_step "Customer APK: build/app/outputs/flutter-apk/app-release.apk"
            ;;
        aab)
            flutter build appbundle --release
            print_step "Customer AAB: build/app/outputs/bundle/release/app-release.aab"
            ;;
        ios)
            flutter build ios --release --no-codesign
            print_step "Customer iOS: build/ios/iphoneos/Runner.app"
            ;;
    esac
}

build_delivery_app() {
    local build_type=$1
    print_step "Building Delivery App ($build_type)..."

    cd "$ROOT_DIR/delivery-app"

    # Clean and get dependencies
    flutter clean
    flutter pub get

    # Generate Freezed files
    dart run build_runner build --delete-conflicting-outputs

    case $build_type in
        apk)
            flutter build apk --release
            print_step "Delivery APK: build/app/outputs/flutter-apk/app-release.apk"
            ;;
        aab)
            flutter build appbundle --release
            print_step "Delivery AAB: build/app/outputs/bundle/release/app-release.aab"
            ;;
        ios)
            flutter build ios --release --no-codesign
            print_step "Delivery iOS: build/ios/iphoneos/Runner.app"
            ;;
    esac
}

# Parse arguments
APP=${1:-all}
BUILD_TYPE=${2:-apk}

print_step "Bagour Delivery - Mobile Build Script"
print_step "App: $APP | Build Type: $BUILD_TYPE"

case $APP in
    customer)
        build_customer_app $BUILD_TYPE
        ;;
    delivery)
        build_delivery_app $BUILD_TYPE
        ;;
    all)
        build_customer_app $BUILD_TYPE
        build_delivery_app $BUILD_TYPE
        ;;
    *)
        print_error "Unknown app: $APP"
        echo "Usage: $0 [customer|delivery|all] [apk|aab|ios]"
        exit 1
        ;;
esac

print_step "Build complete!"
