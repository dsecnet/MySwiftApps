#!/bin/bash

API_URL="http://localhost:8000"

echo "🏠 Əmlak CRM - Auth Test"
echo "========================"
echo ""

# 1. Register
echo "1️⃣ Register new user..."
REGISTER_RESPONSE=$(curl -s -X POST "${API_URL}/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Vusal Dadashov",
    "email": "vusal@emlakcrm.az",
    "phone": "+994501234567",
    "password": "test123456",
    "agency_name": "Premium Əmlak",
    "city": "Bakı"
  }')

echo "$REGISTER_RESPONSE" | python3 -m json.tool
ACCESS_TOKEN=$(echo "$REGISTER_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])" 2>/dev/null)

if [ -n "$ACCESS_TOKEN" ]; then
    echo "✅ Register successful!"
    echo ""
else
    echo "❌ Register failed!"
    echo ""
fi

# 2. Login
echo "2️⃣ Login with credentials..."
LOGIN_RESPONSE=$(curl -s -X POST "${API_URL}/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "vusal@emlakcrm.az",
    "password": "test123456"
  }')

echo "$LOGIN_RESPONSE" | python3 -m json.tool
ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])" 2>/dev/null)

if [ -n "$ACCESS_TOKEN" ]; then
    echo "✅ Login successful!"
    echo ""
else
    echo "❌ Login failed!"
    exit 1
fi

# 3. Get current user
echo "3️⃣ Get current user info..."
curl -s -X GET "${API_URL}/api/v1/auth/me" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" | python3 -m json.tool

echo ""
echo "✅ All tests passed!"
