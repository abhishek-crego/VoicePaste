#!/bin/bash

# Build script for VoicePaste

echo "Building VoicePaste..."

# Clean previous build
rm -rf .build

# Build the app
swift build -c release

# Create app bundle structure
APP_NAME="VoicePaste"
APP_BUNDLE="$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy executable
cp .build/release/VoicePaste "$MACOS_DIR/$APP_NAME"

# Copy Info.plist
cp Sources/VoicePaste/Resources/Info.plist "$CONTENTS_DIR/"

# Create PkgInfo
echo "APPL????" > "$CONTENTS_DIR/PkgInfo"

# Sign the app (requires Developer ID)
# codesign --force --deep --sign "Developer ID Application: Your Name" "$APP_BUNDLE"

echo "Build complete! The app bundle is at: $APP_BUNDLE"
echo ""
echo "To run the app:"
echo "  open $APP_BUNDLE"
echo ""
echo "Note: You may need to grant the following permissions on first run:"
echo "  - Microphone access"
echo "  - Accessibility access (for auto-paste)"
echo ""
echo "To sign the app for distribution:"
echo "  codesign --force --deep --sign 'Developer ID Application: Your Name' $APP_BUNDLE"