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
if swift-format --mode diff --recursive TempoAI/TempoAI/ | grep -q "^"; then
    echo "❌ Code formatting issues found"
    echo "💡 Run './scripts/fix-all.sh' to auto-fix formatting"
    exit 1
else
    echo "✅ Swift formatting is correct"
fi

# Build check (型チェック相当)
echo "🔨 Building iOS project..."
if xcodebuild -project TempoAI/TempoAI.xcodeproj -scheme TempoAI -destination 'platform=iOS Simulator,name=iPhone 15' build > /dev/null 2>&1; then
    echo "✅ iOS project builds successfully"
else
    echo "❌ iOS project build failed"
    echo "💡 Check Xcode for compilation errors"
    exit 1
fi

echo "🎉 All Swift quality checks passed!"