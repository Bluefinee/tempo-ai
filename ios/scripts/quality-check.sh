#!/bin/bash
set -e

echo "🔍 Running Swift quality checks..."

# Check if SwiftLint is installed
if ! command -v swiftlint &> /dev/null; then
    echo "⚠️ SwiftLint not found. Installing..."
    if command -v brew &> /dev/null; then
        brew install swiftlint
    else
        echo "❌ SwiftLint required but not found and Homebrew unavailable"
        echo "Install via: brew install swiftlint (macOS) or via your package manager"
        exit 1
    fi
fi

# Check if swift-format is installed
if ! command -v swift-format &> /dev/null; then
    echo "⚠️ swift-format not found. Installing..."
    if command -v brew &> /dev/null; then
        brew install swift-format
    else
        echo "❌ swift-format required but not found and Homebrew unavailable"
        echo "Install via: brew install swift-format (macOS) or via your package manager"
        exit 1
    fi
fi

# SwiftLint check
echo "📝 Running SwiftLint..."
SWIFTLINT_CACHE_PATH="${PWD}/.swiftlint_cache"
mkdir -p "$SWIFTLINT_CACHE_PATH"
export SWIFTLINT_CACHE_PATH
if swiftlint --strict --no-cache; then
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

# Build check (type checking equivalent)
echo "🔨 Building iOS project..."
PROJECT_PATH="TempoAI/TempoAI.xcodeproj"
SCHEME="TempoAI"

# Validate prerequisites
if ! command -v xcodebuild >/dev/null 2>&1; then
    echo "❌ xcodebuild not found"
    exit 1
fi

if [ ! -d "$PROJECT_PATH" ]; then
    echo "❌ Project not found at $PROJECT_PATH"
    exit 1
fi

# Try to build with simulator if available, otherwise use generic iOS destination
if SIMULATOR_ID=$(xcrun simctl list devices available 2>/dev/null | grep -m 1 "iPhone" | awk -F '[()]' '{print $2}') && [ -n "$SIMULATOR_ID" ]; then
    echo "📱 Using iPhone simulator: $SIMULATOR_ID"
    BUILD_CMD=(xcodebuild -project "$PROJECT_PATH" -scheme "$SCHEME" -destination "platform=iOS Simulator,id=$SIMULATOR_ID" -derivedDataPath "${PWD}/DerivedData" build)
else
    echo "⚠️ No simulator available; using generic iOS Simulator destination"
    BUILD_CMD=(xcodebuild -project "$PROJECT_PATH" -scheme "$SCHEME" -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath "${PWD}/DerivedData" build)
fi

if "${BUILD_CMD[@]}" > /dev/null 2>&1; then
    echo "✅ iOS project builds successfully"
else
    echo "❌ iOS project build failed"
    echo "💡 Check Xcode for compilation errors"
    exit 1
fi

echo "🎉 All Swift quality checks passed!"
