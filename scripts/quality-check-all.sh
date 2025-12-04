#!/bin/bash
set -e

echo "🚀 Running full project quality checks..."
echo "======================================="

# TypeScript API
echo ""
echo "📝 Checking TypeScript API..."
echo "------------------------------"
(
    cd backend
    if pnpm run quality:check; then
        echo "✅ TypeScript API quality checks passed"
    else
        echo "❌ TypeScript API quality checks failed"
        echo "💡 Run 'cd backend && pnpm run quality:fix' to auto-fix"
        exit 1
    fi
) || exit 1

# Swift iOS
echo ""
echo "📱 Checking Swift iOS..."
echo "------------------------"
(
    cd ios
    if ./scripts/quality-check.sh; then
        echo "✅ Swift iOS quality checks passed"
    else
        echo "❌ Swift iOS quality checks failed"
        echo "💡 Run 'cd ios && ./scripts/fix-all.sh' to auto-fix"
        exit 1
    fi
) || exit 1

echo ""
echo "🎉 All project quality checks passed!"
echo "====================================="