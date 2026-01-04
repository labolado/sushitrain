#!/bin/bash

# Sushitrain iOS Build & Install Script
# Builds and installs the app to connected iOS devices

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCHEME="Synctrain"
PROJECT="Sushitrain.xcodeproj"
BUNDLE_ID="com.labolado.test.Sushitrain"
CONFIGURATION=${1:-"Debug"}  # Default to Debug

# Parse arguments
USE_RELEASE=false
if [ "$CONFIGURATION" = "Release" ]; then
    USE_RELEASE=true
fi

echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   Sushitrain iOS Build & Install Script     ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "📦 Configuration: ${GREEN}$CONFIGURATION${NC}"
echo -e "📱 Bundle ID: ${GREEN}$BUNDLE_ID${NC}"
echo ""

# Check for connected devices
echo -e "${BLUE}🔍 Scanning for iOS devices...${NC}"
DEVICES_INFO=$(xcrun devicectl list devices 2>/dev/null)
DEVICE_COUNT=0

# Parse devices
AVAILABLE_DEVICES=()
while IFS= read -r line; do
    if echo "$line" | grep -qE "iPhone|iPad" && ! echo "$line" | grep -q "Simulator"; then
        DEVICE_COUNT=$((DEVICE_COUNT + 1))
        DEVICE_NAME=$(echo "$line" | awk -F'[ ]' '{print $1}' | sed 's/^["\x27]//;s/["\x27]$//')
        DEVICE_ID=$(echo "$line" | awk '{print $2}')
        AVAILABLE_DEVICES+=("$DEVICE_ID|$DEVICE_NAME")
        echo -e "  ${GREEN}✓${NC} $DEVICE_NAME"
    fi
done <<< "$DEVICES_INFO"

echo ""
if [ $DEVICE_COUNT -eq 0 ]; then
    echo -e "${RED}❌ No iOS devices found!${NC}"
    echo ""
    echo "Please:"
    echo "  1. Connect your iPhone/iPad via USB"
    echo "  2. Unlock your device"
    echo "  3. Trust this computer if prompted"
    echo "  4. Run this script again"
    exit 1
fi

# Select first available device
FIRST_DEVICE="${AVAILABLE_DEVICES[0]}"
DEVICE_UDID=$(echo "$FIRST_DEVICE" | cut -d'|' -f1)
DEVICE_NAME=$(echo "$FIRST_DEVICE" | cut -d'|' -f2)

echo -e "${BLUE}🎯 Target device: ${GREEN}$DEVICE_NAME${NC}"
echo -e "${BLUE}📋 Device UDID: ${YELLOW}$DEVICE_UDID${NC}"
echo ""

# Clean previous build
echo -e "${BLUE}🧹 Cleaning previous build...${NC}"
rm -rf build/
mkdir -p build/

# Build the app
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${BLUE}🔨  Building $SCHEME ($CONFIGURATION)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo ""

BUILD_START=$(date +%s)

# Build for iOS device (arm64, NOT simulator)
xcodebuild -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -sdk iphoneos \
    -derivedDataPath ./build/DerivedData \
    ARCHS=arm64 \
    ONLY_ACTIVE_ARCH=NO \
    -allowProvisioningUpdates \
    clean build 2>&1 | tee build/build.log | grep -E "(BUILD SUCCEEDED|BUILD FAILED|error:|^\*\*)"

BUILD_END=$(date +%s)
BUILD_TIME=$((BUILD_END - BUILD_START))

# Check if build succeeded
if ! grep -q "BUILD SUCCEEDED" build/build.log; then
    echo ""
    echo -e "${RED}═══════════════════════════════════════════════${NC}"
    echo -e "${RED}❌  Build FAILED!${NC}"
    echo -e "${RED}═══════════════════════════════════════════════${NC}"
    echo ""
    echo "Check build.log for details:"
    echo "  less build/build.log"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Build successful!${NC} (${BUILD_TIME}s)"
echo ""

# Find the built .app file
APP_PATH=$(find ./build/DerivedData/Build/Products/$CONFIGURATION-iphoneos/ -name "*.app" -maxdepth 1 -type d | head -1)

if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
    echo -e "${RED}❌ Could not find built .app file${NC}"
    echo "Expected location: ./build/DerivedData/Build/Products/$CONFIGURATION-iphoneos/$SCHEME.app"
    exit 1
