#!/bin/bash

# Tempo AI API Test Script
set -e

BASE_URL="http://localhost:8787"
TEST_DATA_FILE="tests/data/sample-request.json"

echo "🧪 Testing Tempo AI API..."
echo "================================"

# Check dependencies
echo "0. Checking dependencies..."
if ! command -v curl &> /dev/null; then
    echo "❌ curl is required but not installed."
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "❌ jq is required but not installed."
    exit 1
fi

if [ ! -f "$TEST_DATA_FILE" ]; then
    echo "❌ Test data file not found: $TEST_DATA_FILE"
    exit 1
fi

# Check if server is running
echo "1. Checking if server is running..."
if curl --fail --silent --max-time 10 "$BASE_URL" > /dev/null; then
    echo "✅ Server is running"
else
    echo "❌ Server is not running. Please run 'npm run dev' first."
    exit 1
fi

# Test root endpoint
echo ""
echo "2. Testing root endpoint..."
curl --fail --silent --max-time 10 "$BASE_URL" | jq .

# Test health status
echo ""
echo "3. Testing health status..."
curl --fail --silent --max-time 10 "$BASE_URL/api/health/status" | jq .

# Test weather API
echo ""
echo "4. Testing weather API..."
curl --fail --silent --max-time 30 -X POST "$BASE_URL/api/test/weather" \
  -H "Content-Type: application/json" \
  -d '{"latitude": 35.6895, "longitude": 139.6917}' \
  | jq '.weather.current | {temperature: .temperature_2m, humidity: .relative_humidity_2m}'

# Test mock analysis
echo ""
echo "5. Testing mock analysis..."
curl --fail --silent --max-time 30 -X POST "$BASE_URL/api/test/analyze-mock" \
  -H "Content-Type: application/json" \
  -d @"$TEST_DATA_FILE" \
  | jq '.advice | {theme, summary}'

# Test real analysis (will show API key error)
echo ""
echo "6. Testing real analysis (expects API key error)..."
RESPONSE=$(curl --silent --max-time 30 -X POST "$BASE_URL/api/health/analyze" \
  -H "Content-Type: application/json" \
  -d @"$TEST_DATA_FILE")
  
if echo "$RESPONSE" | grep -q "Claude API key not configured"; then
    echo "✅ API key validation working correctly"
else
    echo "⚠️  Unexpected response: $RESPONSE"
fi

echo ""
echo "✅ All tests completed!"
echo ""
echo "Next steps:"
echo "- Set GEMINI_API_KEY in .dev.vars for full AI functionality"
echo "- Run 'npm run type-check' to verify TypeScript"
echo "- Run 'npm run lint' to check code style"