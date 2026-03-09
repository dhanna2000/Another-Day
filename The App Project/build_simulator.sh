#!/bin/bash

# Build script for iOS Simulator
# This avoids provisioning profile issues

echo "🚀 Building TheAppProject for iOS Simulator..."

# Check if Xcode is available
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: xcodebuild not found. Please install Xcode first."
    exit 1
fi

# Get available simulators
echo "📱 Available iOS Simulators:"
xcrun simctl list devices available | grep "iPhone" | head -5

# Build for simulator
echo "🔨 Building project..."
xcodebuild -project TheAppProject.xcodeproj \
           -scheme TheAppProject \
           -destination 'platform=iOS Simulator,name=iPhone 15' \
           -configuration Debug \
           build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "🎯 Next steps:"
    echo "1. Open TheAppProject.xcodeproj in Xcode"
    echo "2. Select 'iOS Simulator' as target"
    echo "3. Choose 'iPhone 15' or any available simulator"
    echo "4. Press ⌘+R to build and run"
else
    echo "❌ Build failed. Check the error messages above."
    exit 1
fi