fi

echo -e "${GREEN}📦 App bundle: ${NC}$APP_PATH"
echo ""

# Verify bundle ID
ACTUAL_BUNDLE_ID=$(plutil -p "$APP_PATH/Info.plist" 2>/dev/null | grep "CFBundleIdentifier" | awk -F'"' '{print $2}' | head -1)
if [ -n "$ACTUAL_BUNDLE_ID" ]; then
    echo -e "${BLUE}📋 Bundle ID: ${GREEN}$ACTUAL_BUNDLE_ID${NC}"
fi
echo ""

# Install to device
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${BLUE}📱  Installing to device${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo ""

# Check if ios-deploy is available
if command -v ios-deploy &> /dev/null; then
    echo "Using ${CYAN}ios-deploy${NC}..."

    if ios-deploy --id "$DEVICE_UDID" --bundle "$APP_PATH" --debug --no-wifi --noninteractive; then
        echo ""
        echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
        echo -e "${GREEN}✅  Installation Successful!${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
        echo ""
        INSTALL_SUCCESS=true
    else
        echo ""
        echo -e "${YELLOW}⚠️  ios-deploy installation had issues, trying alternative...${NC}"
        INSTALL_SUCCESS=false
    fi
else
    echo "ios-deploy not found, using ${CYAN}xcrun devicectl${NC}..."
    INSTALL_SUCCESS=false
fi

# Fallback: use xcrun devicectl
if [ "$INSTALL_SUCCESS" = false ]; then
    echo ""
    echo "Using xcrun devicectl to install..."

    # Copy app to device
    if xcrun devicectl device install app --device "$DEVICE_UDID" "$APP_PATH" 2>&1; then
        echo ""
        echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
        echo -e "${GREEN}✅  Installation Successful!${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
        echo ""
        INSTALL_SUCCESS=true
    else
        echo ""
        echo -e "${RED}═══════════════════════════════════════════════${NC}"
        echo -e "${RED}❌  Installation Failed${NC}"
        echo -e "${RED}═══════════════════════════════════════════════${NC}"
        INSTALL_SUCCESS=false
    fi
fi

if [ "$INSTALL_SUCCESS" = true ]; then
    echo "📱 Device: ${GREEN}$DEVICE_NAME${NC}"
    echo "📦 Bundle: ${GREEN}$BUNDLE_ID${NC}"
    echo "⚙️  Config: ${GREEN}$CONFIGURATION${NC}"
    echo ""

    # Try to launch the app
    echo -e "${BLUE}🚀 Launching app...${NC}"
    if xcrun devicectl device launch app --device "$DEVICE_UDID" "$BUNDLE_ID" 2>&1; then
        echo -e "${GREEN}✅ App launched successfully!${NC}"
        echo ""
        echo -e "${CYAN}Happy testing! 🎉${NC}"
    else
        echo -e "${YELLOW}⚠️  App installed but couldn't launch automatically${NC}"
        echo "You can launch it manually from your device's home screen."
    fi
else
    echo ""
    echo -e "${RED}❌ Installation failed${NC}"
    echo ""
    echo "Troubleshooting:"
    echo ""
    echo "1. ${YELLOW}Check device connection:${NC}"
    echo "   xcrun devicectl list devices"
    echo ""
    echo "2. ${YELLOW}Verify developer certificate:${NC}"
    echo "   - Go to Xcode -> Settings -> Accounts"
    echo "   - Check your Apple ID is signed in"
    echo ""
    echo "3. ${YELLOW}Check provisioning profile:${NC}"
    echo "   - Make sure wildcard bundle ID com.labolado.test.* is enabled"
    echo "   - In Apple Developer Portal"
    echo ""
    echo "4. ${YELLOW}Install ios-deploy for better installation:${NC}"
    echo "   brew install ios-deploy"
    echo ""
    echo "5. ${YELLOW}Check build log:${NC}"
    echo "   less build/build.log"
    echo ""
    exit 1
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${BLUE}📝 Build Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo "Configuration: $CONFIGURATION"
echo "Device: $DEVICE_NAME"
echo "Bundle ID: $BUNDLE_ID"
echo "Build time: ${BUILD_TIME}s"
echo ""
