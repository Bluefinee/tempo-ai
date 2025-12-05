#!/bin/bash
echo "🔧 Auto-fixing Swift issues..."

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

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

# SwiftLint自動修正
echo "🔨 Running SwiftLint auto-fix..."
if swiftlint --fix; then
    echo "✅ SwiftLint auto-fix completed"
else
    echo "⚠️ Some SwiftLint issues require manual fixing"
fi

# Swift Format自動適用
echo "🎨 Applying Swift formatting..."
if swift-format --in-place --recursive "$PROJECT_DIR/TempoAI/TempoAI/"; then
    echo "✅ Swift formatting applied"
else
    echo "❌ Swift formatting failed"
    exit 1
fi

echo "🎉 Swift auto-fix completed!"