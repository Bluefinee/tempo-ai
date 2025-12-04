#!/bin/bash
echo "🛠️ Auto-fixing all project issues..."
echo "===================================="

# TypeScript API
echo ""
echo "🔧 Fixing TypeScript API..."
echo "---------------------------"
cd backend || exit 1
if pnpm run quality:fix; then
    echo "✅ TypeScript API auto-fix completed"
else
    echo "⚠️ Some TypeScript issues require manual fixing"
fi

# Security fixes
echo "🔒 Running security fixes..."
if pnpm run security:fix; then
    echo "✅ Security vulnerabilities fixed"
else
    echo "⚠️ Some security issues require manual attention"
fi
cd ..

# Swift iOS  
echo ""
echo "🔧 Fixing Swift iOS..."
echo "----------------------"
cd ios || exit 1
if ./scripts/fix-all.sh; then
    echo "✅ Swift iOS auto-fix completed"
else
    echo "⚠️ Some Swift issues require manual fixing"
fi
cd ..

echo ""
echo "🎉 All auto-fixes completed!"
echo "============================="
echo "💡 Run './scripts/quality-check-all.sh' to verify all fixes"