#!/bin/bash

echo "🔧 Twilio WhatsApp OTP Setup"
echo "=============================="
echo ""

# Prompt for Twilio credentials
read -p "Enter your Twilio Account SID (starts with AC): " ACCOUNT_SID
read -p "Enter your Twilio Auth Token: " AUTH_TOKEN

# Update .env file
echo ""
echo "📝 Updating .env file..."

# Remove old Twilio config
sed -i.bak '/WHATSAPP_OTP_MOCK/d' .env
sed -i.bak '/TWILIO_ACCOUNT_SID/d' .env
sed -i.bak '/TWILIO_AUTH_TOKEN/d' .env
sed -i.bak '/TWILIO_WHATSAPP_FROM/d' .env

# Add new config
cat >> .env << ENVEOF

# WhatsApp OTP - REAL MODE
WHATSAPP_OTP_MOCK=false

# Twilio WhatsApp Configuration
TWILIO_ACCOUNT_SID=$ACCOUNT_SID
TWILIO_AUTH_TOKEN=$AUTH_TOKEN
TWILIO_WHATSAPP_FROM=whatsapp:+14155238886
ENVEOF

echo "✅ .env updated successfully!"
echo ""
echo "📱 Next Steps:"
echo "1. Open WhatsApp"
echo "2. Send message to: +1 415 523 8886"
echo "3. Message: join [your-code] (kod Twilio console-da)"
echo "4. Wait for confirmation"
echo "5. Restart backend: sudo supervisorctl restart corevia"
echo ""
echo "🧪 Test with:"
echo "   Phone: +994559412091 (sandbox-a join etmiş nömrə)"
echo ""
