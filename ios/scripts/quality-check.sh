#!/bin/bash
set -e

echo "🔍 Running Swift quality checks..."

# Check if SwiftLint is installed
if ! command -v swiftlint &> /dev/null; then
    echo "⚠️ SwiftLint not found. Installing..."
    brew install swiftlint
fi

# Check if swift-format is installed
if ! command -v swift-format &> /dev/null; then
    echo "⚠️ swift-format not found. Installing..."
    brew install swift-format
fi

# SwiftLint check
echo "📝 Running SwiftLint..."
if swiftlint --strict; then
    echo "✅ SwiftLint passed"
else
    echo "❌ SwiftLint failed"
    echo "💡 Run './scripts/fix-all.sh' to auto-fix issues"
    exit 1
fi

# Swift Format check
echo "🎨 Checking Swift formatting..."
if swift-format lint --strict --recursive TempoAI/TempoAI/; then
    echo "✅ Swift formatting is correct"
else
    echo "❌ Code formatting issues found"
    echo "💡 Run './scripts/fix-all.sh' to auto-fix formatting"
    exit 1
fi

# Build check (型チェック相当)
echo "🔨 Building iOS project..."
if SIM_OUTPUT=$(xcrun simctl list devices available 2>/dev/null) && [ -n "$SIM_OUTPUT" ]; then
    SIMULATOR_ID=$(echo "$SIM_OUTPUT" | grep -m 1 "iPhone" | awk -F '[()]' '{print $2}')
    if [ -n "$SIMULATOR_ID" ]; then
        DESTINATION="platform=iOS Simulator,id=$SIMULATOR_ID"
        BUILD_CMD=(xcodebuild -project TempoAI/TempoAI.xcodeproj -scheme TempoAI -destination "$DESTINATION" build)
    else
        BUILD_CMD=()
    fi
else
    echo "⚠️ Simulator services unavailable; falling back to generic iOS build"
    BUILD_CMD=(xcodebuild -project TempoAI/TempoAI.xcodeproj -scheme TempoAI -destination 'generic/platform=iOS' build)
fi

if [ ${#BUILD_CMD[@]} -eq 0 ]; then
    echo "⚠️ No available simulator detected; falling back to generic iOS build"
    BUILD_CMD=(xcodebuild -project TempoAI/TempoAI.xcodeproj -scheme TempoAI -destination 'generic/platform=iOS' build)
fi

if "${BUILD_CMD[@]}" > /dev/null 2>&1; then
    echo "✅ iOS project builds successfully"
else
    echo "❌ iOS project build failed"
    echo "💡 Check Xcode for compilation errors"
    exit 1
fi

echo "🎉 All Swift quality checks passed!"
