#!/bin/bash

echo "=== CoreVia Fitness News Test ==="
echo ""

# 1. Backend check
echo "1. Backend status:"
if curl -s http://localhost:8000/health > /dev/null 2>&1; then
    echo "✅ Backend işləyir (port 8000)"
else
    echo "❌ Backend işləmir!"
    exit 1
fi

echo ""

# 2. Login and get token
echo "2. Login test:"
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test_student@corevia.com","password":"Student123"}')

TOKEN=$(echo $LOGIN_RESPONSE | python3 -c "import sys, json; print(json.load(sys.stdin).get('access_token', ''))" 2>/dev/null)

if [ -z "$TOKEN" ]; then
    echo "❌ Login failed!"
    echo "Response: $LOGIN_RESPONSE"
    exit 1
else
    echo "✅ Login successful"
fi

echo ""

# 3. Test news endpoint
echo "3. News endpoint test:"
NEWS_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:8000/news/?limit=3")

NEWS_COUNT=$(echo $NEWS_RESPONSE | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data.get('articles', [])))" 2>/dev/null)

if [ "$NEWS_COUNT" -gt 0 ]; then
    echo "✅ News endpoint işləyir - $NEWS_COUNT xəbər alındı"
    echo ""
    echo "İlk xəbər:"
    echo $NEWS_RESPONSE | python3 -m json.tool | head -20
else
    echo "❌ News endpoint xəta qaytardı!"
    echo "Response: $NEWS_RESPONSE"
    exit 1
fi

echo ""
echo "=== Test UĞURLU ==="
echo ""
echo "Backend tamamilə işləyir. Problem iOS app-dadır."
echo "iOS app-da login olmağınızı yoxlayın!"
