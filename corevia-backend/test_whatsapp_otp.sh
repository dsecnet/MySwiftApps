#!/bin/bash

echo "🧪 Testing WhatsApp OTP"
echo "======================"
echo ""

# Check if backend is running
if ! lsof -ti:8000 > /dev/null 2>&1; then
    echo "❌ Backend is not running on port 8000"
    echo "   Start it with: uvicorn app.main:app --reload"
    exit 1
fi

# Get phone number
read -p "Enter phone number (e.g., +994559412091): " PHONE
read -p "Enter email (e.g., test@corevia.life): " EMAIL

echo ""
echo "📤 Sending OTP to WhatsApp: $PHONE"
echo ""

# Send OTP
RESPONSE=$(curl -s -X POST http://localhost:8000/api/v1/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d "{\"email\": \"$EMAIL\", \"phone_number\": \"$PHONE\"}")

echo "Response: $RESPONSE"
echo ""

# Check if successful
if echo "$RESPONSE" | grep -q '"success":true'; then
    echo "✅ OTP sent successfully!"
    
    # If mock mode, show code
    if echo "$RESPONSE" | grep -q '"code"'; then
        CODE=$(echo "$RESPONSE" | grep -o '"code":"[0-9]*"' | grep -o '[0-9]*')
        echo "🔐 OTP Code (mock mode): $CODE"
    else
        echo "📱 Check your WhatsApp for the OTP code"
    fi
    
    echo ""
    read -p "Enter OTP code: " OTP
    read -p "Enter new password: " NEW_PASS
    
    echo ""
    echo "🔄 Resetting password..."
    
    RESET_RESPONSE=$(curl -s -X POST http://localhost:8000/api/v1/auth/reset-password \
      -H "Content-Type: application/json" \
      -d "{\"email\": \"$EMAIL\", \"phone_number\": \"$PHONE\", \"otp_code\": \"$OTP\", \"new_password\": \"$NEW_PASS\"}")
    
    echo "Response: $RESET_RESPONSE"
    
    if echo "$RESET_RESPONSE" | grep -q '"success":true'; then
        echo ""
        echo "✅ Password reset successful!"
    else
        echo ""
        echo "❌ Password reset failed"
    fi
else
    echo "❌ Failed to send OTP"
fi

echo ""
