#!/bin/bash

# Orbit - Run Script
# Builds and launches the Orbit macOS app

set -e

echo "🚀 Building Orbit..."

# Build the app
xcodebuild -project Orbit.xcodeproj \
  -scheme Orbit \
  -configuration Debug \
  -derivedDataPath ./build \
  build

echo "✅ Build complete!"
echo "🎯 Launching Orbit..."

# Find and launch the app
APP_PATH="./build/Build/Products/Debug/Orbit.app"

if [ -d "$APP_PATH" ]; then
    open "$APP_PATH"
    echo "✨ Orbit is running!"
else
    echo "❌ Error: App not found at $APP_PATH"
    exit 1
fi
